//
//  VHRoom.h
//  VHInteractive
//
//  Created by vhall on 2018/4/18.
//  Copyright © 2018年 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VHLiveSDK/VHDocument.h>
#import <VHLiveSDK/VHWebinarInfo.h>
#import <VHInteractive/VHRoomInfo.h>
#import <VHInteractive/VHLocalRenderView.h>
#import <VHInteractive/VHRoomEnum.h>
#import <VHInteractive/VHRoomBroadCastConfig.h>

@protocol   VHRoomDelegate;
@class      VHRenderView;
@class      VHRoomMember;

@interface VHRoom : NSObject

/// 获取互动SDK版本号
+(NSString *)sdkVersionEX;

/// 代理
@property (nonatomic, weak) id <VHRoomDelegate> delegate;
/// 当前房间状态
@property (nonatomic, assign, readonly) VHRoomStatus status;
/// 旁路布局配置
@property (nonatomic, strong) VHRoomBroadCastConfig *broadCastConfig;
/// 当前是否在推流中
@property (nonatomic, assign, readonly) BOOL isPublishing;

/// 当前推流cameraView，只在推流过程中存在
@property (nonatomic, weak, readonly) VHRenderView *cameraView;

/// 除自己以外房间内其他流id与视频view信息  (key:streamId value:视频VHRenderView)
@property (nonatomic, strong, readonly) NSDictionary *renderViewsById;

/// 除自己以外房间内其他流id列表
@property (nonatomic, strong, readonly) NSArray *streams;

/// 房间id
@property (nonatomic, copy, readonly) NSString *roomId;

/// 房间相关信息（进入房间成功后才有值）
@property (nonatomic, strong, readonly) VHRoomInfo *roomInfo;

/// 获取支持的推流视频分辨率列表，如：[480x360,640x480,960x540...]
+ (NSArray<NSString *> *)availableVideoResolutions;

/// 观众加入互动房间 (观众使用，注意必须先进行VHallMoviePlayer观看，参考demo使用)
/// @param roomId 房间id，同活动id
- (void)enterRoomWithRoomId:(NSString *)roomId;

/// 观众加入互动房间 (观众使用，注意必须先进行VHallMoviePlayer观看，参考demo使用）
/// @param params 参数
/// params[@"id"]    = 房间id，同活动id
/// params[@"pass"]  = 活动如果有K值或密码，则需要传
- (void)enterRoomWithParams:(NSDictionary *)params;

/// 开始推流
/// @param cameraView 需要推流的本地摄像头view
- (BOOL)publishWithCameraView:(VHLocalRenderView * )cameraView;

/// 下麦并停止推流
- (void)unpublish;

/// 离开房间
- (void)leaveRoom;


#pragma mark ------------------v6.1新增--------------------
/// 嘉宾加入互动房间 (嘉宾使用)
/// @param params 参数
/// params[@"id"]    = 房间id，同活动id（必传）
/// params[@"nickname"]  = 昵称（必传）
/// params[@"password"]  = 口令（必传）
/// params[@"avatar"]  = 头像url（可选）
- (void)guestEnterRoomWithParams:(NSDictionary *)params success:(void(^)(VHRoomInfo *))success fail:(void(^)(NSError *))fail;

/// 主持人进入互动房间，并发起互动直播，收到"房间连接成功回调"后可开始推流（主持人使用）
/// @param params 参数
/// params[@"id"]    = 房间id，同活动id
- (void)hostEnterRoomStartWithParams:(NSDictionary *)params success:(void(^)(VHRoomInfo *))success fail:(void(^)(NSError *))fail;

/// 设置是否开启观众举手申请上麦功能（主持人使用。若开启，则观众可举手申请上麦。）
/// @param status 1：开启 0：关闭
/// @param success 成功
/// @param fail 失败
- (void)setHandsUpStatus:(NSInteger)status success:(void(^)(NSDictionary *response))success fail:(void(^)(NSError *error))fail;

/// 邀请某个用户上麦 (主持人使用)
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)inviteWithTargetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 同意某个用户的上麦申请 (主持人使用)
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)agreeApplyWithTargetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 拒绝某个用户的上麦申请 (主持人使用)
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)rejectApplyWithTargetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 设置某个用户为主讲人 (主持人使用)
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)setMainSpeakerWithTargetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 下麦某个用户 (主持人使用)
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)downMicWithTargetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 禁言/取消禁言某个用户
/// @param status YES：禁言 NO：取消禁言
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)setBanned:(BOOL)status targetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 踢出/取消踢出某个用户
/// @param status YES：踢出 NO：取消踢出
/// @param userId 目标用户id
/// @param success 成功
/// @param fail 失败
- (void)setKickOut:(BOOL)status targetUserId:(NSString *)userId success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 申请上麦
/// @param success 成功
/// @param fail 失败
- (void)applySuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 取消申请上麦
/// @param success 成功
/// @param fail 失败
- (void)cancelApplySuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 拒绝主持人发来的上麦邀请
/// @param success 成功回调
/// @param fail 失败回调
- (void)rejectInviteSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 同意主持人发来的上麦邀请，成功回调中开启推流
/// @param success 成功回调
/// @param fail 失败回调
- (void)agreeInviteSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/// 获取在线成员列表
/// @param pageNum 页码，第一页从1开始
/// @param pageSize 每页条数
/// @param nickName 指定昵称（非必传参数，可传nil）
/// @param success 成功 haveNextPage：是否还有下一页
/// @param fail 失败
- (void)getOnlineUserListWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize nickName:(NSString *)nickName success:(void(^)(NSArray <VHRoomMember *> *list,BOOL haveNextPage))success fail:(void(^)(NSError *error))fail;

/// 获取受限成员列表 (包括：被踢出、被禁言的用户)
/// @param pageNum 页码，第一页从1开始
/// @param pageSize 每页条数
/// @param success 成功 haveNextPage：是否还有下一页
/// @param fail 失败
- (void)getLimitUserListWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize success:(void(^)(NSArray <VHRoomMember *> *list,BOOL haveNextPage))success fail:(void(^)(NSError *error))fail;

/// 获取房间文档列表
/// @param pageNum 页码，第一页从1开始
/// @param pageSize 每页条数
/// @param success 成功
/// @param fail 失败
- (void)getDocListWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize success:(void(^)(NSArray <VHRoomDocumentModel *> *list,BOOL haveNextPage))success fail:(void(^)(NSError *error))fail;
@end


/// 代理协议
@protocol VHRoomDelegate <NSObject>

/// 进入房间回调
/// @param room room实例
/// @param error 错误信息，如果error存在，则进入房间失败
- (void)room:(VHRoom *)room enterRoomWithError:(NSError *)error;

/// 房间连接成功回调
/// @param room room实例
/// @param roomMetadata 互动直播间数据 (可能为nil，暂时无用)
- (void)room:(VHRoom *)room didConnect:(NSDictionary *)roomMetadata;

/// 房间发生错误回调
/// @param room room实例
/// @param status 错误状态码
/// @param reason 错误描述
- (void)room:(VHRoom *)room didError:(VHRoomErrorStatus)status reason:(NSString *)reason;

/// 房间状态改变回调
/// @param room room实例
/// @param status 房间状态
- (void)room:(VHRoom *)room didChangeStatus:(VHRoomStatus)status;

/// 推流成功回调
/// @param room room实例
/// @param cameraView 当前推流 cameraView
- (void)room:(VHRoom *)room didPublish:(VHRenderView *)cameraView;

/// 停止推流回调
/// @param room room实例
/// @param cameraView 当前推流 cameraView
- (void)room:(VHRoom *)room didUnpublish:(VHRenderView *)cameraView;

/// 视频流加入回调（流类型包括音视频、共享屏幕、插播等）
/// @param room room实例
/// @param attendView 该成员对应视频画面
- (void)room:(VHRoom *)room didAddAttendView:(VHRenderView *)attendView;

/// 视频流离开回调（流类型包括音视频、共享屏幕、插播等）
/// @param room room实例
/// @param attendView 该成员对应视频画面
- (void)room:(VHRoom *)room didRemovedAttendView:(VHRenderView *)attendView;

/// 互动房间互动消息回调
/// @param room room实例
/// @param eventName 互动消息name，可为空
/// @param attributes 互动消息体
- (void)room:(VHRoom *)room interactiveMsgWithEventName:(NSString *)eventName attribute:(id)attributes __deprecated_msg("Use room:receiveMsgType:targetId: instead");

/// 自己下麦回调（主动下麦/被下麦都会触发此回调） v4.0.0+
/// @param room room实例
- (void)leaveInteractiveRoomByHost:(VHRoom *)room;

/// 自己的麦克风开关状态改变回调（主动操作/被操作都会触发此回调，收到此回调后不需要再主动设置麦克风状态） v4.0.0+
/// @param room room实例
/// @param isClose YES:关闭 NO:开启
- (void)room:(VHRoom *)room microphoneClosed:(BOOL)isClose;

/// 自己的摄像头开关状态改变回调（主动操作/被操作都会触发此回调，收到此回调后不需要再主动设置摄像头状态） v4.0.0+
/// @param room room实例
/// @param isClose YES:关闭 NO:开启
- (void)room:(VHRoom *)room screenClosed:(BOOL)isClose;

/// 自己被踢出房间回调
/// @param room room实例
/// @param iskickout YES
- (void)room:(VHRoom *)room iskickout:(BOOL)iskickout;

/// 自己被禁言/取消禁言回调
/// @param room room实例
/// @param forbidChat 是否被禁言
- (void)room:(VHRoom *)room forbidChat:(BOOL)forbidChat;

/// 收到全体禁言/取消全体禁言回调
/// @param room room实例
/// @param allForbidChat 是否已全体禁言
- (void)room:(VHRoom *)room allForbidChat:(BOOL)allForbidChat;

/// 直播结束回调
/// @param room room实例
/// @param liveOver YES
- (void)room:(VHRoom *)room liveOver:(BOOL)liveOver;

#pragma mark ----------- v6.1新增 --------------
/// 互动相关消息回调（推荐使用）
/// @param room room实例
/// @param message 消息相关信息
- (void)room:(VHRoom *)room receiveRoomMessage:(VHRoomMessage *)message;

@end
