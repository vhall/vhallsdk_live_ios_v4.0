//
//  VHallBasePlugin.h
//  VHallSDK
//
//  Created by vhall on 2017/7/25.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHallLivePublish.h"
#import "VHallMoviePlayer.h"

@class VHallActivityModel;

@interface VHallBasePlugin : NSObject

/**
 * 活动Model 活动正常开始后 才会有值
 */
@property (nonatomic,weak) VHallActivityModel *activityModel;

/**
 * 开始活动通知
 */
- (void)startActivity:(NSNotification *)notify;

/**
 * 初始化功能模块
 * livePublish 发起端实例
 */
- (instancetype)initWithLivePublish:(VHallLivePublish *)livePublish __deprecated_msg("Use initWithObject: instead");

/**
 * 初始化功能模块
 * moviePlayer 观看端实例
 */
- (instancetype)initWithMoviePlayer:(VHallMoviePlayer *)moviePlayer __deprecated_msg("Use initWithObject: instead");

/**
 * 初始化功能模块 通用方法
 * object 发起VHallLivePublish实例、观看VHallMoviePlayer实例、互动VHRoom实例
 */
- (instancetype)initWithObject:(NSObject *)object;

@end
