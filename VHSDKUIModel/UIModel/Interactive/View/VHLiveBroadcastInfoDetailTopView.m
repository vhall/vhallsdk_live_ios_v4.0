//
//  VHLiveBroadcastInfoDetailTopView.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBroadcastInfoDetailTopView.h"
#import "UIImageView+WebCache.h"

@interface VHLiveBroadcastInfoDetailTopView ()

/// 主播头像
@property (nonatomic , strong) UIImageView * headImgView;
/// 详细信息(直播时间/观看次数)
@property (nonatomic , strong) UILabel * introLab;
/// 观看人数
@property (nonatomic , strong) UILabel * watchNumLab;
/// 美颜
@property (nonatomic , strong) UIButton * beautyBtn;
/// 前后摄像头切换
@property (nonatomic , strong) UIButton * cameraSwitchBtn;
/// 退出按钮
@property (nonatomic , strong) UIButton * closeBtn;
/** 观看人数 */
@property (nonatomic, copy) NSString *watchNumStr;
/** 是否横屏显示 */
@property (nonatomic, assign) BOOL screenLandscape;

@end
@implementation VHLiveBroadcastInfoDetailTopView

- (instancetype)initWithScreenLandscape:(BOOL)screenLandscape
{
    self = [super init];
    if (self) {
        self.screenLandscape = screenLandscape;
        _watchNumStr = @"1人观看";
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.introBgView];
        [self.introBgView addSubview:self.introLab];
        [self.introBgView addSubview:self.watchNumLab];
        [self.introBgView addSubview:self.headImgView];
        
        [self addSubview:self.videoBtn];
        [self addSubview:self.voiceBtn];
        [self addSubview:self.beautyBtn];
        [self addSubview:self.cameraSwitchBtn];
        [self addSubview:self.closeBtn];

        [self configFrame];
    }
    return self;
}

- (void)configFrame
{
    [self.introBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.height.equalTo(self.introBgView);
        make.width.equalTo(self.introBgView);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(3);
        make.centerY.mas_equalTo(self.introBgView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.introLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImgView.mas_right).offset(4);
        make.top.mas_equalTo(self.introBgView).offset(5);
        make.right.mas_equalTo(self.introBgView).offset(-14);
        make.height.mas_equalTo(12);
    }];
    
    [self.watchNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImgView.mas_right).offset(4);
        make.bottom.mas_equalTo(self.introBgView).offset(-5.5);
        make.right.mas_equalTo(self.introBgView).offset(-14);
        make.height.mas_equalTo(12);
    }];

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.centerY.mas_equalTo(self);
        make.height.width.equalTo(self.mas_height);
    }];

    //iPhone5系列竖屏特殊处理
    CGFloat btnMargin = (!self.screenLandscape && VH_IS_IPHONE_5) ? 5 : 10;
    CGFloat btnSize = (!self.screenLandscape && VH_IS_IPHONE_5) ? 30 : LiveTopToolHeight;

    [self.cameraSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(0);;
        make.height.width.mas_equalTo(btnSize);
    }];

    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.cameraSwitchBtn.mas_left).offset(-btnMargin);;
        make.height.width.equalTo(self.cameraSwitchBtn);
    }];
    
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.beautyBtn.mas_left).offset(-btnMargin);;
        make.height.width.equalTo(self.cameraSwitchBtn);
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.voiceBtn.mas_left).offset(-btnMargin);;
        make.height.width.equalTo(self.cameraSwitchBtn);
    }];
}

- (void)setLiveType:(VHLiveType)liveType {
    _liveType = liveType;
    if (liveType == VHLiveType_Audio) { //音频直播
        [self hiddenCameraOpenBtn:YES microphoneBtn:YES beautyBtn:YES cameraSwitch:YES];
    }else {
        self.voiceBtn.hidden = self.beautyBtn.hidden = self.cameraSwitchBtn.hidden = NO;
        if(liveType == VHLiveType_Video) { //视频直播不显示 视频按钮
            self.videoBtn.hidden = YES;
        }else if(liveType == VHLiveType_Interact) { //互动直播
            self.videoBtn.hidden = NO;
        }
    }
}

/** 是否隐藏摄像头麦克风等相关操作按钮 */
- (void)hiddenCameraOpenBtn:(BOOL)cameraOpenHidden microphoneBtn:(BOOL)microphoneHidden beautyBtn:(BOOL)beautyHidden cameraSwitch:(BOOL)cameraSwitchHidden {
    self.videoBtn.hidden = cameraOpenHidden;
    self.voiceBtn.hidden = microphoneHidden;
    self.beautyBtn.hidden = beautyHidden;
    self.cameraSwitchBtn.hidden = cameraSwitchHidden;
}

//设置直播标题
- (void)setLiveTitleStr:(NSString *)titleStr{
    _liveTitleStr = titleStr;
    if(titleStr.length > 8) {
        _liveTitleStr =  [NSString stringWithFormat:@"%@...",[titleStr substringToIndex:8]];
    }
    self.introLab.text = _liveTitleStr;
}

//设置直播时长
- (void)setLiveTimeStr:(NSString *)timeStr {
    _liveTimeStr = timeStr;
    self.introLab.text = _liveTimeStr;
}

//设置观看人数
- (void)setWatchNumer:(NSInteger)watchNumer {
    _watchNumer = watchNumer;
    if (watchNumer >= 10000) {
        CGFloat userNum = watchNumer/10000.0;
        _watchNumStr = [NSString stringWithFormat:@"%.2fW人观看",userNum];
    }if (watchNumer == 0) {
        _watchNumStr = @"1人观看";
    }else{
        _watchNumStr = [NSString stringWithFormat:@"%zd人观看",watchNumer];
    }
    self.watchNumLab.text = _watchNumStr;
}

//设置头像
- (void)setHeadIconStr:(NSString *)headIconStr {
    _headIconStr = headIconStr;
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:[UIModelTools httpPrefixImgUrlStr:headIconStr]] placeholderImage:BundleUIImage(@"head50")];
}

#pragma mark - UI事件
///美颜
- (void)clickBeautyBtn:(UIButton *)button
{
    button.selected = !button.selected;
    if ([self.delegate respondsToSelector:@selector(liveTopToolView:clickBeautyBtn:)]) {
        [self.delegate liveTopToolView:self clickBeautyBtn:button];
    }
}

///退出直播间
- (void)clickCloseBtn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(liveTopToolView:clickClostBtn:)]) {
        [self.delegate liveTopToolView:self clickClostBtn:button];
    }
}

///语音开关
- (void)clickVoiceBtn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(liveTopToolView:clickVoiceBtn:)]) {
        [self.delegate liveTopToolView:self clickVoiceBtn:button];
    }
}

///摄像头开关
- (void)clickVideoBtn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(liveTopToolView:clickVideoBtn:)]) {
        [self.delegate liveTopToolView:self clickVideoBtn:button];
    }
}
    
///摄像头前后切换
- (void)clickCameraSwitchBtn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(liveTopToolView:clickCameraSwitchBtn:)]) {
         [self.delegate liveTopToolView:self clickCameraSwitchBtn:button];
    }
}

#pragma mark - 懒加载
- (UIView *)introBgView
{
    if (!_introBgView)
    {
        _introBgView = [[UIView alloc] init];
        _introBgView.backgroundColor = MakeColorRGBA(0x000000,0.3);
        _introBgView.layer.cornerRadius = 18;
    }
    return _introBgView;
}
- (UILabel *)introLab
{
    if (!_introLab) {
        _introLab = [UILabel new];
        _introLab.font = FONT_FZZZ(10);
        _introLab.textColor = MakeColorRGB(0xffffff);
        _introLab.text = @"00:00:00";
    }
    return _introLab;
}
- (UILabel *)watchNumLab
{
    if (!_watchNumLab) {
        _watchNumLab = [UILabel new];
        _watchNumLab.font = FONT_FZZZ(10);
        _watchNumLab.textColor = MakeColorRGB(0xffffff);
        _watchNumLab.text = _watchNumStr;
    }
    return _watchNumLab;
}
- (UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [UIImageView new];
        _headImgView.image = BundleUIImage(@"直播");
        _headImgView.layer.cornerRadius = 15;
        _headImgView.clipsToBounds = YES;
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headImgView.backgroundColor = MakeColorRGB(0xefeff4);
    }
    return _headImgView;
}
- (UIButton *)voiceBtn
{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn setImage:BundleUIImage(@"live_topTool_voice_on") forState:UIControlStateNormal];
        [_voiceBtn setImage:BundleUIImage(@"live_topTool_voice_off") forState:UIControlStateSelected];
        [_voiceBtn addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        _voiceBtn.hidden = YES;
    }
    return _voiceBtn;
}

- (UIButton *)videoBtn
{
    if (!_videoBtn) {
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoBtn setImage:BundleUIImage(@"live_topTool_video_on") forState:UIControlStateNormal];
        [_videoBtn setImage:BundleUIImage(@"live_topTool_video_off") forState:UIControlStateSelected];
        [_videoBtn addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
        _videoBtn.hidden = YES;
    }
    return _videoBtn;
}

- (UIButton *)beautyBtn
{
    if (!_beautyBtn) {
        _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautyBtn setImage:BundleUIImage(@"live_topTool_beautys_on") forState:UIControlStateNormal];
        [_beautyBtn setImage:BundleUIImage(@"live_topTool_beautys_off") forState:UIControlStateSelected];
        [_beautyBtn addTarget:self action:@selector(clickBeautyBtn:) forControlEvents:UIControlEventTouchUpInside];
        _beautyBtn.hidden = YES;
    }
    return _beautyBtn;
}

- (UIButton *)cameraSwitchBtn
{
    if (!_cameraSwitchBtn) {
        _cameraSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraSwitchBtn setImage:BundleUIImage(@"live_topTool_cameraSwitch") forState:UIControlStateNormal];
        [_cameraSwitchBtn addTarget:self action:@selector(clickCameraSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cameraSwitchBtn.hidden = YES;
    }
    return _cameraSwitchBtn;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.imageView.contentMode = UIViewContentModeCenter;
        [_closeBtn setImage:BundleUIImage(@"icon-close") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


@end
