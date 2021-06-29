//
//  VHInteractVideoCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHInteractVideoCell.h"
#import "VHLiveMemberModel.h"
#import "UIImageView+WebCache.h"
#import <VHInteractive/VHRoom.h>
#import "VUITool.h"
@interface VHInteractVideoCell ()
/** 名字 */
@property (nonatomic, strong) UILabel *nameLab;
/** 摄像头标识 */
@property (nonatomic, strong) UIImageView *videoIcon;
/** 语音标识 */
@property (nonatomic, strong) UIImageView *voiceIcon;
/** 主讲人标识 */
@property (nonatomic, strong) UIImageView *speakerIcon;
/** 角色 */
@property (nonatomic, strong) UILabel *roleLab;
/** 关闭摄像头时的头像 */
@property (nonatomic, strong) UIImageView *headIcon;
/** 阴影图片 */
@property (nonatomic, strong) UIImageView *shadowImgView;
/** 底部控件父视图view */
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation VHInteractVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        [self configFrame];
    }
    return self;
}


- (void)configUI {
    _bottomView = [[UIView alloc] init];
//    _bottomView.backgroundColor = [UIColor redColor];
    self.contentView.backgroundColor = MakeColorRGB(0x000000);
    [self.contentView addSubview:self.shadowImgView];
    [self.contentView addSubview:self.speakerIcon];
    [self.contentView addSubview:self.headIcon];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.roleLab];
    [self.bottomView addSubview:self.nameLab];
    [self.bottomView addSubview:self.voiceIcon];
    [self.bottomView addSubview:self.videoIcon];
}

- (void)configFrame {
    
    [self.shadowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(40));
    }];
    
    [self.speakerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(16, 16)));
        make.right.equalTo(self.contentView).offset(-6);
        make.top.equalTo(self.contentView).offset(6);
    }];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.equalTo(@(CGSizeMake(60, 60)));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(0);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(40));
    }];
    
    [self.roleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView).offset(-5);
        make.left.equalTo(self.bottomView).offset(5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roleLab.mas_right).offset(4);
        make.bottom.equalTo(self.bottomView).offset(-5);
        make.right.equalTo(self.videoIcon.mas_left).offset(-5);
        make.height.mas_equalTo(16);
    }];
    [self.voiceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.bottomView).offset(-6);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    [self.videoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.voiceIcon);
        make.size.equalTo(self.voiceIcon);
    }];
}

- (void)setModel:(VHLiveMemberModel * _Nonnull)model {
    _model = model;

    if(model.role_name == VHLiveRole_Host) {
        self.roleLab.text = @"主持人";
        self.roleLab.textColor = [UIColor whiteColor];
        self.roleLab.backgroundColor = MakeColorRGBA(0xFC5659,0.8);
    }else if (model.role_name == VHLiveRole_Guest) {
        self.roleLab.text = @"嘉宾";
        self.roleLab.textColor = [UIColor whiteColor];
        self.roleLab.backgroundColor = MakeColorRGBA(0x5EA6EC,0.8);
    }else {
        self.roleLab.text = @"";
        self.roleLab.textColor = [UIColor clearColor];
        self.roleLab.backgroundColor = [UIColor clearColor];
    }
    CGSize size = [self.roleLab sizeThatFits:CGSizeZero];
    [self.roleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width+12);
    }];
    NSString *nickname = model.nickname.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[model.nickname substringToIndex:VH_MaxNickNameCount]] : model.nickname;
    self.nameLab.text = nickname;
    
    self.voiceIcon.hidden = !model.closeMicrophone;
    
    if(model.closeCamera) { //关闭摄像头
        self.headIcon.hidden = NO;
        self.videoIcon.hidden = NO;
        [self.headIcon sd_setImageWithURL:[NSURL URLWithString:[VUITool httpPrefixImgUrlStr:model.avatar]] placeholderImage:BundleUIImage(@"head50")];
    }else { //开启摄像头
        self.headIcon.hidden = YES;
        self.videoIcon.hidden = YES;
    }
    
    if(model.closeMicrophone && model.closeCamera) { //同时关闭摄像头与麦克风
        [self.videoIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.voiceIcon.mas_left).offset(-6);
            make.bottom.equalTo(self.bottomView).offset(-6);
            make.size.equalTo(@(CGSizeMake(16, 16)));
        }];
    }else if(model.closeCamera) { //只关闭摄像头
        [self.videoIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.bottomView).offset(-6);
            make.size.equalTo(@(CGSizeMake(16, 16)));
        }];
    }else if(model.closeMicrophone) { //只关闭麦克风
        [self.voiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.bottomView).offset(-6);
            make.size.equalTo(@(CGSizeMake(16, 16)));
        }];
    }else { //同时开启摄像头与麦克风
        [self.voiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.bottomView).offset(-6);
            make.size.equalTo(@(CGSizeMake(16, 16)));
        }];
        [self.videoIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.voiceIcon);
            make.size.equalTo(self.voiceIcon);
        }];
    }

//    NSLog(@"视频用户id：%@ 视频流id：%@",model.videoView.userId,model.videoView.streamId);
    VHRenderView *videoView = [self.contentView viewWithTag:1000];
    if(videoView && videoView != model.videoView) {
        [videoView removeFromSuperview];
        [self addVideoView];
    }else {
        [self addVideoView];
    }

    if(model.videoView.streamType == VHInteractiveStreamTypeScreen || model.videoView.streamType == VHInteractiveStreamTypeFile) { //桌面共享或插播不显示主讲人标识，昵称等控件
        self.speakerIcon.hidden = YES;
        self.bottomView.hidden = YES;
    }else {
        self.bottomView.hidden = NO;
        self.speakerIcon.hidden = !model.haveDocPermission;
    }
//    NSLog(@"麦克风关闭：%d---摄像头关闭：%d",model.closeMicrophone,model.closeCamera);
}

- (void)addVideoView {
    [self.contentView insertSubview:self.model.videoView atIndex:0];
    self.model.videoView.tag = 1000;
    [self.model.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)adaptLandscapeiPhoneX:(BOOL)enable {
    if(enable) {
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.right.equalTo(self.contentView);
            make.height.equalTo(@(40));
        }];
    }else {
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.equalTo(@(40));
        }];
    }
}

- (UIImageView *)voiceIcon
{
    if (!_voiceIcon)
    {
        _voiceIcon = [[UIImageView alloc] init];
        _voiceIcon.image = BundleUIImage(@"icon-上麦成员-扬声器关闭");
    }
    return _voiceIcon;
}

- (UIImageView *)videoIcon
{
    if (!_videoIcon)
    {
        _videoIcon = [[UIImageView alloc] init];
        _videoIcon.image = BundleUIImage(@"icon-上麦成员-摄像头关闭");
    }
    return _videoIcon;
}

- (UILabel *)nameLab
{
    if (!_nameLab)
    {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = FONT_FZZZ(11);
        _nameLab.textColor = MakeColorRGB(0xcccccc);
        _nameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLab;
}

- (UIImageView *)speakerIcon
{
    if (!_speakerIcon)
    {
        _speakerIcon = [[UIImageView alloc] init];
        _speakerIcon.image = BundleUIImage(@"icon-成员-主持人");
    }
    return _speakerIcon;
}

- (UILabel *)roleLab
{
    if (!_roleLab)
    {
        _roleLab = [[UILabel alloc] init];
        _roleLab.textAlignment = NSTextAlignmentCenter;
        _roleLab.font = FONT_FZZZ(11);
        _roleLab.layer.cornerRadius = 8;
        _roleLab.layer.masksToBounds = YES;
    }
    return _roleLab;
}

- (UIImageView *)headIcon
{
    if (!_headIcon)
    {
        _headIcon = [[UIImageView alloc] init];
        _headIcon.backgroundColor = MakeColorRGB(0xefeff4);
        _headIcon.contentMode = UIViewContentModeScaleAspectFill;
        _headIcon.layer.cornerRadius = 30;
        _headIcon.layer.masksToBounds = YES;
    }
    return _headIcon;
}

- (UIImageView *)shadowImgView
{
    if (!_shadowImgView)
    {
        _shadowImgView = [[UIImageView alloc] init];
        _shadowImgView.contentMode = UIViewContentModeScaleToFill;
        _shadowImgView.clipsToBounds = YES;
        _shadowImgView.image = BundleUIImage(@"icon-互动画面遮罩");
    }
    return _shadowImgView;
}

@end
