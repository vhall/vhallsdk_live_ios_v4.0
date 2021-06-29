//
//  VHLiveMemberAndLimitBaseCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveMemberAndLimitBaseCell.h"
#import "VHLiveMemberModel.h"
#import "UIImageView+WebCache.h"
#import <VHInteractive/VHRoom.h>
#import "VUITool.h"
@interface VHLiveMemberAndLimitBaseCell ()
/** 角色 */
@property (nonatomic, strong) UILabel *roleLab;
/** 用户头像 */
@property (nonatomic, strong) UIImageView *headIcon;
/** 设备标识 */
@property (nonatomic, strong) UIImageView *deviceIcon;
/** 昵称 */
@property (nonatomic, strong) UILabel *nameLab;

@end

@implementation VHLiveMemberAndLimitBaseCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (VHLiveMemberAndLimitBaseCell *)createCellWithTableView:(UITableView *)tableView delegate:(id<VHLiveMemberAndLimitBaseCellDelegate>)deleage {
    VHLiveMemberAndLimitBaseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VHLiveMemberAndLimitBaseCell"];
    if (!cell) {
        cell = [[VHLiveMemberAndLimitBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VHLiveMemberAndLimitBaseCell"];
        cell.delegate = deleage;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configUI];
        [self configFrame];
    }
    return self;
}

- (void)configUI {
    [self.contentView addSubview:self.headIcon];
    [self.contentView addSubview:self.deviceIcon];
    [self.contentView addSubview:self.roleLab];
    [self.contentView addSubview:self.nameLab];
    [self.contentView addSubview:self.moreBtn];
    [self.contentView addSubview:self.banVoiceIcon];
}

- (void)configFrame {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(40));
    }];
    
    [self.deviceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.headIcon);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    
    [self.roleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_right).offset(8);
        make.width.equalTo(@(0));
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roleLab.mas_right).offset(4);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(0);
        make.centerY.equalTo(self.contentView);
        make.size.equalTo(@(CGSizeMake(40, 40)));
    }];
}

- (void)setModel:(VHRoomMember *)model {
    _model = model;
    
    [self.headIcon sd_setImageWithURL:[NSURL URLWithString:[VUITool httpPrefixImgUrlStr:model.avatar]] placeholderImage:BundleUIImage(@"head50")];
    if(model.role_name != VHLiveRole_Audience) {
        if(model.role_name == VHLiveRole_Host) {
            self.roleLab.text = @"主持人";
            self.roleLab.backgroundColor = MakeColorRGBA(0xFC5659,0.8);
        }else if (model.role_name == VHLiveRole_Assistant) {
            self.roleLab.text = @"助理";
            self.roleLab.backgroundColor = MakeColorRGBA(0xBBBBBB,0.8);
        }else if (model.role_name == VHLiveRole_Guest) {
            self.roleLab.text = @"嘉宾";
            self.roleLab.backgroundColor = MakeColorRGBA(0x5EA6EC,0.8);
        }
        CGSize size = [self.roleLab sizeThatFits:CGSizeZero];
        [self.roleLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(size.width+12));
        }];
    } else {
        [self.roleLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(0));
        }];
    }
    
    NSString *name = model.nickname.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[model.nickname substringToIndex:VH_MaxNickNameCount]] : model.nickname;
    self.nameLab.text = name;
}


- (void)moreBtnClick:(UIButton *)moreBtn {
    if([self.delegate respondsToSelector:@selector(moreBtnClickModel:)]) {
        [self.delegate moreBtnClickModel:self.model];
    }
}


- (UIImageView *)headIcon
{
    if (!_headIcon)
    {
        // 不设置宽高，加载gif图片会失败
        _headIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _headIcon.layer.cornerRadius = 20;
        _headIcon.clipsToBounds = YES;
        _headIcon.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headIcon;
}

- (UIImageView *)deviceIcon
{
    if (!_deviceIcon)
    {
        _deviceIcon = [[UIImageView alloc] init];
        _deviceIcon.image = [UIImage imageNamed:@""];
        _deviceIcon.hidden = YES;
    }
    return _deviceIcon;
}

- (UILabel *)nameLab
{
    if (!_nameLab)
    {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = FONT_FZZZ(15);
        _nameLab.textColor = MakeColorRGB(0x333333);
        _nameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLab;
}

- (UILabel *)roleLab
{
    if (!_roleLab)
    {
        _roleLab = [[UILabel alloc] init];
        _roleLab.font = FONT_FZZZ(11);
        _roleLab.textColor = [UIColor whiteColor];
        _roleLab.textAlignment = NSTextAlignmentCenter;
        _roleLab.layer.cornerRadius = 8;
        _roleLab.layer.masksToBounds = YES;
    }
    return _roleLab;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn)
    {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.contentMode = UIViewContentModeCenter;
//        _moreBtn.backgroundColor = [UIColor blueColor];
        [_moreBtn setImage:BundleUIImage(@"icon-成员-更多操作") forState:UIControlStateNormal];
    }
    return _moreBtn;
}

- (UIImageView *)banVoiceIcon
{
    if (!_banVoiceIcon)
    {
        _banVoiceIcon = [[UIImageView alloc] init];
//        _banVoiceIcon.backgroundColor = [UIColor orangeColor];
        _banVoiceIcon.image = BundleUIImage(@"icon-成员-禁言");
    }
    return _banVoiceIcon;
}

@end
