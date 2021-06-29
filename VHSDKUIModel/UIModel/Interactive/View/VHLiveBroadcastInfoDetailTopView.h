//
//  VHLiveBroadcastInfoDetailTopView.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LiveTopToolHeight 36 //顶部工具栏高度
@class VHLiveBroadcastInfoDetailTopView;

NS_ASSUME_NONNULL_BEGIN
@protocol VHLiveBroadcastInfoDetailTopViewDelegate <NSObject>

///退出按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickClostBtn:(UIButton *)button;

///前后摄像头切换
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickCameraSwitchBtn:(UIButton *)button;

///美颜按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickBeautyBtn:(UIButton *)button;

///语音按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickVoiceBtn:(UIButton *)button;

///视频按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickVideoBtn:(UIButton *)button;

@end

@interface VHLiveBroadcastInfoDetailTopView : UIView

@property (nonatomic, weak) id<VHLiveBroadcastInfoDetailTopViewDelegate> delegate;
/** 头像、时长、观看次数背景view */
@property (nonatomic, strong) UIView *introBgView;
/// 标题（嘉宾端显示标题）
@property (nonatomic , copy) NSString *liveTitleStr;
/** 时长 (主播端显示时长) */
@property (nonatomic, copy) NSString *liveTimeStr;
/** 头像 */
@property (nonatomic, copy) NSString *headIconStr;
/** 观看人数 */
@property (nonatomic, assign) NSInteger watchNumer;
/** 直播类型 */
@property (nonatomic, assign) VHLiveType liveType;
/// 视频按钮
@property (nonatomic , strong) UIButton * videoBtn;
/// 语音按钮
@property (nonatomic , strong) UIButton * voiceBtn;

- (instancetype)initWithScreenLandscape:(BOOL)screenLandscape;

/** 是否隐藏摄像头麦克风等相关操作按钮 */
- (void)hiddenCameraOpenBtn:(BOOL)cameraOpenHidden microphoneBtn:(BOOL)microphoneHidden beautyBtn:(BOOL)beautyHidden cameraSwitch:(BOOL)cameraSwitchHidden;
@end

NS_ASSUME_NONNULL_END
