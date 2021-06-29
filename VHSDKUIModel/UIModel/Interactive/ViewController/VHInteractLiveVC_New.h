//
//  VHInteractLiveVC_New.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBroadcastBaseVC.h"

NS_ASSUME_NONNULL_BEGIN
@class VHRoom;
@interface VHInteractLiveVC_New : VHLiveBroadcastBaseVC

/** 互动SDK */
@property (nonatomic, strong) VHRoom *inavRoom;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithParams:(NSDictionary *)params isHost:(BOOL)isHost screenLandscape:(BOOL)screenLandscape;

@end

NS_ASSUME_NONNULL_END
