//
//  VHWatchNodelayVideoView.h
//  UIModel
//
//  Created by xiongchao on 2021/10/27.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//
//无延迟观看，视频容器
#import <UIKit/UIKit.h>
#import <VHInteractive/VHLocalRenderView.h>
#import <VHInteractive/VHRoomInfo.h>
NS_ASSUME_NONNULL_BEGIN

@interface VHWatchNodelayVideoView : UIView

@property (nonatomic, strong) VHRoomInfo *roomInfo;

//添加画面
- (void)addRenderView:(VHRenderView *)renderView;

//移除画面
- (void)removeRenderView:(VHRenderView *)renderView;

//更新主讲人画面
- (void)updateMainSpeakerView;

//移除所有画面
- (void)removeAllRenderView;
@end

NS_ASSUME_NONNULL_END
