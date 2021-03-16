//
//  VHallQAndA.h
//  VHallSDK
//
//  Created by Ming on 16/8/23.
//  Copyright © 2016年 vhall. All rights reserved.
//
// 问答
// !!!!:注意实例方法使用时机，看直播/回放————>在收到"播放连接成功回调"或"视频信息预加载成功回调"以后使用。

#import <Foundation/Foundation.h>
#import "VHallBasePlugin.h"

@class VHallQAndA;
@class VHallQAModel;

@protocol VHallQAndADelegate <NSObject>
@optional
//主播开启问答
- (void)vhallQAndADidOpened:(VHallQAndA *)QA;
//主播关闭问答
- (void)vhallQAndADidClosed:(VHallQAndA *)QA;
//问答消息
- (void)reciveQAMsg:(NSArray <VHallQAModel *> *)msgs;

@end

@interface VHallQAndA : VHallBasePlugin

@property (nonatomic, weak) id <VHallQAndADelegate> delegate;

//问答是否开启
@property (nonatomic, assign, readonly) BOOL isOpen;


/// 发送提问 （在收到播放器"播放连接成功回调"或"视频信息预加载成功回调"以后使用）
/// @param msg 提问内容
/// @param success 成功回调
/// @param reslutFailedCallback 失败回调，参数字典结构：{code：错误码，content：错误信息}
- (void)sendMsg:(NSString *)msg success:(void(^)(void))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;


/// 获取问答历史记录 （在收到播放器"播放连接成功回调"或"视频信息预加载成功回调"以后使用）
/// @param showAll 保留字段（暂时无用）
/// @param success 成功回调
/// @param reslutFailedCallback 失败回调，参数字典结构：{code：错误码，content：错误信息}
- (void)getQAndAHistoryWithType:(BOOL)showAll success:(void(^)(NSArray <VHallQAModel *>* msgs))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;
@end
