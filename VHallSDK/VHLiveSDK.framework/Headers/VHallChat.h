//
//  VHallChat.h
//  VHallSDK
//
//  Created by Ming on 16/8/23.
//  Copyright © 2016年 vhall. All rights reserved.
//
//聊天
// !!!!:注意实例方法使用时机，发直播————>在收到"直播连接成功回调"以后使用；看直播/回放————>在收到"播放连接成功回调"或"视频信息预加载成功回调"以后使用。

#import <Foundation/Foundation.h>
#import "VHallBasePlugin.h"
@class VHallChatModel;
@class VHallOnlineStateModel;
@class VHallCustomMsgModel;

@protocol VHallChatDelegate <NSObject>
@optional
/**
 * 收到上下线消息
 */
- (void)reciveOnlineMsg:(NSArray <VHallOnlineStateModel *> *)msgs;
/**
 * 收到聊天消息
 */
- (void)reciveChatMsg:(NSArray <VHallChatModel *> *)msgs;
/**
 * 收到自定义消息
 */
- (void)reciveCustomMsg:(NSArray <VHallCustomMsgModel *> *)msgs;

/**
 * 收到自己被禁言/取消禁言
 */
- (void)forbidChat:(BOOL)forbidChat;

/**
 * 收到全体禁言/取消全体禁言
 */
- (void)allForbidChat:(BOOL)allForbidChat;

@end

@interface VHallChat : VHallBasePlugin

@property (nonatomic, weak) id <VHallChatDelegate> delegate;

/**
 * 是否被禁言（YES：自己被禁言或全体被禁言，NO：自己未被禁言且全体未被禁言）
 */
@property (nonatomic, assign ,readonly) BOOL isSpeakBlocked;

/**
 * 是否全体被禁言
 */
@property (nonatomic, assign ,readonly) BOOL isAllSpeakBlocked;

/**
 * 发送聊天内容
 * 成功回调成功Block
 * 失败回调失败Block 字典结构：{code：错误码，content：错误信息}
 *
 */
- (void)sendMsg:(NSString *)msg success:(void(^)(void))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;


/**
 * 获取20条聊天历史记录，返回至多20条数据，最新消息在数组最后一位
 * @param showAll               NO 只获取本次直播产生的聊天记录，YES 获取包含以前开播产生的聊天记录 （H5活动该参数无效，默认YES）
 * @param success               成功回调成功Block 返回聊天历史记录
 * @param reslutFailedCallback  失败回调失败Block 字典结构：{code：错误码，content：错误信息}
 *
 */
- (void)getHistoryWithType:(BOOL)showAll success:(void(^)(NSArray <VHallChatModel *> * msgs))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;


/**
 * 分页获取聊天历史记录，最新消息在数组最后一位（仅支持H5活动，Flash活动若使用该方法效果同上：getHistoryWithType:YES） (v5.0新增)
 * @param startTime             查询该时间至今的所有聊天记录，若不指定时间可传nil。格式如：@"2020-01-01 12:00:00"
 * @param pageNum               当前页码数，第一页从1开始
 * @param pageSize              每页的数据个数
 * @param success               成功回调成功Block msgs：聊天历史记录 endPage：是否为最后一页
 * @param reslutFailedCallback  失败回调失败Block  字典结构：{code：错误码，content：错误信息}
 *
 */

- (void)getHistoryWithStartTime:(NSString *)startTime pageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize success:(void(^)(NSArray <VHallChatModel *> * msgs))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;

/**
 * 发送自定义消息
 * 成功回调成功Block
 * 失败回调失败Block 字典结构：{code：错误码，content：错误信息}
 *
 */
- (void)sendCustomMsg:(NSString *)jsonStr success:(void(^)(void))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;
@end
