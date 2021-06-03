//
//  VHallMoviePlayer.h
//  VHLivePlay
//
//  Created by liwenlong on 16/2/16.
//  Copyright © 2016年 vhall. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerController.h>
#import "VHallConst.h"
#import "VHWebinarInfo.h"

@class VHDLNAControl;
@protocol VHallMoviePlayerDelegate;

@interface VHallMoviePlayer : NSObject
/// 获取播放器view
@property (nonatomic, strong, readonly) UIView *moviePlayerView;

/// 代理对象
@property (nonatomic, weak) id <VHallMoviePlayerDelegate> delegate;

/// 设置链接的超时时间 默认6000毫秒，单位为毫秒  MP4点播 最小10000毫秒
@property (nonatomic, assign) int timeout;

/// 设置RTMP 的缓冲时间 默认 6秒 单位为秒 必须>0 值越小延时越小,卡顿增加
@property (nonatomic, assign) int bufferTime;

/// 设置视频的填充模式 默认是自适应模式：VHRTMPMovieScalingModeAspectFit
@property (nonatomic, assign) VHRTMPMovieScalingMode movieScalingMode;

/// 设置默认播放的清晰度 默认原画
@property (nonatomic, assign) VHMovieDefinition defaultDefinition;

/// 设置当前播放的清晰度
@property (nonatomic, assign) VHMovieDefinition curDefinition;

/// 获取当前视频观看模式
@property (nonatomic, assign, readonly) VHMovieVideoPlayMode playMode;

/// 获取RTMP播放实际的缓冲时间，单位毫秒
@property (nonatomic, assign, readonly) int realityBufferTime;

/// 获取播放器状态
@property (nonatomic, assign, readonly) VHPlayerState playerState;

/// 获取文档演示view，如果没有文档则为nil (在收到"文档显示/隐藏回调"后获取)
@property (nonatomic, strong, readonly) UIView *documentView;

/// 活动状态 （在收到"视频信息预加载回调"或"播放连接成功回调"后使用）
@property (nonatomic, assign, readonly) VHMovieActiveState activeState;

/// 活动相关信息 （在收到"视频信息预加载回调"或"播放连接成功回调"后使用，v6.0新增，仅限新版控制台(v3及以上)创建的活动使用）
@property (nonatomic, strong, readonly) VHWebinarInfo *webinarInfo;

/// 水印（在收到"播放连接成功回调"后使用）
@property(nonatomic, strong, readonly) UIImageView *waterImg;

//---------------以下属性 点播/回放播放时使用 直播无效--------------------
/// 视频时长
@property (nonatomic, assign, readonly) NSTimeInterval          duration;
/// 可播放时长
@property (nonatomic, assign, readonly) NSTimeInterval          playableDuration;
/// 当前播放时间点
@property (nonatomic, assign) NSTimeInterval          currentPlaybackTime;
/// 点播倍速播放速率 0.50, 0.67, 0.80, 1.0, 1.25, 1.50, and 2.0
@property (nonatomic, assign) float                   rate;
/// 初始化要播放的位置
@property (nonatomic, assign) NSTimeInterval          initialPlaybackTime;

/// 初始化VHMoviePlayer对象
/// @param delegate 代理对象
- (instancetype)initWithDelegate:(id <VHallMoviePlayerDelegate>)delegate;

/// 预加载视频信息，在收到"视频信息预加载完成回调"后，即可使用聊天、签到、问答、抽奖等功能，然后择机调用startPlay/startPlayback进行播放，注意使用此方法后，startPlay和startPlayback传参将不再生效（此方法主要用于播放之前需要使用聊天等功能）
/// @param param 传参信息
/// param[@"id"]    = 活动Id，必传
/// param[@"pass"]  = 活动如果有K值或密码，则需要传
- (void)preLoadRoomWithParam:(NSDictionary *)param;

/// 观看直播视频，在收到"播放连接成功回调"后，才可使用聊天、签到、问答、抽奖等功能
/// @param param
/// param[@"id"]    = 活动Id
/// param[@"pass"]  = 活动如果有K值或密码，则需要传
- (BOOL)startPlay:(NSDictionary *)param;

/// 观看回放/点播视频，在收到"播放连接成功回调"后，才可使用聊天、签到、问答、抽奖等功能
/// @param param
/// param[@"id"]    = 活动Id，必传
/// param[@"pass"]  = 活动如果有K值或密码，则需要传
- (BOOL)startPlayback:(NSDictionary *)param;

/// 暂停播放 （如果是直播，等同于stopPlay）
- (void)pausePlay;

/// 播放出错/暂停播放后恢复播放
/// @return NO 播放器不是暂停状态 或者已经结束
- (BOOL)reconnectPlay;

/// 停止播放
- (void)stopPlay;

/// 设置静音
/// @param mute 是否静音
- (void)setMute:(BOOL)mute;

/// 销毁播放器
- (void)destroyMoivePlayer;

#pragma mark - 连麦互动接口

/// 发送 申请上麦/取消申请 消息
/// @param type 1申请上麦，0取消申请上麦
- (BOOL)microApplyWithType:(NSInteger)type;


/// 发送 申请上麦/取消申请 消息
/// @param type 1申请上麦，0取消申请上麦
/// @param finishBlock finishBlock 消息发送结果
- (BOOL)microApplyWithType:(NSInteger)type finish:(void(^)(NSError *error))finishBlock;


/// 收到邀请后 是否同意上麦
/// @param type 1接受，2拒绝，3超时失败
/// @param finishBlock 结果回调
- (BOOL)replyInvitationWithType:(NSInteger)type finish:(void(^)(NSError *error))finishBlock;

#pragma mark - 辅助接口

/// 清空视频剩余的最后一帧画面
- (void)cleanLastFrame;

/// 是否启用陀螺仪控制画面模式，仅播放 VR 活动时有效
/// @param usingGyro 是否使用陀螺仪
- (void)setUsingGyro:(BOOL)usingGyro;

/// 设置视频显示的方向，用于陀螺仪方向校对，仅播放 VR 活动时，并且开启陀螺仪模式时，必须设置
/// @param orientation 方向
- (void)setUILayoutOrientation:(UIDeviceOrientation)orientation;

/// 设置投屏对象 (投屏功能使用步骤：1、设置DLNAobj 2、收到DLNAobj设备列表回调后，设置投屏设备 3、DLNAobj初始化播放。如果播放过程中多个player使用对同一个DLNAobj，则DLNAobj需要重新初始化播放)
/// @param DLNAobj 投屏VHDLNAControl对象
/// 返回值  YES 可投屏，NO不可投屏
- (BOOL)dlnaMappingObject:(VHDLNAControl *)DLNAobj;

/// 重连socket
- (BOOL)reconnectSocket;

///设置音频输出设备
+ (void)audioOutput:(BOOL)inSpeaker;

/// 设置系统声音大小
/// @param size 音量范围[0.0~1.0]
+ (void)setSysVolumeSize:(float)size;

/// 获取系统声音大小
+ (float)getSysVolumeSize;
@end


@protocol VHallMoviePlayerDelegate <NSObject>

@optional

/// 视频信息预加载完成回调，前提需使用方法"preLoadRoomWithParam"，收到此回调后，可以使用聊天、签到、问答、抽奖等功能，择机调用startPlay/startPlayback进行播放（可以实现在调用播放之前使用聊天等功能）
/// @param moviePlayer 播放器实例
/// @param activeState 活动状态
/// @param error    非空即预加载成功
- (void)preLoadVideoFinish:(VHallMoviePlayer *)moviePlayer activeState:(VHMovieActiveState)activeState error:(NSError*)error;

/// 播放连接成功回调，前提需使用方法"startPlay/startPlayback"，收到此回调后，可以使用聊天、签到、问答、抽奖等功能
/// @param moviePlayer 播放器实例
/// @param info 相关信息
- (void)connectSucceed:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info;

/// 缓冲开始回调
/// @param moviePlayer 播放器实例
/// @param info 相关信息
- (void)bufferStart:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info;

/// 缓冲结束回调
/// @param moviePlayer 播放器实例
/// @param info 相关信息
- (void)bufferStop:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info;

/// 下载速率的回调
/// @param moviePlayer 播放器实例
/// @param info 下载速率信息，单位kbps，字典结构：{content：速度}
- (void)downloadSpeed:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info;

/// 视频流类型回调
/// @param moviePlayer 播放器实例
/// @param info 字典结构：{content：流类型(VHStreamType)}
- (void)recStreamtype:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info;

/// 播放时错误的回调
/// @param livePlayErrorType 直播错误类型
/// @param info 具体错误信息  字典结构：{code:错误码，content:错误信息} (错误码以及对应含义请前往VhallConst.h查看)
- (void)playError:(VHSaasLivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;

/// 当前活动状态回调
/// @param activeState 活动状态
- (void)ActiveState:(VHMovieActiveState)activeState;

/// 当前视频播放模式，以及是否为vr活动回调
/// @param playMode 视频播放模式
/// @param isVrVideo 是否为vr活动
- (void)VideoPlayMode:(VHMovieVideoPlayMode)playMode isVrVideo:(BOOL)isVrVideo;

/// 当前视频支持的播放模式列表回调
/// @param playModeList VHMovieVideoPlayMode播放模式组合，如@[@(VHMovieVideoPlayModeMedia),@(VHMovieVideoPlayModeVoice)]
- (void)VideoPlayModeList:(NSArray *)playModeList;

/// 当前视频支持的清晰度列表回调
/// @param definitionList VHDefinition清晰度组合，如@[@(VHDefinitionOrigin),@(VHDefinitionUHD),@(VHDefinitionHD)]
- (void)VideoDefinitionList:(NSArray *)definitionList;

/// 直播开始推流消息 注意：H5和互动活动 收到此消息后建议延迟 5s 开始播放
- (void)LiveStart;

/// 直播结束消息
- (void)LiveStoped;

/// 发布公告的回调
/// @param content 公告内容
/// @param time 发布时间
- (void)Announcement:(NSString*)content publishTime:(NSString*)time;

/// 当前活动是否允许举手申请上麦回调
/// @param player 播放器实例
/// @param isInteractive 当前活动是否支持互动功能
/// @param state 主持人是否允许举手
- (void)moviePlayer:(VHallMoviePlayer *)player isInteractiveActivity:(BOOL)isInteractive interactivePermission:(VHInteractiveState)state;

/// 主持人是否同意上麦申请回调
/// @param player 播放器实例
/// @param attributes 收到的数据
/// @param error 错误回调 nil：同意上麦  非nil：不同意上麦
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitationWithAttributes:(NSDictionary *)attributes error:(NSError *)error;

/// 被主持人邀请上麦
/// @param player 播放器实例
/// @param attributes 收到的数据
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitation:(NSDictionary *)attributes;

/// 被踢出
/// @param player 播放器实例
/// @param isKickout 被踢出 （取消踢出后需要重新进入）
- (void)moviePlayer:(VHallMoviePlayer *)player isKickout:(BOOL)isKickout;

/// 主持人显示/隐藏文档
/// @param player 播放器实例
/// @param isHave YES 此活动有文档演示
/// @param isShow YES 主持人显示观看端文档，NO 主持人隐藏观看端文档
- (void)moviePlayer:(VHallMoviePlayer *)player isHaveDocument:(BOOL)isHave isShowDocument:(BOOL)isShow;

/// 直播文档同步，直播文档有延迟，指定需要延迟的秒数 （默认为直播缓冲时间，即：realityBufferTime/1000.0）
/// @param player 播放器实例
- (NSTimeInterval)documentDelayTime:(VHallMoviePlayer *)player;

/// 当前是否支持投屏功能
/// @param player 播放器实例
/// @param isCast_screen 1支持 0不支持
- (void)moviePlayer:(VHallMoviePlayer *)player isCast_screen:(BOOL)isCast_screen;

/// 播放器状态回调
/// @param player 播放器实例
/// @param state 播放器状态
- (void)moviePlayer:(VHallMoviePlayer *)player statusDidChange:(VHPlayerState)state;

/// 当前是否开启问答功能
/// @param player 播放器实例
/// @param isQuestion_status 1开启 0关闭
- (void)moviePlayer:(VHallMoviePlayer *)player isQuestion_status:(BOOL)isQuestion_status;


/// 视频宽髙回调（支持直播与点播）
/// @param player 播放器实例
/// @param size 视频尺寸
- (void)moviePlayer:(VHallMoviePlayer *)player videoSize:(CGSize)size;

#pragma mark - 点播

/// 当前播放时间回调
/// @param player 播放器实例
/// @param currentTime 当前播放时间点 1s回调一次，可用于UI刷新
- (void)moviePlayer:(VHallMoviePlayer *)player currentTime:(NSTimeInterval)currentTime;

@end
