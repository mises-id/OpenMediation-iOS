// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMUnit.h"
#import "OMEventManager.h"
#import "OMToolUmbrella.h"
@implementation OMUnit
- (instancetype)initWithUnitData:(NSDictionary*)unitData {
    if (self = [super init]) {
        _instanceMap = nil;
        _unitID = [NSString stringWithFormat:@"%@",[unitData objectForKey:@"id"]];
        [self updateWithUnitData:unitData];
    }
    return self;
}

- (void)updateWithUnitData:(NSDictionary*)unitData {
    _cachedInstanceMap = _instanceMap?[_instanceMap copy]:nil;
    _unitModel = unitData;
    _name = OM_SAFE_STRING([unitData objectForKey:@"n"]);
    _adFormat = (1<<[[unitData objectForKey:@"t"]integerValue]);
    _main = [[unitData objectForKey:@"main"]integerValue];
    _frequencryCap = [[unitData objectForKey:@"fc"]integerValue];
    _frequencryUnit = [[unitData objectForKey:@"fu"]integerValue];
    _frequencryInterval = [[unitData objectForKey:@"fi"]integerValue];
    _batchSize = [[unitData objectForKey:@"bs"]integerValue];
    _batchTimeout = [[unitData objectForKey:@"pt"]integerValue];
    _fanout = [[unitData objectForKey:@"fo"]boolValue];
    _cacheCount = [[unitData objectForKey:@"cs"]integerValue];
    _waterfallReloadTime = [[unitData objectForKey:@"rlw"]integerValue];
    _hb = [[unitData objectForKey:@"hb"] integerValue];
    _instanceList = [NSMutableArray array];
    _hbInstances = [NSMutableArray array];
    _instanceMap = [NSMutableDictionary dictionary];
    NSArray *instances = [unitData objectForKey:@"ins"];
    if (instances && [instances isKindOfClass:[NSArray class]] && [instances count]>0 ) {
        for (NSDictionary *instanceData in instances) {
            NSString *instanceID = [NSString stringWithFormat:@"%@",[instanceData objectForKey:@"id"]];
            OMInstance *instance = _cachedInstanceMap?[_cachedInstanceMap objectForKey:instanceID]:nil;
            if (!instance) {
                instance = [[OMInstance alloc]initWithUnitID:_unitID instanceData:instanceData];
            } else {
                [instance updateWithInstanceData:instanceData];
            }
            [_instanceList addObject:instance];
            [_instanceMap setObject:instance forKey:instance.instanceID];
            if (instance.hb) {
                [_hbInstances addObject:instance.instanceID];
            }
        }
    }
    _sceneList = [NSMutableArray array];
    _sceneMapKeyId = [NSMutableDictionary dictionary];
    _sceneMapKeyName = [NSMutableDictionary dictionary];
    NSArray *scenes = [unitData objectForKey:@"scenes"];
    if (scenes && [scenes isKindOfClass:[NSArray class]] && [scenes count] > 0) {
        for (NSDictionary *sceneDic in scenes) {
            OMScene *scene = [[OMScene alloc] initWithUnitID:_unitID sceneData:sceneDic];
            [_sceneList addObject:scene];
            [_sceneMapKeyId setObject:scene forKey:scene.sceneID];
            [_sceneMapKeyName setObject:scene forKey:scene.sceneName];
            if (scene.defaultScene) {
                self.defaultScene = scene;
            }
        }
    }
    [self sortRefreshLevel:unitData[@"rfs"]];
}

- (void)sortRefreshLevel:(NSDictionary*)levelDict {
    self.refreshLevels = @[];
    self.refreshTimes = @[];
    
    if (levelDict && [levelDict isKindOfClass:[NSDictionary class]]) {
        NSArray *refreshLevels = [levelDict allKeys];
        refreshLevels = [refreshLevels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 integerValue] < [obj2 integerValue])
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }];
        
        NSMutableArray *refreshTimes = [NSMutableArray array];
        for (id level in refreshLevels) {
            [refreshTimes addObject:[levelDict objectForKey:level]];
        }
        self.refreshLevels = refreshLevels;
        self.refreshTimes = refreshTimes;
    }

}

- (OMScene*)getSceneById:(NSString*)sceneID {
    OMScene *scene = nil;
    if (!OM_STR_EMPTY(sceneID) && [_sceneMapKeyId objectForKey:sceneID]) {
        scene = [_sceneMapKeyId objectForKey:sceneID];
    }
    return scene;
}
- (OMScene*)getSceneByName:(NSString*)name {
    OMScene *scene = nil;
    if (!OM_STR_EMPTY(name) && [_sceneMapKeyName objectForKey:name]) {
        scene = [_sceneMapKeyName objectForKey:name];
    } else {
        if (_defaultScene) {
            scene = _defaultScene;
        } else {
            OMLogD(@"ad unit %@ no default scene", _unitID);
        }
        [[OMEventManager sharedInstance]addEvent:SCENE_NOT_FOUND extraData:@{@"pid":_unitID,@"msg":OM_SAFE_STRING(name)}];
    }
    return scene;
}
- (NSDictionary*)modelData {
    NSDictionary *model = [NSDictionary dictionary];
    if (_unitModel && [_unitModel isKindOfClass:[NSDictionary class]]) {
        model = _unitModel;
    }
    return model;
}

@end
