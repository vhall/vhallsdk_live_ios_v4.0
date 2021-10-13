//
//  VHRoomBroadCastConfig.h
//  VHallInteractive
//
//  Created by xiongchao on 2021/9/14.
//  Copyright © 2021 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VHInteractive/VHRoomEnum.h>
NS_ASSUME_NONNULL_BEGIN


//旁路配置
@interface VHRoomBroadCastConfig : NSObject

/// 设置旁路布局，默认主次平铺，自动布局（VHBroadcastLayout_ADAPTIVE_TILED_MODE）
@property (nonatomic, assign) VHBroadcastLayout broadcastLayout;
/// 是否显示占位小人图标，默认NO，不显示
@property (nonatomic, assign) BOOL precast_pic_exist;
/// 旁路直播视频质量参数（分辨率+帧率+码率），默认 VHBroadcastProfileMode_720P_1 (即，宽高比：16:9 分辨率：1280x720 帧率：25  码率：1600)
@property (nonatomic, assign) VHBroadcastProfileMode profileMode;

@end

NS_ASSUME_NONNULL_END
