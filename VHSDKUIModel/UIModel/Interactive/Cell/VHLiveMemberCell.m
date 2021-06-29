//
//  VHLiveMemberCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveMemberCell.h"
#import <VHInteractive/VHRoom.h>

@interface VHLiveMemberCell ()
/** 主讲人标识 */
@property (nonatomic, strong) UIImageView *speakerImgView;
/** 设备不可用标识 */
@property (nonatomic, strong) UIImageView *deviceErrorImgView;
/** 上下麦按钮 */
@property (nonatomic, strong) UIButton *interactBtn;

@end

@implementation VHLiveMemberCell

+ (__kindof VHLiveMemberAndLimitBaseCell *)createCellWithTableView:(UITableView *)tableView delegate:(id<VHLiveMemberAndLimitBaseCellDelegate>)deleage {
    VHLiveMemberCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VHLiveMemberCell"];
    if (!cell) {
        cell = [[VHLiveMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VHLiveMemberCell"];
        cell.delegate = deleage;
    }
    return cell;
}

- (void)configUI {
    [super configUI];
    [self.contentView addSubview:self.speakerImgView];
    [self.contentView addSubview:self.interactBtn];
    [self.contentView addSubview:self.deviceErrorImgView];
}

- (void)configFrame {
    [super configFrame];
    
    [self.interactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(52, 26)));
        make.right.equalTo(self.moreBtn.mas_left).offset(0);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)setModel:(VHRoomMember *)model {
    [super setModel:model];
    UIView *deviceErrorRightView; //设备错误标识右侧相对约束view
    CGFloat deviceErrorRightViewOffset; //设备错误标识view相对于错误标识右侧view的offset

    UIView *banVoiceRightView; //禁言标识右侧view
    CGFloat banVoiceRightViewOffset; //禁言view相对于禁言标识右侧view的offset

    //是否显示更多按钮
    if([self.delegate currentUserIsGuest] && (![self.delegate guestHaveMemberManage] || model.role_name != VHLiveRole_Audience)) { //嘉宾端 && (没有用户管理权限 || cell用户非观众)，不显示更多按钮 ，嘉宾只能对观众操作
        self.moreBtn.hidden = YES;
        deviceErrorRightView = self.contentView;
        deviceErrorRightViewOffset = -15;
    }else {
        self.moreBtn.hidden = NO;
        deviceErrorRightView = self.moreBtn;
        deviceErrorRightViewOffset = 0;
    }
    
    if(model.device_status != 1 && model.role_name != VHLiveRole_Host) { //设备不可用
        self.deviceErrorImgView.hidden = NO;
        self.interactBtn.hidden = YES;
        [self.deviceErrorImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.size.equalTo(@(CGSizeMake(16, 16)));
            if(deviceErrorRightView == self.contentView) {
                make.right.equalTo(deviceErrorRightView.mas_right).offset(deviceErrorRightViewOffset);
            }else {
                make.right.equalTo(deviceErrorRightView.mas_left).offset(deviceErrorRightViewOffset);
            }
        }];
        banVoiceRightView = self.deviceErrorImgView;
        banVoiceRightViewOffset = -8;
    }else { //设备可用
        self.deviceErrorImgView.hidden = YES;
        
        if([self.delegate curretLiveType] == VHLiveType_Interact && ![self.delegate currentUserIsGuest] && model.role_name != VHLiveRole_Host && model.role_name != VHLiveRole_Assistant && !model.is_banned) { //互动直播 && 当前为发起端(及主持人) && cell用户非主持人和助理 && 没有被禁言，才显示上邀请上/下麦按钮
            self.interactBtn.hidden = NO;
            self.interactBtn.selected = model.is_speak == 1;
            self.interactBtn.backgroundColor = model.is_speak == 1 ? MakeColorRGB(0xE5E5E5) : MakeColorRGB(0xFC5659);
            banVoiceRightView = self.interactBtn;
            banVoiceRightViewOffset = -8;
        }else { //设备可用，但是不满足上下麦显示条件，不显示上下麦按钮
            self.interactBtn.hidden = YES;
            if(self.moreBtn.hidden) { //设备可用 ，不显示上下麦按钮 ，更多按钮隐藏
                banVoiceRightView = self.contentView;
                banVoiceRightViewOffset = -15;
            }else { //设备可用 ，不显示上下麦按钮 ，更多按钮显示
                banVoiceRightView = self.moreBtn;
                banVoiceRightViewOffset = 0;
            }
        }
    }
    
    //是否显示禁言标识
    if(model.is_banned) { //被禁言，显示禁言标识
        self.banVoiceIcon.hidden = NO;
        [self.banVoiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(16, 16)));
            make.centerY.equalTo(self.contentView);
            if(banVoiceRightView == self.contentView) {
                make.right.equalTo(banVoiceRightView.mas_right).offset(banVoiceRightViewOffset);
            }else {
                make.right.equalTo(banVoiceRightView.mas_left).offset(banVoiceRightViewOffset);
            }
        }];
    }else { //未被禁言，不显示禁言标识
        self.banVoiceIcon.hidden = YES;
    }

    //是否显示主讲人标识
    if([model.account_id isEqualToString:self.mainSpeakerId]) {
        self.speakerImgView.hidden = NO;
        UIView *speakerRightView; //主讲人标识右侧view
        CGFloat speakerRightViewOffset = -8; //主讲人view相对于主讲人标识右侧view的offset
        if(self.banVoiceIcon.hidden == NO) { //显示禁言标识
            speakerRightView = self.banVoiceIcon;
        }else { //不显示禁言标识
            if(self.interactBtn.hidden == NO) { //显示上下麦按钮
                speakerRightView = self.interactBtn;
            }else { //不显示上下麦按钮
                if(self.moreBtn.hidden == NO) { //显示更多按钮
                    speakerRightView = self.moreBtn;
                    speakerRightViewOffset = 0;
                }else {
                    speakerRightView = self.contentView;
                    speakerRightViewOffset = -15;
                }
            }
        }

        [self.speakerImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(16, 16)));
            make.centerY.equalTo(self.contentView);
            if(speakerRightView == self.contentView) {
                make.right.equalTo(speakerRightView.mas_right).offset(speakerRightViewOffset);
            }else {
                make.right.equalTo(speakerRightView.mas_left).offset(speakerRightViewOffset);
            }
        }];
    }else {
        self.speakerImgView.hidden = YES;
    }
}

//上麦邀请/下麦用户
- (void)interactBtnClick:(UIButton *)button {
    if([self.delegate respondsToSelector:@selector(upMicrophoneActionWithButton:targetId:)]) {
        [self.delegate upMicrophoneActionWithButton:button targetId:self.model.account_id];
    }
}

- (UIImageView *)speakerImgView
{
    if (!_speakerImgView)
    {
        _speakerImgView = [[UIImageView alloc] init];
//        _speakerImgView.backgroundColor = [UIColor redColor];
        _speakerImgView.image = BundleUIImage(@"icon-成员-主持人");
    }
    return _speakerImgView;
}

- (UIImageView *)deviceErrorImgView
{
    if (!_deviceErrorImgView)
    {
        _deviceErrorImgView = [[UIImageView alloc] init];
//        _deviceErrorImgView.backgroundColor = [UIColor greenColor];
        _deviceErrorImgView.image = BundleUIImage(@"icon-成员-error");
    }
    return _deviceErrorImgView;
}

- (UIButton *)interactBtn
{
    if (!_interactBtn)
    {
        _interactBtn = [[UIButton alloc] init];
        [_interactBtn setTitle:@"上麦" forState:UIControlStateNormal];
        [_interactBtn setTitleColor:MakeColorRGB(0xFFFFFF) forState:UIControlStateNormal];
        [_interactBtn setTitle:@"下麦" forState:UIControlStateSelected];
        [_interactBtn setTitleColor:MakeColorRGB(0x999999) forState:UIControlStateSelected];
        [_interactBtn addTarget:self action:@selector(interactBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _interactBtn.titleLabel.font = FONT_FZZZ(14);
        _interactBtn.layer.cornerRadius = 13;
        _interactBtn.layer.masksToBounds = YES;
    }
    return _interactBtn;
}

@end
