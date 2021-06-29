//
//  VHLiveLimitListView.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHRoom;
NS_ASSUME_NONNULL_BEGIN

@interface VHLiveLimitListView : UIView

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 初始化方法
/// @param room 直播房间对象
/// @param isGuest 是否为嘉宾端
/// @param memberManage 嘉宾是否有成员管理权限 （只有是嘉宾端才有用）
- (instancetype)initWithRoom:(VHRoom *)room guest:(BOOL)isGuest haveMembersManage:(BOOL)memberManage;

///刷新数据
- (void)reloadNewData;

@end

NS_ASSUME_NONNULL_END
