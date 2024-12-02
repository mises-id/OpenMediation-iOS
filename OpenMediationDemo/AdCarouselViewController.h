// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@import OpenMediation;
NS_ASSUME_NONNULL_BEGIN

@interface AdCarouselViewController : BaseViewController <OMNativeDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *adViews;
@property (nonatomic, strong) NSMutableArray *ads;
@property (nonatomic, strong, nullable) NSTimer *timer;

// - (void)addAdView:(UIView *)adView;
// - (void)removeAdView:(UIView *)adView;

@end

NS_ASSUME_NONNULL_END
