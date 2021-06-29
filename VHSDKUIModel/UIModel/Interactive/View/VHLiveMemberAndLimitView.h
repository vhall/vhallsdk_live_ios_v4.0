//
//  VHLiveMemberAndLimitView.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHRoom;
typedef void(^ShowCompleteBlock)(void); //显示完成回调
typedef void(^DismissCompleteBlock)(void); //消失完成回调

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveMemberAndLimitView : UIView

/** 直播对象 */
@property (nonatomic, strong) VHRoom *room;
@property (nonatomic, copy) ShowCompleteBlock showBlock;
@property (nonatomic, copy) DismissCompleteBlock disMissBlock;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/// 初始化方法
/// @param room 直播对象
/// @param liveType 直播类型
/// @param isGuest 是否为嘉宾端（只有在直播类型为互动时才使用）
/// @param memberManage 是否有成员管理权限（只有嘉宾端才使用）
- (instancetype)initWithRoom:(VHRoom *)room liveType:(VHLiveType)liveType isCuest:(BOOL)isGuest haveMembersManage:(BOOL)memberManage;

///显示
- (void)showInView:(UIView *)view;

///更新成员列表与受限列表
- (void)updateListData;

@end

NS_ASSUME_NONNULL_END
