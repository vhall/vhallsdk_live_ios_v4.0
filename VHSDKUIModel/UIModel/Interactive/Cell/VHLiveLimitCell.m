//
//  VHLiveLimitCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveLimitCell.h"
#import <VHInteractive/VHRoom.h>

@interface VHLiveLimitCell ()
/** 踢出标识 */
@property (nonatomic, strong) UIImageView *kickOutIcon;
@end

@implementation VHLiveLimitCell

+ (VHLiveLimitCell *)createCellWithTableView:(UITableView *)tableView delegate:(nonnull id<VHLiveMemberAndLimitBaseCellDelegate>)deleage {
    VHLiveLimitCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VHLiveLimitCell"];
    if (!cell) {
        cell = [[VHLiveLimitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VHLiveLimitCell"];
        cell.delegate = deleage;
    }
    return cell;
}

- (void)configUI {
    [super configUI];
    [self.contentView addSubview:self.kickOutIcon];
}

- (void)setModel:(VHRoomMember *)model {
    [super setModel:model];
    
    UIView *rightView;
    CGFloat rightOffset;
    //是否显示更多按钮
    if([self.delegate currentUserIsGuest] && (![self.delegate guestHaveMemberManage] || model.role_name != VHLiveRole_Audience)) { //如果是嘉宾端 && (没有成员管理权限 || cell用户非观众) ，不显示更多按钮（嘉宾只能对观众进行禁言/踢出操作）
        self.moreBtn.hidden = YES;
        rightView = self.contentView;
        rightOffset = -15;
    }else {
        self.moreBtn.hidden = NO;
        rightView = self.moreBtn;
        rightOffset = 0;
    }
    if(model.is_kicked && model.is_banned) { //被踢出 && 被禁言
        [self.kickOutIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(17, 17)));
            make.centerY.equalTo(self.contentView);
            if(rightView == self.contentView) {
                make.right.equalTo(rightView.mas_right).offset(rightOffset);
            }else {
                make.right.equalTo(rightView.mas_left).offset(rightOffset);
            }
        }];
        [self.banVoiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(17, 17)));
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.kickOutIcon.mas_left).offset(-7);
        }];
    }else if (model.is_kicked) { //只被踢出
        [self.kickOutIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(17, 17)));
            make.centerY.equalTo(self.contentView);
            if(rightView == self.contentView) {
                make.right.equalTo(rightView.mas_right).offset(rightOffset);
            }else {
                make.right.equalTo(rightView.mas_left).offset(rightOffset);
            }
        }];
    }else if (model.is_banned) { //只被禁言
        [self.banVoiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(17, 17)));
            make.centerY.equalTo(self.contentView);
            if(rightView == self.contentView) {
                make.right.equalTo(rightView.mas_right).offset(rightOffset);
            }else {
                make.right.equalTo(rightView.mas_left).offset(rightOffset);
            }
        }];
    }
    self.banVoiceIcon.hidden = !model.is_banned;
    self.kickOutIcon.hidden = !model.is_kicked;
}

- (UIImageView *)kickOutIcon
{
    if (!_kickOutIcon)
    {
        _kickOutIcon = [[UIImageView alloc] init];
//        _kickOutIcon.backgroundColor = [UIColor purpleColor];
        _kickOutIcon.image = BundleUIImage(@"icon-成员-踢出");
    }
    return _kickOutIcon;
}

@end
