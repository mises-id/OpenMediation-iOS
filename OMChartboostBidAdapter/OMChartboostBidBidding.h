// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import <Foundation/Foundation.h>
#import "OMBiddingCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OMChartboostBidBidding : NSObject <OMCustomEventBid>
+ (void)bidWithNetworkItem:(OMBiddingNetworkItem*)networkItem adFormat:(OpenMediationAdFormat)format responseCallback:(void(^)(OMBiddingResponse *bidResponse))callback;

@end

NS_ASSUME_NONNULL_END
