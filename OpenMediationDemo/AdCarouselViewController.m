// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "AdCarouselViewController.h"
#import "OMEventManager.h"
#import "OMNative.h"
#import "OMAdSingletonInterfacePrivate.h"

@implementation AdCarouselViewController

- (void)viewDidLoad {
    self.title = @"AdCarousel";
    self.adFormat = OpenMediationAdFormatNative;
    
    // 初始化广告视图数组
    self.adViews = [NSMutableArray array];
    self.ads = [NSMutableArray array];
    
    
    int banner_width = self.view.bounds.size.width;
    int banner_height = banner_width * 560 / 1200;
    // 初始化 UIScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height - banner_height - 40, banner_width, banner_height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    //self.scrollView.backgroundColor = [UIColor greenColor];
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    // 初始化 UIPageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 20 - 20, self.view.bounds.size.width, 20)];
    [self.view addSubview:self.pageControl];
    self.pageControl.backgroundColor = [UIColor blueColor];
    
    [super viewDidLoad];
}

- (void)loadAd {
    NSArray* ids = [OpenMediation cachedPlacementIds:@"carousel"];
    [[OMNativeManager sharedInstance]addDelegate:self];
    for (NSString* pid in ids) {
        [[OMCrossPromotion sharedInstance] addAdEvent:CALLED_LOAD placementID:pid scene:nil extraMsg:nil];
        [[OMNativeManager sharedInstance]loadWithPlacementID:pid];
    }
    
}


-(void)showItemAction {
    [super showItemAction];
    for (NSArray* adinfo in self.ads) {
        OMNativeView* view = [self genNativeView];
        view.nativeAd = adinfo[1];
        OMNative *native = adinfo[0];
        
        [[OMCrossPromotion sharedInstance] addAdEvent:CALLED_SHOW placementID:[native placementID] scene:nil extraMsg:nil];
        
        [self.adViews addObject:view];
    }
    
    [self updateScrollView];
    [self resetTimer];
    
}

-(void)removeItemAction {
    [super removeItemAction];
    [self.ads removeAllObjects];
    [self.adViews removeAllObjects];
    [self updateScrollView];
    [self clearTimer];
}

- (OMNativeView*)genNativeView {
    CGSize scrollViewSize = self.scrollView.bounds.size;
    OMNativeView* _nativeView = [[OMNativeView alloc]initWithFrame:CGRectZero];
    _nativeView.frame = CGRectMake(0,0, scrollViewSize.width, scrollViewSize.height);
    _nativeView.mediaView = [[OMNativeMediaView alloc]initWithFrame:CGRectZero];
    _nativeView.mediaView.frame = CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height);
    [_nativeView addSubview:_nativeView.mediaView];

    //    UIImageView* _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 255, 40, 40)];
    //    [_nativeView addSubview:_iconView];
    
    //    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 255, self.view.frame.size.width-100, 15)];
    //    _titleLabel.font = [UIFont systemFontOfSize:16];
    //    [_nativeView addSubview:_titleLabel];
    //
    //    UILabel *_bodyLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 270, self.view.frame.size.width-150, 30)];
    //    _bodyLabel.numberOfLines = 0;
    //    _bodyLabel.font = [UIFont systemFontOfSize:10];
    //    [_nativeView addSubview:_bodyLabel];
    
    //    UILabel *_action = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-80, 265, 60, 30)];
    //    _action.layer.cornerRadius = 3;
    //    _action.layer.masksToBounds = YES;
    //    _action.layer.borderColor = [UIColor blackColor].CGColor;
    //    _action.layer.borderWidth = 1;
    //    _action.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    //    _action.textAlignment = NSTextAlignmentCenter;
    //
    //    [_nativeView addSubview:_action];
    return _nativeView;
}


- (void)addAdView:(UIView *)adView {
    [self.adViews addObject:adView];
    [self updateScrollView];
}

- (void)removeAdView:(UIView *)adView {
    [self.adViews removeObject:adView];
    [self updateScrollView];
}

- (void)updateScrollView {
    // 移除所有子视图
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger adCount = self.adViews.count;
    if (adCount == 0) {
        self.scrollView.contentSize = CGSizeZero;
        self.pageControl.numberOfPages = 0;
        return;
    }
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    // 添加广告视图到 UIScrollView，包括重复部分
    for (int i = 0; i < adCount + 2; i++) {
        UIView *adView;
        if (i == 0) {
            adView = [self.adViews.lastObject snapshotViewAfterScreenUpdates:YES];
        } else if (i == adCount + 1) {
            adView = [self.adViews.firstObject snapshotViewAfterScreenUpdates:YES];
        } else {
            adView = self.adViews[i - 1];
        }
        adView.frame = CGRectMake(i * scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height);
        [self.scrollView addSubview:adView];
    }
    
    self.scrollView.contentSize = CGSizeMake((adCount + 2) * scrollViewSize.width, scrollViewSize.height);
    [self.scrollView setContentOffset:CGPointMake(scrollViewSize.width, 0) animated:NO];
    
    // 更新 UIPageControl
    self.pageControl.numberOfPages = adCount;
    self.pageControl.currentPage = 0;
}

- (void)nextAd {
    NSInteger page = self.pageControl.currentPage;
    page++;
    if (page >= self.adViews.count) {
        page = 0;
    }
    CGSize scrollViewSize = self.scrollView.bounds.size;
    [self.scrollView setContentOffset:CGPointMake((page + 1) * scrollViewSize.width, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger adCount = self.adViews.count;
    if (adCount == 0) {
        return;
    }
    CGSize scrollViewSize = self.scrollView.bounds.size;
    NSInteger page = scrollView.contentOffset.x / scrollViewSize.width - 1;
    if (scrollView.contentOffset.x == 0) {
        [scrollView setContentOffset:CGPointMake(adCount * scrollViewSize.width, 0) animated:NO];
        self.pageControl.currentPage = adCount - 1;
    } else if (scrollView.contentOffset.x == (adCount + 1) * scrollViewSize.width) {
        [scrollView setContentOffset:CGPointMake(scrollViewSize.width, 0) animated:NO];
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self clearTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetTimer];
}

- (void) clearTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void) resetTimer {
    [self clearTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(nextAd) userInfo:nil repeats:YES];
}

#pragma mark -- OMNativeDelegate

- (void)omNative:(OMNative*)native didLoad:(OMNativeAd*)nativeAd {
    [self.ads addObject:@[native, nativeAd]];

    self.showItem.enabled = YES;
    self.removeItem.enabled = YES;
    [self showLog:@"Native ad did load"];
   
}

- (void)omNative:(OMNative *)native didLoadAdView:(OMNativeAdView *)nativeAdView {
    self.showItem.enabled = YES;
    self.removeItem.enabled = YES;
    [self showLog:@"Native ad view did load"];
}

- (void)omNative:(OMNative*)native didFailWithError:(NSError*)error {
    [self showLog:@"Native ad load fail"];
}

- (void)omNative:(OMNative*)native nativeAdDidShow:(OMNativeAd*)nativeAd {
    [self showLog:@"Native ad impression"];
    
}

- (void)omNative:(OMNative*)native nativeAdDidClick:(OMNativeAd*)nativeAd {
    [self showLog:@"Native ad click"];
}


@end
