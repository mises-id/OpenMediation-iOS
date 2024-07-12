// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMCrossPromotionNativeMediaView.h"
#import "OMToolUmbrella.h"
#import "UIImageView+AnimatedGIF.h"

@implementation OMCrossPromotionNativeMediaView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.imgView];
        [_imgView addConstraintEqualSuperView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

-(BOOL) isGIF:(NSData *) data{
    if (data.length < 3) {
        return NO;
    }
    const char *bytes = [data bytes];
    if (bytes[0] == 'G' && bytes[1] == 'I' && bytes[2] == 'F') {
        return YES;
    }
    
    return NO;
}

- (void)setNativeAd:(OMCrossPromotionNativeAd *)nativeAd {
    _nativeAd  = nativeAd;
    NSData* data  = [NSData dataWithContentsOfFile:[nativeAd.adObject mainImgCachePath]];
    if ([self isGIF:data]) {
        _imgView.animatedImage = [TJAnimatedImage animatedImageWithData:data];
    } else {
        _imgView.image = [UIImage imageWithData:data];
    }
}

- (void)click {
    if(_nativeAd && _nativeAd.adDelegate && [_nativeAd.adDelegate respondsToSelector:@selector(OMCrossPromotionNativeAdDidClick:)]) {
        [_nativeAd.adDelegate OMCrossPromotionNativeAdDidClick:_nativeAd];
    }
}
@end
