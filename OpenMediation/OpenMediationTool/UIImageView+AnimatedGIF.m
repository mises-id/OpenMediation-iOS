//
//  UIImageView+AnimatedGIF.m
//  UIImageViewAnimatedGIF
//
//  Created by Tim Johnsen on 12/26/19.
//  Copyright © 2019 Tim Johnsen. All rights reserved.
//

#import "UIImageView+AnimatedGIF.h"

#import <ImageIO/CGImageAnimation.h>
#import <objc/runtime.h>

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@interface TJAnimatedImage ()

@property (nonatomic, nullable, readwrite) NSData *data;
@property (nonatomic, nullable, readwrite) NSURL *url;

@property (nonatomic, readwrite) CGSize size;

@end

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation TJAnimatedImage

- (instancetype)init
{
    if (self = [super init]) {
        _size = CGSizeZero;
    }
    return self;
}

+ (instancetype)animatedImageWithData:(nullable NSData *const)data
{
    TJAnimatedImage *const animatedImage = [TJAnimatedImage new];
    animatedImage.data = data;
    return animatedImage;
}

+ (instancetype)animatedImageWithURL:(nullable NSURL *const)url
{
    TJAnimatedImage *const animatedImage = [TJAnimatedImage new];
    animatedImage.url = url;
    return animatedImage;
}

- (NSUInteger)hash
{
    return [self.data hash] + [self.url hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TJAnimatedImage class]]) {
        return ((self.data == [(TJAnimatedImage *)object data] || [self.data isEqual:[(TJAnimatedImage *)object data]]) &&
                (self.url == [(TJAnimatedImage *)object url] || [self.url isEqual:[(TJAnimatedImage *)object url]]));
        
    }
    return NO;
}

- (CGSize)size
{
    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        CGImageSourceRef imageSource = nil;
        if (_data) {
            imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)_data, nil);
        } else if (_url) {
            imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)_url, nil);
        }
        if (imageSource) {
            if (CGImageSourceGetCount(imageSource) > 0) {
                NSDictionary *const properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
                const CGFloat width = [properties[(__bridge NSString *)kCGImagePropertyPixelWidth] doubleValue];
                const CGFloat height = [properties[(__bridge NSString *)kCGImagePropertyPixelHeight] doubleValue];
                _size = CGSizeMake(width, height);
            }
            CFRelease(imageSource);
        }
    }
    return _size;
}

@end

@implementation UIImageView (AnimatedGIF)

static BOOL _tj_configuredStillImageAnimatedImageMutualExclusivity;

+ (void)tj_configureStillImageAnimatedImageMutualExclusivity
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(setImage:);
        SEL swizzledSelector = @selector(_setImage:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
        _tj_configuredStillImageAnimatedImageMutualExclusivity = YES;
    });
}

- (void)_setImage:(UIImage *)image
{
    if (_tj_configuredStillImageAnimatedImageMutualExclusivity) {
        self.animatedImage = nil;
        [self _setImage:image];
    } else {
        NSAssert(NO, @"%s is being invoked when %@ hasn't been called", __PRETTY_FUNCTION__, NSStringFromSelector(@selector(tj_configureStillImageAnimatedImageMutualExclusivity)));
    }
}

- (void)_tj_setImageAnimated:(UIImage *const)image
{
    if (_tj_configuredStillImageAnimatedImageMutualExclusivity) {
        [self _setImage:image];
    } else {
        [self setImage:image];
    }
}

- (void)setAnimatedImage:(TJAnimatedImage *const)animatedImage
{
    if (self.animatedImage == animatedImage || [self.animatedImage isEqual:animatedImage]) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(animatedImage), animatedImage, OBJC_ASSOCIATION_RETAIN);
    
    if (@available(iOS 13.0, *)) {
        __weak typeof(self) weakSelf = self;
        __block size_t last_index = 0;
        void (^updateBlock)(size_t, CGImageRef, bool *) = ^(size_t index, CGImageRef  _Nonnull image, bool * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (index < last_index) {
                //a new loop
                *stop = true;
                if (strongSelf) {
                    [strongSelf setAnimatedImage:nil];
                    [strongSelf setAnimatedImage:animatedImage];
                }
                return;
            }
            if (strongSelf && [strongSelf.animatedImage isEqual:animatedImage]) {
                UIImage *const loadedImage = [UIImage imageWithCGImage:image];
                [strongSelf _tj_setImageAnimated:loadedImage];
                animatedImage.size = loadedImage.size;
                last_index = index;
            } else {
                *stop = true;
            }
        };
        
        [self _tj_setImageAnimated:nil];
        
        NSDictionary *options = @{
            //(NSString *)kCGImageAnimationLoopCount: @(2) // Set loop count
        };
        
        if (animatedImage.data) {
            CGAnimateImageDataWithBlock((__bridge CFDataRef)animatedImage.data,  (__bridge CFDictionaryRef)options, updateBlock);
        } else if (animatedImage.url) {
            CGAnimateImageAtURLWithBlock((__bridge CFURLRef)animatedImage.url,  (__bridge CFDictionaryRef)options, updateBlock);
        }
    } else {
        if (animatedImage.data) {
            [self _tj_setImageAnimated:[UIImage imageWithData:animatedImage.data]];
        } else if (animatedImage.url && [animatedImage.url isFileURL]) {
            [self _tj_setImageAnimated:[UIImage imageWithContentsOfFile:animatedImage.url.path]];
        } else {
            [self _tj_setImageAnimated:nil];
        }
    }
}

- (TJAnimatedImage *)animatedImage
{
    return objc_getAssociatedObject(self, @selector(animatedImage));
}

@end

@implementation TJAnimatedImageView

- (void)setImage:(UIImage *)image
{
    if (!_tj_configuredStillImageAnimatedImageMutualExclusivity) {
        // UIImageView handles nil-ing out animatedImage if tj_configureStillImageAnimatedImageMutualExclusivity is called
        self.animatedImage = nil;
    }
    [super setImage:image];
}

- (void)_tj_setImageAnimated:(UIImage *const)image
{
    if (_tj_configuredStillImageAnimatedImageMutualExclusivity) {
        [super _tj_setImageAnimated:image];
    } else {
        [super setImage:image];
    }
}

@end
