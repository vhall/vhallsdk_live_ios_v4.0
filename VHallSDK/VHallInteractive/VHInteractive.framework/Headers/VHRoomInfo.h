//
//  VHRoomInfo.h
//  VHallInteractive
//
//  Created by xiongchao on 2021/4/19.
//  Copyright © 2021 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHRoomEnum.h"
#import <VHLiveSDK/VHDocument.h>
#import <VHLiveSDK/VHallConst.h>
NS_ASSUME_NONNULL_BEGIN

// 房间活动相关信息
@interface VHRoomInfo : NSObject
/// 活动id
@property (nonatomic, copy) NSString *webinarId;
/// 活动作者昵称
@property (nonatomic, copy) NSString *webinar_user_nick;
/// 活动作者头像
@property (nonatomic, copy) NSString *webinar_user_icon;
/// 活动标题
@property (nonatomic, copy) NSString *webinar_title;
/// 自己的角色  1主持人 2观众 3助理 4嘉宾
@property (nonatomic, assign) VHRoomRoleNameType selfRoleName;
/// 自己的用户id
@property (nonatomic, copy) NSString *selfUserId;
/// 自己的昵称
@property (nonatomic, copy) NSString *selfNickname;
/// 自己的头像
@property (nonatomic, copy) NSString *selfAvatar;
/// 自己是否有成员管理权限
@property (nonatomic, assign) BOOL membersManageAuthority;

/// 自己是否被禁言  YES：禁言 NO：未禁言
@property (nonatomic, assign) BOOL selfBanChat;
/// 全员是否被禁言  YES：禁言 NO：未禁言
@property (nonatomic, assign) BOOL allBanChat;
/// 当前主讲人（具有文档操作权限）的用户id
@property (nonatomic, copy) NSString *mainSpeakerId;
/// 文档实例对象 ，获取该对象后，设置VHDocument的代理，监听文档相关回调
@property (nonatomic, strong, readonly) VHDocument *documentManager;

@property (nonatomic, strong) id data;
@end


// 互动消息
@interface VHRoomMessage : NSObject
///消息类型
@property (nonatomic, assign) VHRoomMessageType messageType;
///该消息对应的目标用户id
@property (nonatomic, copy) NSString *targetId;
///该消息对应的目标用户昵称
@property (nonatomic, copy) NSString *targetName;
///该消息目标用户是否为自己
@property (nonatomic, assign) BOOL targetForMe;
@end



NS_ASSUME_NONNULL_END
