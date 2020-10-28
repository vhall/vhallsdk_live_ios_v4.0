//
//  VHPortraitWatchLiveDecorateView.h
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//
//竖屏观看视频画面上的子控件（聊天、上麦等）
#import <UIKit/UIKit.h>
#import "MicCountDownView.h"

NS_ASSUME_NONNULL_BEGIN
@class VHPortraitWatchLiveDecorateView;

@protocol VHPortraitWatchLiveDecorateViewDelegate <NSObject>

//指定需要判断是否响应交互事件的视图
- (UIView *)decorateViewHitTestEventView;

//上麦按钮点击事件
- (void)decorateView:(VHPortraitWatchLiveDecorateView *)decorateView upMicBtnClick:(UIButton *)button;

//上麦倒计时结束
- (void)decorateViewUpMicTimeOver:(VHPortraitWatchLiveDecorateView *)decorateView;

//发送消息
- (void)decorateView:(VHPortraitWatchLiveDecorateView *)decorateView sendMessage:(NSString *)messageText;

@end

@interface VHPortraitWatchLiveDecorateView : UIView
/** 代理 */
@property (nonatomic, weak) id<VHPortraitWatchLiveDecorateViewDelegate> delegate;
/** 上麦按钮view */
@property (nonatomic, strong, readonly) MicCountDownView *upMicBtnView;
/** 网速 */
@property (nonatomic, strong, readonly) UILabel *networkSpeedLab;
/** 聊天列表 */
@property (nonatomic, strong ,readonly) UITableView *chatListView;


- (instancetype)initWithDelegate:(id<VHPortraitWatchLiveDecorateViewDelegate>)delegate;

//接收消息
- (void)receiveMessage:(NSArray *)msgArr;

@end

NS_ASSUME_NONNULL_END
