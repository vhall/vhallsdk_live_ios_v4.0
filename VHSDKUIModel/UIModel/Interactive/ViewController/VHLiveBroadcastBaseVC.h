//
//  VHLiveBroadcastBaseVC.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBaseVC.h"
#import <VHLiveSDK/VHallApi.h>

@class VHLiveMemberAndLimitView;
@class VHLiveBroadcastInfoDetailView;
@class VHLiveStateView;
@class VHLiveDocContentView;
@class VHRoomInfo;
@class OMTimer;
@class VHRoom;
@class VHallChat;

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveBroadcastBaseVC : VHLiveBaseVC
/// 直播时长
@property (nonatomic , strong) OMTimer *liveTimer;
///视频直播、音频直播推流对象
@property (nonatomic,strong)VHallLivePublish *publisher;
///聊天对象
@property (nonatomic,strong)VHallChat *chatService;
/** 用户列表 */
@property (nonatomic, weak) VHLiveMemberAndLimitView *userListView;
/// 直播详情View
@property (nonatomic , strong) VHLiveBroadcastInfoDetailView *infoDetailView;
/** 文档容器 */
@property (nonatomic, strong) VHLiveDocContentView *docContentView;
/** 直播状态view */
@property (nonatomic, strong) VHLiveStateView *liveStateView;

/** 直播信息 */
@property (nonatomic, strong) VHRoomInfo *roomInfo;
/** 直播信息 */
@property (nonatomic, copy) NSDictionary *params;
/// 是否为横屏 ，YES：横屏 NO：竖屏 ，默认NO
@property (nonatomic , assign) BOOL screenLandscape;

/** 是否为音频直播，默认NO */
@property (nonatomic, assign) BOOL isAudioLive;
/** 是否是主讲人，默认NO */
@property (nonatomic, assign) BOOL isSpeaker;
/** 是否是嘉宾，默认NO */
@property (nonatomic, assign) BOOL isGuest;

//开播倒计时结束
- (void)startLiveCountDownOver NS_REQUIRES_SUPER;
//回到前台
- (void)appWillEnterForeground;
//回到后台
- (void)appDidEnterBackground;
//强杀
- (void)appWillTerminate;
//初始化
- (instancetype)initWithParams:(NSDictionary *)params;
//显示直播结束页
- (void)showLiveEndView;
//网络错误，重新推流
- (void)restartPushForNetError;
/// 更新成员列表与受限列表
- (void)updateUserList;
///前后设置头切换
- (void)liveDetaiViewClickCameraSwitchBtn:(VHLiveBroadcastInfoDetailView *)detailView;
///美颜开关
- (void)liveDetaiViewClickBeautyBtn:(VHLiveBroadcastInfoDetailView *)detailView openBeauty:(BOOL)open;
///麦克风开关
- (void)liveDetaiViewClickMicrophoneBtn:(VHLiveBroadcastInfoDetailView *)detailView voiceBtn:(UIButton *)voiceBtn;
///摄像头开关
- (void)liveDetaiViewClickCameraOpenBtn:(VHLiveBroadcastInfoDetailView *)detailView videoBtn:(UIButton *)videoBtn;
///打开文档容器
- (void)liveDetailViewOpenDocumentView:(VHLiveBroadcastInfoDetailView *)detailView;
///关闭文档容器
- (void)docContentViewDisMissComplete:(VHLiveDocContentView *)docContentView NS_REQUIRES_SUPER;
///显示/隐藏文档无关内容
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView hiddenDocUnRelationView:(BOOL)hidden;
//演示文档
- (void)liveDetaiViewShowDocId:(NSString *)docId;

@end

NS_ASSUME_NONNULL_END
