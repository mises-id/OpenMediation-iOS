// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMAdSingletonInterface : NSObject


- (void)addAdEvent:(NSInteger)eventID placementID:(NSString*)placementID;

@end

NS_ASSUME_NONNULL_END
