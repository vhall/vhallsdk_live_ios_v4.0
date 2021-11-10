//
//  VHInteractLiveVC_New.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHInteractLiveBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface VHInteractLiveVC_New : VHInteractLiveBaseVC

@property (nonatomic, assign) NSInteger inav_num;     ///<当前活动支持的最大连麦人数，如：6代表1v5，16代表1v15...

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithParams:(NSDictionary *)params isHost:(BOOL)isHost screenLandscape:(BOOL)screenLandscape;

@end

NS_ASSUME_NONNULL_END
