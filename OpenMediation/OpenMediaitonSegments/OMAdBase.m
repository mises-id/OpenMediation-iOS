// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMAdBase.h"
#import "OMAdBasePrivate.h"
#import "OMConfig.h"
#import "OMToolUmbrella.h"
#import "OMWaterfallRequest.h"
#import "OMInstanceContainer.h"
#import "OMUnit.h"
#import "OMNetworkUmbrella.h"
#import "OMEventManager.h"
#import "OMMediations.h"
#import "OMLrRequest.h"
#import "OMEventManager.h"
#import "OpenMediation.h"
#import "OMBidding.h"

@protocol OMBiddingCustomEvent<NSObject>
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
@end

#define OMDefaultMaxTimeoutMS     5000

#define OMBiddingTest   YES //for bid

@implementation OMAdBase

- (instancetype)initWithPlacementID:(NSString*)placementID size:(CGSize)size {
    return [self initWithPlacementID:placementID size:size rootViewController:nil];
}

- (instancetype)initWithPlacementID:(NSString*)placementID size:(CGSize)size rootViewController:(UIViewController*)rootViewController {
    if (self = [super init]) {
        _pid = OM_SAFE_STRING(placementID);
        _showSceneID = @"";
        _size = size;
        _rootViewController = rootViewController;
        self.instanceAdapters = [NSMutableDictionary dictionary];
        self.didLoadAdObjects = [NSMutableDictionary dictionary];
        self.bidLoadInstances = [NSMutableDictionary dictionary];
        self.bid = [[OMBidding alloc]init];
    }
    return self;
}

- (void)loadAd {
    
}

- (void)preload {
    
}


- (void)loadAd:(OpenMediationAdFormat)adFormat actionType:(OMLoadAction)action {
    OMLogD(@"%@ loadAd action:%zd",self.pid,action);
    if (_loadAction != OMLoadActionManualLoad) {
        [self addEvent:((adFormat == OpenMediationAdFormatBanner)?REFRESH_INTERVAL:ATTEMPT_TO_BRING_NEW_FEED) instance:@"" extraData:nil];
    }

    if (_adLoader.loading) {
        OMLogD(@"%@ load block: loading",_pid);
        [self addEvent:LOAD_BLOCKED instance:nil extraData:@{@"msg":@"loading"}];
        return;
    }
    if (![[OMLoadFrequencryControl sharedInstance]allowLoadOnPlacement:_pid]) {
        OMLogD(@"%@ load block: frequency capped",_pid);
        [self addEvent:LOAD_BLOCKED instance:nil extraData:@{@"msg":@"frequency capped"}];
        [self sendDidFailWithErrorType:OMErrorLoadFrequencry];
        return;
    }
    
    [[OMDependTask sharedInstance]addTaskDependOjbect:[OMConfig sharedInstance] keyPath:@"initState" observeValues:@[@"2",@"0"] observeTask:^{
        if (![OMConfig sharedInstance].initSuccess) {
            OMLogD(@"%@ load block: sdk not initialized",self.pid);
            [self addEvent:LOAD_BLOCKED instance:nil extraData:@{@"msg":@"SDK not initialized"}];
            [self sendDidFailWithErrorType:OMErrorLoadInitFailed];
        } else if (![[OMConfig sharedInstance]configContainAdUnit:self.pid]) {
            OMLogD(@"%@ load block: placement not found",self.pid);
            [self addEvent:LOAD_BLOCKED instance:nil extraData:@{@"msg":[NSString stringWithFormat:@"placement not found"]}];
            [self sendDidFailWithErrorType:OMErrorLoadPlacementNotFound];
        } else if (![[OMConfig sharedInstance] isValidAdUnitId:self.pid forAdFormat:adFormat]) {
            OMLogD(@"%@ load block: Invalid placment for adformat = %zd",self.pid,adFormat);
            [self addEvent:LOAD_BLOCKED instance:nil extraData:@{@"msg":[NSString stringWithFormat:@"Invalid placment %@ for adformat = %zd",self.pid,adFormat]}];
            [self sendDidFailWithErrorType:OMErrorLoadPlacementAdTypeIncorrect];
        } else {
            if (!self.loadConfig) {
                self.loadConfig = YES;
                [self loadPlacementConfig];
            }
            [self loadAdWithAction:action];
        }
    } realTaskCheckValues:@[@"0"] realTask:^{
        [OpenMediation initWithAppKey:[OMConfig sharedInstance].appKey];
    }];
}


- (void)loadPlacementConfig {
    OMUnit *unit = [[OMConfig sharedInstance].adUnitMap objectForKey:_pid];
    Class loadClass = NSClassFromString(((unit.adFormat<OpenMediationAdFormatRewardedVideo || unit.adFormat == OpenMediationAdFormatSplash)?@"OMHybridLoad":@"OMSmartLoad"));
    if (loadClass && [loadClass instancesRespondToSelector:@selector(initWithPid:adFormat:)]) {
        self.adLoader = [[loadClass alloc]initWithPid:_pid adFormat:unit.adFormat];
        self.adLoader.delegate = self;
    }
    _adFormat = unit.adFormat;
}

- (void)loadAdWithAction:(OMLoadAction)action {
    
    self.callLoad = (action == OMLoadActionManualLoad);
    self.replenishLoad = !self.callLoad;
    if ((_adFormat == OpenMediationAdFormatInterstitial || _adFormat == OpenMediationAdFormatRewardedVideo) && [self isReady]) {
        [self notifyAvailable:YES];
    }
    [self.adLoader loadWithAction:action];
    
}

#pragma mark - bid

- (NSArray*)bidNetworkItmes:(NSArray*)intances {
    NSMutableArray *bidItems = [NSMutableArray array];
    OMConfig *config = [OMConfig sharedInstance];
    for (NSString *instanceID in intances) {
        OMInstance *bidInstance = [config getInstanceByinstanceID:[NSString stringWithFormat:@"%@",instanceID]];
        if (bidInstance) {
            id adapter = [_instanceAdapters objectForKey:bidInstance.instanceID];
            if (!(adapter && [adapter respondsToSelector:@selector(isReady)] && [adapter isReady] )) {
                NSString *adnName = [config.adnNameMap objectForKey:@(bidInstance.adnID)];
                NSString *appKey = [config.adnAppkeyMap objectForKey:@(bidInstance.adnID)];
                OMBiddingNetworkItem *bidNetworkItem = [OMBiddingNetworkItem networkItemWithName:adnName appKey:appKey placementID:bidInstance.adnPlacementID timeOut:((bidInstance.hbt<1000)?OMDefaultMaxTimeoutMS:bidInstance.hbt) test:OMBiddingTest extra:@{@"instanceID":bidInstance.instanceID}];
                [bidItems addObject:bidNetworkItem];
                [self addEvent:INSTANCE_BID_REQUEST instance:bidInstance.instanceID extraData:nil];
            }
        }
    }
    return [bidItems copy];
}

- (void)getBidResponses:(OMLoadAction)action completionHandler:(void(^)(NSArray *,NSDictionary *))completionHandler {
    __block NSMutableArray *tokens = [NSMutableArray array];
    __block NSMutableDictionary *bidSuccessResponses = [NSMutableDictionary dictionary];
    
    OMUnit *unit = [[OMConfig sharedInstance].adUnitMap objectForKey:_pid];
    if (unit) {
        NSMutableArray *bidRequestInstances = [NSMutableArray array];
        for (NSString *instanceID in unit.hbInstances) {
            if ( (unit.adFormat == OpenMediationAdFormatRewardedVideo || unit.adFormat == OpenMediationAdFormatInterstitial) && [self.bidLoadInstances objectForKey:instanceID]) {
                [bidSuccessResponses setObject:[self.bidLoadInstances objectForKey:instanceID] forKey:instanceID];
            } else {
                [bidRequestInstances addObject:instanceID];
            }
        }
        [self.bid bidWithNetworkItems:[self bidNetworkItmes:bidRequestInstances] adFormat:self.adFormat completionHandler:^(NSDictionary * _Nonnull bidTokens, NSDictionary * _Nonnull bidResponses) {
            //for s2s
            NSArray *allS2sIns = [bidTokens allKeys];
            for (NSString *instanceID in allS2sIns) {
                NSDictionary *bidData = @{@"iid":instanceID,@"token":[bidTokens objectForKey:instanceID]};
                [tokens addObject:bidData];
            }
            
            [bidSuccessResponses addEntriesFromDictionary:bidResponses];

            NSArray *allBidIns = [bidResponses allKeys];
            for (NSString *instanceID in allBidIns) {
                OMBiddingResponse *bidResponse = [bidResponses objectForKey:instanceID];
                if (bidResponse.isSuccess) {
                    [self addEvent:INSTANCE_BID_RESPONSE instance:instanceID extraData:@{@"bid":[NSNumber numberWithInt:1],@"price":[NSNumber numberWithDouble:bidResponse.price],@"cur":bidResponse.currency}];
                    OMLogD(@"instance %@ bid response price %lf cur %@",instanceID,bidResponse.price,bidResponse.currency);
                } else {
                    OMLogD(@"instance %@ bid failed",instanceID);
                    [self addEvent:INSTANCE_BID_FAILED instance:instanceID extraData:@{@"msg":OM_SAFE_STRING(bidResponse.errorMsg)}];
                    [bidSuccessResponses removeObjectForKey:instanceID];
                }
            }
            completionHandler(tokens,bidSuccessResponses);
        }];

        
        
    } else {
        completionHandler(tokens,bidSuccessResponses);
    }
    
}

- (void)notifyLossBid {
    NSMutableArray *bidInstances = [NSMutableArray arrayWithArray:[_bidInstances allKeys]];
    NSArray *loadInstances = [_bidLoadInstances allKeys];
    [bidInstances removeObjectsInArray:loadInstances];
    
    for (NSString *instanceID in bidInstances) {
        OMBiddingResponse *bidResponse = [_bidInstances objectForKey:instanceID];
        [bidResponse notifyLossWithReasonCode:OMBiddingLossedReasonCodeNotHiggestBidder];
        [self.bidLoadInstances removeObjectForKey:instanceID];
        OMLogD(@"%@ bid loss %zd",instanceID,OMBiddingLossedReasonCodeNotHiggestBidder);
        [self addEvent:INSTANCE_BID_LOSE instance:instanceID extraData:nil];
    }
}



#pragma mark - OMLoadDelegate

- (void)omLoadReqeustWithAction:(OMLoadAction)action {
    if (action == OMLoadActionTimer) {
        self.replenishLoad = YES;
    }
    [self getBidResponses:action completionHandler:^(NSArray * _Nonnull tokens,NSDictionary * _Nonnull bidResponses) {
        
        self.bidInstances = [bidResponses copy];
        if (self.testInstance && self.testInstance.count>0) {
            [self.adLoader resetContext];
        }
        NSMutableArray *bids = [NSMutableArray array];
        
        for (NSString *instanceID in self.bidInstances) {
            OMBiddingResponse *bidResponse = [self.bidInstances objectForKey:instanceID];
            NSDictionary *bidData = @{@"iid":instanceID,@"price":[NSNumber numberWithFloat:bidResponse.price],@"cur":bidResponse.currency};
            [bids addObject:bidData];
        }

        OMLogD(@"%@ load request with action: %zd",self.pid,action);
        
        [OMLrRequest postWithType:OMLRTypeWaterfallLoad pid:self.pid adnID:0 instanceID:@"" action:self.loadAction scene:@"" abt:self.abTest bid:NO];//lr load
        
        [self addEvent:LOAD instance:nil extraData:nil];//load event
        
        
        [OMWaterfallRequest requestDataWithPid:self.pid size:self.size actionType:action bidResponses:bids tokens:tokens completionHandler:^(NSDictionary * _Nullable ins, NSError * _Nullable error) {
            if (!error) {
                self.abTest = [[ins objectForKey:@"abt"]boolValue];
                
                NSMutableDictionary *addBidResponse = [NSMutableDictionary dictionary];
                if ([ins objectForKey:@"bidresp"] && [[ins objectForKey:@"bidresp"]isKindOfClass:[NSArray class]] ) {
                    NSArray *responses = [ins objectForKey:@"bidresp"];
                   
                    for (NSDictionary *bidResponseData in responses) {
                        NSString *instanceID = [NSString stringWithFormat:@"%@",bidResponseData[@"iid"]];
                        if ([bidResponseData objectForKey:@"adm"]) {
                            OMBiddingResponse *response = [OMBiddingResponse buildResponseWithData:bidResponseData];
                            [addBidResponse setObject:response forKey:instanceID];
                            
                            OMLogD(@"instance %@ bid response price %lf cur %@",instanceID,response.price,response.currency);
                        } else {
                            NSString *error = [NSString stringWithFormat:@"error:%@,nbr:%@",OM_SAFE_STRING(bidResponseData[@"err"]),OM_SAFE_STRING(bidResponseData[@"nbr"])];
                            OMLogD(@"instance %@ bid failed %@",instanceID,error);
                            [self addEvent:INSTANCE_BID_FAILED instance:instanceID extraData:@{@"msg":error}];
                        }
                    }
                    NSMutableDictionary *newClBid = [NSMutableDictionary dictionaryWithDictionary:addBidResponse];
                    [newClBid addEntriesFromDictionary:self.bidInstances];
                    self.bidInstances = [newClBid copy];
                    
                }
                
                if ([ins objectForKey:@"ins"] && [[ins objectForKey:@"ins"]isKindOfClass:[NSArray class]]) {

                    NSArray *instancePriority = [ins objectForKey:@"ins"];
                    NSString *instancePriorityStr = [instancePriority componentsJoinedByString:@","];
                    OMLogD(@"%@ waterfall priority %@",self.pid,instancePriorityStr);
                    instancePriority = [[instancePriority componentsJoinedByString:@","]componentsSeparatedByString:@","];
                    
                    if (self.testInstance && self.testInstance.count>0) {
                        [self.adLoader loadWithPriority:self.testInstance];
                    } else {
                        [self.adLoader loadWithPriority:instancePriority];
                    }
                } else {
                    OMLogD(@"%@ waterfall request ins empty",self.pid);
                    [self.adLoader loadWithPriority:@[]];
                }

            } else {
                OMLogD(@"%@ waterfall request error:%@",self.pid,error);
                [self.adLoader loadWithPriority:@[]];
            }
        }];
    }];
}


- (void)omLoadInstance:(NSString*)instanceID {
    OMLogD(@"%@ loader load instance:%@",self.pid,instanceID);
    if (![[OMLoadFrequencryControl sharedInstance]allowLoadOnInstance:instanceID]) {
        [self instanceLoadBlockWithError:OMErrorLoadFrequencry instanceID:instanceID];
        return;
    }
    
    OMConfig *config = [OMConfig sharedInstance];
    OMAdNetwork adnID = [config getInstanceAdNetwork:instanceID];
    if (![[OMConfig sharedInstance]getInstanceByinstanceID:instanceID]) {
        OMLogD(@"%@ load instance %@ not found",self.pid,instanceID);
        [self addEvent:INSTANCE_NOT_FOUND instance:instanceID extraData:nil];
        [self instanceLoadBlockWithError:OMErrorLoadInstanceNotFound instanceID:instanceID];
    } else {
        if ([[config adnAppKey:adnID]length]>0 || adnID == OMAdNetworkMopub) {
            if (![[OMMediations sharedInstance]adnSDKInitialized:adnID]) {
                //mediation init
                [self addEvent:INSTANCE_INIT_START instance:instanceID extraData:nil];
                __weak __typeof(self) weakSelf = self;
                [[OMMediations sharedInstance]initAdNetworkSDKWithId:adnID
                                                   completionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        OMLogD(@"%@ %@ init success",self.pid,instanceID);
                        [self addEvent:INSTANCE_INIT_SUCCESS instance:instanceID extraData:nil];
                        [weakSelf loadInstance:instanceID];
                    } else {
                        //init failed
                        OMLogD(@"%@ %@ init failed: %@",self.pid,instanceID,error);
                        [self addEvent:INSTANCE_INIT_FAILED instance:instanceID extraData:@{@"msg":[error description]}];
                        [weakSelf instanceLoadBlockWithError:OMErrorLoadInitFailed instanceID:instanceID];
                    }
                }];
            } else {
                [self loadInstance:instanceID];
            }
        } else {
            //key empty;
            OMLogD(@"%@ %@ init failed: key empty",self.pid,instanceID);
            [self addEvent:INSTANCE_INIT_FAILED instance:instanceID extraData:@{@"msg":@"key empty"}];
            [self instanceLoadBlockWithError:OMErrorLoadInitFailed instanceID:instanceID];
        }
    }
}

- (void)loadInstance:(NSString*)instanceID {
    OMBiddingResponse *instanceBidResponse = [self.bidInstances objectForKey:instanceID];
    id adapter = [_instanceAdapters objectForKey:instanceID];
    OMAdNetwork adnID = [[OMConfig sharedInstance]getInstanceAdNetwork:instanceID];
    
    if (adapter && [adapter respondsToSelector:@selector(isReady)] && [adapter isReady]) {
        OMLogD(@"%@ load instance %@ ready true",self.pid,instanceID);
        if (instanceBidResponse && (adnID == OMAdNetworkChartboostBid)) {
            @synchronized (self) {
                [_bidLoadInstances setObject:instanceBidResponse forKey:instanceID];
            }
        }

        OMInstance *instance = [[OMConfig sharedInstance]getInstanceByinstanceID:instanceID];
        if (!instance.hb) {
            [self addEvent:INSTANCE_LOAD instance:instanceID extraData:nil];
            [OMLrRequest postWithType:OMLRTypeInstanceLoad pid:self.pid adnID:adnID instanceID:instanceID action:_loadAction scene:@"" abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];//lr load;
            [self addEvent:INSTANCE_LOAD_SUCCESS instance:instanceID extraData:nil];
            [OMLrRequest postWithType:OMLRTypeInstanceReady pid:self.pid adnID:adnID instanceID:instanceID action:_loadAction scene:@"" abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];//lr ready;
        }
        [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateSuccess];
    } else if (instanceBidResponse && adapter && [adapter respondsToSelector:@selector(loadAdWithBidPayload:)]) {
        OMLogD(@"%@ load instance %@ with bid payload",self.pid,instanceID);
           @synchronized (self) {
               [_bidLoadInstances setObject:instanceBidResponse forKey:instanceID];
           }
        [self addEvent:INSTANCE_PAYLOAD_REQUEST instance:instanceID extraData:nil];
        [adapter loadAdWithBidPayload:(NSString*)instanceBidResponse.payLoad];
    } else if (adapter && [adapter respondsToSelector:@selector(loadAd)]) {

        OMLogD(@"%@ load instance %@ adapter call load",self.pid,instanceID);
        [OMLrRequest postWithType:OMLRTypeInstanceLoad pid:self.pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:_loadAction scene:@"" abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];//lr instance load;
        [self addEvent:INSTANCE_LOAD instance:instanceID extraData:nil];
        [adapter loadAd];
    }
}

- (void)omLoadInstanceTimeout:(NSString *)instanceID {
    OMLogD(@"%@ load instance %@ timeout",self.pid,instanceID);
    [self addEvent:INSTANCE_LOAD_TIMEOUT instance:instanceID extraData:nil];
}

- (void)instanceLoadBlockWithError:(OMErrorCode)errorType instanceID:(NSString*)instanceID {
    OMLogD(@"%@ load instance %@ block:%zd",self.pid,instanceID,errorType);
    [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateFail];
}


- (void)omLoadFill:(NSString*)instanceID {
    OMLogD(@"%@ loader fill %@",self.pid,instanceID)
    
    [OMLrRequest postWithType:OMLRTypeWaterfallReady pid:self.pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:_loadAction scene:@"" abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];//lr ready
    
    
    if ((_adFormat < OpenMediationAdFormatRewardedVideo) || (_adFormat == OpenMediationAdFormatSplash)) {
        [self omDidLoad];
    } else {
        [self addEvent:AVAILABLE_FROM_CACHE instance:instanceID extraData:nil];
        [self notifyAvailable:YES];
    }
}

- (void)omLoadOptimalFill:(NSString*)instanceID {
    OMLogD(@"%@ Optimal fill instance %@",self.pid,instanceID);
    [self notifyAvailable:YES];
}

- (void)omLoadNoFill {
    [self addEvent:NO_MORE_OFFERS instance:nil extraData:nil];
    [self sendDidFailWithErrorType:OMErrorLoadWaterfallFail];
    [self notifyAvailable:NO];
}

- (void)omLoadEnd {
    [self notifyLossBid];
}


- (void)omLoadAddEvent:(NSInteger)eventID extraData:data {
    [self addEvent:eventID instance:nil extraData:data];
}

- (BOOL)omCheckInstanceReady:(NSString*)instanceID {
    BOOL instanceReady = NO;
    id adapter = [_instanceAdapters objectForKey:instanceID];
    if (adapter && [adapter respondsToSelector:@selector(isReady)]) {
        instanceReady = [adapter isReady];
    }
    if (!instanceReady) {
        [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateWait];//instance available state changed
        OMBiddingResponse *bidResponse = [self.bidLoadInstances objectForKey:instanceID];
        if (bidResponse) {
            [bidResponse notifyLossWithReasonCode:OMBiddingLossedReasonCodeNotShow];
            [self addEvent:INSTANCE_BID_LOSE instance:instanceID extraData:nil];
            OMLogD(@"%@ bid loss %zd",instanceID,OMBiddingLossedReasonCodeNotShow);
        }
        [self.bidLoadInstances removeObjectForKey:instanceID];
    }
    return instanceReady;
}

- (void)sendDidFailWithErrorType:(OMErrorCode)errorCode{
    NSError *error = [OMError omErrorWithCode:errorCode];
    NSError *developerError = [OMSDKError errorWithAdtError:error];
    [OMSDKError throwDeveloperError:developerError];
    _callLoad = NO;
    [self performSelector:@selector(omDidFail:) withObject:developerError afterDelay:0.5];
}

- (void)omDidLoad {
    
}

- (void)omDidFail:(NSError*)error {
    
}

- (void)notifyAvailable:(BOOL)avalible {
    if (self.replenishLoad) {
        [self addEvent:AVAILABLE_FROM_CACHE instance:_adLoader.optimalFillInstance extraData:nil];
        self.replenishLoad = NO;
    }
    if ((_callLoad || (_adAvailable != avalible)) && (!_adLoader.adShow ||!avalible)) {
        [self omDidChangedAvailable:avalible];
        OMLogD(@"notify %@ available change %zd",self.pid,(NSInteger)avalible);
        _callLoad = NO;
        _adAvailable =  avalible;
    }
}

- (void)omDidChangedAvailable:(BOOL)available {
    OMLogD(@"%@ change available:%zd",self.pid,(NSInteger)available);
}

#pragma mark - isReady

- (BOOL)isReady {
    BOOL isReady = NO;
    if (_adLoader && [_adLoader isReady] && !_adLoader.adShow) {
        isReady = YES;
    }
    return isReady;
}



#pragma mark - OMCustomEventDelegate


- (void)customEvent:(id)instanceAdapter didLoadAd:(id)didLoadAd {
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    if (instanceID) {
        OMLogD(@"%@ instance %@ load success",self.pid,instanceID);
        OMInstance *instance = [[OMConfig sharedInstance]getInstanceByinstanceID:instanceID];
        if (instance.hb) {
            [self addEvent:INSTANCE_PAYLOAD_SUCCESS instance:instanceID extraData:nil];
        } else {
            [OMLrRequest postWithType:OMLRTypeInstanceReady pid:self.pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:_loadAction scene:@"" abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];//lr ready
            
            [self addEvent:INSTANCE_LOAD_SUCCESS instance:instanceID extraData:nil];
        }
        
        if (didLoadAd) {
            [_didLoadAdObjects setObject:didLoadAd forKey:instanceID];
        }
        [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateSuccess];
    }
}

- (void)customEvent:(id)adapter didFailToLoadWithError:(NSError*)error {
    NSString *instanceID = [self checkInstanceIDWithAdapter:adapter];
    if (instanceID) {
        OMBiddingResponse *bidResponse = [self.bidLoadInstances objectForKey:instanceID];
        if (bidResponse) {
            [bidResponse notifyLossWithReasonCode:OMBiddingLossedReasonCodeInternalError];
            [self addEvent:INSTANCE_BID_LOSE instance:instanceID extraData:nil];
            OMLogD(@"%@ bid loss %zd",instanceID,OMBiddingLossedReasonCodeInternalError);
        }
        [self.bidLoadInstances removeObjectForKey:instanceID];
        NSString *errorMsg = [error isKindOfClass:[NSError class]]?[error description]:@"";
        OMLogD(@"%@ instance %@ load fail error %@",self.pid,instanceID,errorMsg);
        
        OMInstance *instance = [[OMConfig sharedInstance]getInstanceByinstanceID:instanceID];
        [self addEvent:(instance.hb?INSTANCE_PAYLOAD_FAIL:INSTANCE_LOAD_ERROR) instance:instanceID extraData:@{@"msg":OM_SAFE_STRING([error localizedDescription]),@"code":[NSString stringWithFormat:@"%zd",error.code]}];
        [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateFail];
    }
}



#pragma mark - show

- (void)showInstance:(id)instanceID {
    if (!OM_STR_EMPTY(instanceID)) {
        OMBiddingResponse *bidResponse = [self.bidLoadInstances objectForKey:instanceID];
        if (bidResponse) {
            [bidResponse win];
            [self addEvent:INSTANCE_BID_WIN instance:instanceID extraData:nil];
            OMLogD(@"%@ %@ bid win notice",self.pid,instanceID);
        }
        [[OMInstanceContainer sharedInstance]removeImpressionInstance:instanceID];
        [self addEvent:INSTANCE_SHOW instance:instanceID extraData:nil];
    }
}

- (void)adshow:(id)instanceAdapter {
    self.adLoader.adShow = YES;
    [self notifyAvailable:NO];
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    OMLogD(@"%@ instance %@ show",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_SHOW_SUCCESS instance:instanceID extraData:nil];
    [OMLrRequest postWithType:OMLRTypeInstanceImpression pid:_pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:0 scene:self.showSceneID abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];
    
    
    [[OMLoadFrequencryControl sharedInstance]recordImprOnPlacement:_pid sceneID:self.showSceneID];
    [[OMLoadFrequencryControl sharedInstance]recordImprOnInstance:OM_SAFE_STRING(instanceID)];
}

- (void)adShowFail:(id)instanceAdapter {
    self.adLoader.adShow = NO;
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    OMLogD(@"%@ instance %@ show fail",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_SHOW_FAILED instance:instanceID extraData:nil];
    [_adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateWait];
    [self loadAd:_adFormat actionType:OMLoadActionCloseEvent];
}

- (void)adClick:(id)instanceAdapter {
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    OMLogD(@"%@ instance %@ click",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_CLICKED instance:instanceID extraData:nil];
    [OMLrRequest postWithType:OMLRTypeInstanceClick pid:_pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:0 scene:self.showSceneID abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];
    
    
    
}

- (void)adVideoStart:(id)instanceAdapter {
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    OMLogD(@"%@ instance %@ video start",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_VIDEO_START instance:instanceID extraData:nil];
    [OMLrRequest postWithType:OMLRTypeVideoStart pid:_pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:0 scene:self.showSceneID abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];
}

- (void)adVideoComplete:(id)instanceAdapter {
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    
    OMLogD(@"%@ instance %@ video start",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_VIDEO_COMPLETED instance:instanceID extraData:nil];
    [OMLrRequest postWithType:OMLRTypeVideoComplete pid:_pid adnID:[[OMConfig sharedInstance]getInstanceAdNetwork:instanceID] instanceID:instanceID action:0 scene:self.showSceneID abt:self.abTest bid:[[OMConfig sharedInstance]isHBInstance:instanceID]];
}

- (void)adClose:(id)instanceAdapter {
    self.adLoader.adShow = NO;
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    OMLogD(@"%@ instance %@ close",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_CLOSED instance:instanceID extraData:nil];
    [self.bidLoadInstances removeObjectForKey:instanceID];
    [self.adLoader saveInstanceLoadState:instanceID state:OMInstanceLoadStateWait];
    if (_adFormat != OpenMediationAdFormatSplash) {
        [self loadAd:_adFormat actionType:OMLoadActionCloseEvent];
    }
}

- (void)adReceiveReward:(id)instanceAdapter {
    NSString *instanceID = [self checkInstanceIDWithAdapter:instanceAdapter];
    
    OMLogD(@"%@ instance %@ receive reward",self.pid,OM_SAFE_STRING(instanceID));
    [self addEvent:INSTANCE_VIDEO_REWARDED instance:instanceID extraData:nil];
}


- (NSString*)checkInstanceIDWithAdapter:(id)adapter {
    NSString *adapterInstanceID = @"";
    NSArray *instanceIDs = [_instanceAdapters allKeys];
    for (NSString *instanceID in instanceIDs) {
        id instanceAdapter = [_instanceAdapters objectForKey:instanceID];
        if (adapter == instanceAdapter) {
            adapterInstanceID = instanceID;
            break;
        }
    }
    return adapterInstanceID;
}


- (void)dealloc{
    [self addEvent:DESTROY instance:nil extraData:nil];
}



#pragma mark - addEvent

- (void)addEvent:(NSInteger)eventID instance:(NSString*)instanceID extraData:data {
    
    NSMutableDictionary *wrapperData = [NSMutableDictionary dictionary];
    if (data) {
        [wrapperData addEntriesFromDictionary:data];
    }
    OMConfig *config = [OMConfig sharedInstance];
    [wrapperData setObject:[NSNumber omStr2Number:_pid] forKey:@"pid"];
    if (self.abTest) {
        [wrapperData setObject:[NSNumber numberWithInteger:self.abTest] forKey:@"abt"];
    }
    if (!OM_STR_EMPTY(instanceID)) {
        OMAdNetwork adnID = [config getInstanceAdNetwork:instanceID];
        [wrapperData setObject:[NSNumber omStr2Number:instanceID] forKey:@"iid"];
        [wrapperData setObject:[NSNumber numberWithInteger:adnID] forKey:@"mid"];
        if([self.bidLoadInstances objectForKey:instanceID]){
            OMBiddingResponse *bidResponse = [self.bidLoadInstances objectForKey:instanceID];
            if(bidResponse){
                [wrapperData setObject:[NSNumber numberWithInt:1] forKey:@"bid"];
                [wrapperData setObject:[NSNumber numberWithDouble:bidResponse.price] forKey:@"price"];
                [wrapperData setObject:bidResponse.currency forKey:@"cur"];
            }
        }
        if ([_adLoader.priorityList containsObject:instanceID]) {
            [wrapperData setObject:[NSNumber numberWithInteger:[_adLoader.priorityList indexOfObject:instanceID]] forKey:@"priority"];
        }else {
            OMLogD(@"instance %@ not in priorityList %@",instanceID,[_adLoader.priorityList componentsJoinedByString:@","])
        }
        
        [wrapperData setObject:[NSNumber numberWithInteger:_adLoader.cacheCount] forKey:@"cs"];
        NSDictionary *adNetworkInfo = [[[OMMediations sharedInstance]adNetworkInfo]objectForKey:@(adnID)];
        if (adNetworkInfo) {
            [wrapperData addEntriesFromDictionary:adNetworkInfo];
        }
    }
    
    [[OMEventManager sharedInstance] addEvent:eventID extraData:wrapperData];
}

#pragma mark - test

-(void)testI:(NSArray *)instanceIDArray {
    if (!instanceIDArray) {
        return;
    } else {
        self.testInstance = instanceIDArray;
    }
}



@end
