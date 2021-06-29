//
//  VHLiveBroadcastInfoDetailView.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHLiveBroadcastInfoDetailBootomView.h"
#import "VHLiveBroadcastInfoDetailTopView.h"
#import "VHLiveInfoDetailChatView.h"
NS_ASSUME_NONNULL_BEGIN
@class VHLiveBroadcastInfoDetailView;
@protocol VHDocBrushPopViewDelegate;

@protocol VHLiveBroadcastInfoDetailViewDelegate <NSObject>
///点击关闭
- (void)liveDetaiViewClickCloseBtn:(VHLiveBroadcastInfoDetailView *)detailView;

///前后摄像头切换
- (void)liveDetaiViewClickCameraSwitchBtn:(VHLiveBroadcastInfoDetailView *)detailView;

///美颜开关
- (void)liveDetaiViewClickBeautyBtn:(VHLiveBroadcastInfoDetailView *)detailView openBeauty:(BOOL)open;

///麦克风开关
- (void)liveDetaiViewClickMicrophoneBtn:(VHLiveBroadcastInfoDetailView *)detailView voiceBtn:(UIButton *)voiceBtn;

///摄像头开关
- (void)liveDetaiViewClickCameraOpenBtn:(VHLiveBroadcastInfoDetailView *)detailView videoBtn:(UIButton *)videoBtn;

///发送聊天内容
- (void)liveDetaiView:(VHLiveBroadcastInfoDetailView *)detailView sendText:(NSString *)sendText;

///打开文档view
- (void)liveDetailViewOpenDocumentView:(VHLiveBroadcastInfoDetailView *)detailView;

///打开成员列表
- (void)liveDetailViewOpenMemberListView:(VHLiveBroadcastInfoDetailView *)detailView;

- (void)liveDetailViewDocumentListBtnClick:(VHLiveBroadcastInfoDetailView *)detailView;

///演示文档id
- (void)liveDetaiViewShowDocId:(NSString *)docId;

///显示/隐藏文档无关内容
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView hiddenDocUnRelationView:(BOOL)hidden;

//是否可以进行画笔操作
- (BOOL)liveDetailViewCanBrush;

@optional
///上麦/下麦
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView upMicrophoneActionBtn:(UIButton *)button;
///取消上麦
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView cancaelUpMicrophoneActionBtn:(UIButton *)button;

@end

@interface VHLiveBroadcastInfoDetailView : UIView<VHLiveBroadcastInfoDetailBootomViewDelegate>

@property (nonatomic, weak) id<VHLiveBroadcastInfoDetailViewDelegate,VHDocBrushPopViewDelegate> delegate;
/// 直播时间 在线人数 网速
@property (nonatomic , strong) VHLiveBroadcastInfoDetailTopView *topToolView;
/// 底部工具栏
@property (nonatomic , strong) VHLiveBroadcastInfoDetailBootomView *bottomToolView;
/// 聊天视图
@property (nonatomic , strong) VHLiveInfoDetailChatView * chatView;

/** 开播倒计时Label */
@property (nonatomic, strong) UILabel *countDownLab;

/** 当前是否打开文档view */
@property (nonatomic, assign) BOOL openDocView;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 初始化方法
/// @param isSpeaker 是否主讲人
/// @param isGuest 是否为嘉宾
/// @param landScapeShow 是否横屏显示
- (instancetype)initWithSpeaker:(BOOL)isSpeaker guest:(BOOL)isGuest landScapeShow:(BOOL)landScapeShow;

//是否显示聊天view
- (void)hiddenMessageView:(BOOL)hidden;

//是否显示主持人头像/昵称
- (void)hiddenHostInfoView:(BOOL)hidden;

//设置是否切换文档演示样式的UI
- (void)showDocUI:(BOOL)docUI;

//显示隐藏文档无关view(聊天列表、聊天按钮、文档列表)
- (void)hiddenDocUnRelationView:(BOOL)hidden;

//当前画笔弹窗是否在显示
- (BOOL)brushPopViewIsShow;

@end

NS_ASSUME_NONNULL_END
