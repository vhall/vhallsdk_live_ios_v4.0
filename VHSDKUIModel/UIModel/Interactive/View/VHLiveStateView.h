//
//  VHLiveStateView.h
//  UIModel
//
//  Created by leiheng on 2021/4/16.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHLiveStateView;

@protocol VHLiveStateViewDelegate <NSObject>

///直播状态页按钮事件
- (void)liveStateView:(VHLiveStateView *)liveStateView actionType:(VHLiveState)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveStateView : UIView

/** 代理 */
@property (nonatomic, weak) id<VHLiveStateViewDelegate> delegate;
/** 直播状态 */
@property (nonatomic, assign ,readonly) VHLiveState liveState;

- (void)setLiveState:(VHLiveState)liveState btnTitle:(NSString *)btnTitle;

@end

NS_ASSUME_NONNULL_END
