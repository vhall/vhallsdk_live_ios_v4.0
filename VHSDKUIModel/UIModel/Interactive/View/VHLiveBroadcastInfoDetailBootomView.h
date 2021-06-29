//
//  VHLiveBroadcastInfoDetailBootomView.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LiveToolViewHeight 36 //工具栏高度

#define UpMicCountDownTime 30 //上麦倒计时

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class VHLiveBroadcastInfoDetailBootomView;
@protocol VHLiveBroadcastInfoDetailBootomViewDelegate <NSObject>

///说点什么
- (void)chatBtnClickToolView:(VHLiveBroadcastInfoDetailBootomView *)toolView;

@optional

//----------------------开启文档演示之前，相关按钮事件---------------------
///文档演示
- (void)documentShowBtnClickToolView:(VHLiveBroadcastInfoDetailBootomView *)toolView;

///成员列表
- (void)liveDetailBottomViewMemberBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView;

///上麦/下麦
- (void)toolView:(VHLiveBroadcastInfoDetailBootomView *)toolView upMicrophoneWithBtn:(UIButton *)button;
///取消上麦
- (void)toolView:(VHLiveBroadcastInfoDetailBootomView *)toolView cancelMicrophoneWithBtn:(UIButton *)button;

//----------------------开启文档演示之后，相关按钮事件---------------------
///文档选择
- (void)liveDetailBottomViewDocumentListBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView;

///文档画笔
- (void)liveDetailBottomViewDocumentBrushBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView showBrushView:(BOOL)show;

///隐藏/显示文档无关功能
- (void)liveDetailBottomView:(VHLiveBroadcastInfoDetailBootomView *)toolView hiddenDocUnRelationView:(BOOL)hidden;

@end

@interface VHLiveBroadcastInfoDetailBootomView : UIView

@property (nonatomic, weak) id<VHLiveBroadcastInfoDetailBootomViewDelegate> delegate;
/** 是否为主讲人 */
@property (nonatomic, assign) BOOL isSpeaker;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;


/// 初始化
/// @param isSpeaker 是否为主讲人
/// @param isGuest 是否为嘉宾
- (instancetype)initWithSpearker:(BOOL)isSpeaker guest:(BOOL)isGuest;

//是否显示文档演示时的工具按钮
- (void)showDocScenceBtns:(BOOL)isDoc;

//显示/隐藏聊天按钮
- (void)hiddenChatBtn:(BOOL)hidden;

//显示/隐藏文档列表按钮
- (void)hiddenDocListBtn:(BOOL)hidden;

//开始上麦倒计时
- (void)startUpMicCountDownTime;

//结束倒计时  UpMicSuccess: YES：成功上麦  NO：倒计时走完也没上麦成功
- (void)endTimeByUpMicSuccess:(BOOL)upMicSuccess;

//取消清屏
- (void)cancelClear;

//取消画笔选择
- (void)cancelSelectBrush;

//当前是否已上麦（上麦按钮是否选中）
- (BOOL)upMicBtnSelected;

@end

NS_ASSUME_NONNULL_END
