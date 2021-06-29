//
//  VHLiveMemberAndLimitBaseCell.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHRoomMember;
NS_ASSUME_NONNULL_BEGIN

@protocol VHLiveMemberAndLimitBaseCellDelegate <NSObject>

//更多按钮事件
- (void)moreBtnClickModel:(VHRoomMember *)model;

@optional
//当前是否为嘉宾端
- (BOOL)currentUserIsGuest;
//嘉宾端是否有成员管理权限
- (BOOL)guestHaveMemberManage;
//当前直播类型
- (VHLiveType)curretLiveType;
//上麦邀请/强制下麦
- (void)upMicrophoneActionWithButton:(UIButton *)button targetId:(NSString *)targetId;

@end

@interface VHLiveMemberAndLimitBaseCell : UITableViewCell

/** 更多按钮 */
@property (nonatomic, strong) UIButton *moreBtn;
/** 禁言标识 */
@property (nonatomic, strong) UIImageView *banVoiceIcon;

/** 用户模型 */
@property (nonatomic, strong) VHRoomMember *model;
/** 主讲人 */
@property (nonatomic, strong) NSString *mainSpeakerId;

/** 代理 */
@property (nonatomic, weak) id<VHLiveMemberAndLimitBaseCellDelegate> delegate;

+ (__kindof VHLiveMemberAndLimitBaseCell *)createCellWithTableView:(UITableView *)tableView delegate:(id<VHLiveMemberAndLimitBaseCellDelegate>)deleage;

- (void)configUI;

- (void)configFrame;

@end

NS_ASSUME_NONNULL_END
