// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMNativeAd.h"
#import "OpenMediationConstant.h"
#import "OMMediatedNativeAd.h"
#import "OMBidResponse.h"
@interface OMNativeAd()

@property (nonatomic, strong) id<OMMediatedNativeAd, customAdClick> mediatedAd;
@property (nonatomic, assign) BOOL rendering;
@property (nonatomic, assign) BOOL impr;
@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) NSObject *adapter;
@property (nonatomic, strong) OMBidResponse *bidResponse;
@end

@implementation OMNativeAd

- (instancetype)initWithMediatedAd:(id<OMMediatedNativeAd>)mediatedAd {
    self = [super init];
    if (self) {
        _mediatedAd = mediatedAd;
        _title = mediatedAd.title;
        _body = mediatedAd.body;
        _iconUrl = mediatedAd.iconUrl;
        _callToAction = mediatedAd.callToAction;
        _rating = mediatedAd.rating;
    }
    return self;
}

- (void)setCustomShowAd {
    if ([_mediatedAd respondsToSelector:@selector(setCustomShowAd)]) {
        [_mediatedAd setCustomShowAd];
    }
    
    
}
- (NSString *) adUrl {
    if ([_mediatedAd respondsToSelector:@selector(adUrl)]) {
        return [_mediatedAd adUrl];
    }
    return @"";
    
}

@end
