//
//  VHallSign.h
//  VHallSDK
//
//  Created by vhall on 17/2/14.
//  Copyright © 2017年 vhall. All rights reserved.
//
// 签到
// !!!!:注意实例方法使用时机，看直播/回放————>在收到"播放连接成功回调"或"视频信息预加载成功回调"以后使用。
#import <Foundation/Foundation.h>
#import "VHallBasePlugin.h"

@protocol VHallSignDelegate <NSObject>

/// 收到主持人发起签到消息
- (void)startSign;

@optional

/// 距签到结束剩余时间，每秒会回调一次
/// @param remainingTime 剩余倒计时
- (void)signRemainingTime:(NSTimeInterval)remainingTime;

/// 签到结束 （签到剩余倒计时结束后回调）
- (void)stopSign;

@end

@interface VHallSign : VHallBasePlugin

@property (nonatomic, copy) NSString *title;     ///<签到标题 (主持人设置发起签到设置的标题，默认为"主持人发起了签到")

@property (nonatomic, weak) id <VHallSignDelegate> delegate;

/// 观众确定签到
/// @param isStop isStop 成功后是否结束倒计时 YES：结束(则不执行签到结束的回调) NO：不结束（会收到签到结束的回调）
/// @param success 成功回调成功Block
/// @param reslutFailedCallback 失败回调失败Block 字典结构：{code：错误码，content：错误信息}
- (BOOL)signSuccessIsStop:(BOOL)isStop success:(void(^)(void))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;

/// 观众取消签到
- (void)cancelSign;
@end
