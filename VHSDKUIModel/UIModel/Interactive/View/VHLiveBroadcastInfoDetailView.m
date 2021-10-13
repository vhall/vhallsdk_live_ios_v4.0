//
//  VHLiveBroadcastInfoDetailView.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBroadcastInfoDetailView.h"
#import "VHKeyboardToolView.h"
#import "VHDocListVC.h"
#import "VHDocBrushPopView.h"

@interface VHLiveBroadcastInfoDetailView ()<VHLiveBroadcastInfoDetailTopViewDelegate,VHKeyboardToolViewDelegate>
/** 聊天键盘 */
@property (nonatomic, strong) VHKeyboardToolView *keyboardView;
/** 是否是主讲人 */
@property (nonatomic, assign) BOOL isSpeaker;
/** 是否是嘉宾 */
@property (nonatomic, assign) BOOL isGuest;
/// 是否横屏
@property (nonatomic , assign) BOOL screenLandscape;
/// 画笔弹窗
@property (nonatomic, strong) VHDocBrushPopView *brushView;

@end

@implementation VHLiveBroadcastInfoDetailView

- (instancetype)initWithSpeaker:(BOOL)isSpeaker guest:(BOOL)isGuest landScapeShow:(BOOL)landScapeShow;
{
    self = [super init];
    if (self) {
        self.isSpeaker = isSpeaker;
        self.isGuest = isGuest;
        self.screenLandscape = landScapeShow;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topToolView];
        [self addSubview:self.chatView];
        [self addSubview:self.bottomToolView];
        [self addSubview:self.countDownLab];
        //显示当前推流分辨率
        [self addSubview:self.resolutionLab];
        [self setupUI];
    }
    
    return self;
}

- (void)dealloc
{
    VUI_Log(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (void)setupUI
{
    [self.topToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.screenLandscape) {
            make.right.mas_equalTo(VH_KiPhoneXSeries ? -29 : 0);
            make.left.mas_equalTo(VH_KiPhoneXSeries ? 29 : 0);
        }else {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }
        make.height.mas_equalTo(LiveTopToolHeight);
        make.top.mas_equalTo(self.screenLandscape ? 20 : (VH_KStatusBarHeight + 20));
    }];
    
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(VH_KiPhoneXSeries && self.screenLandscape) {
            make.left.mas_equalTo(VH_KSystemNavBarHeight);
        }else {
            make.left.mas_equalTo(15);
        }
        make.width.mas_equalTo(300);
        make.bottom.equalTo(self.bottomToolView.mas_top).offset(-12);
        make.height.mas_equalTo(ChatViewHeight);
    }];
    
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.screenLandscape) {
            make.right.mas_equalTo(iPhoneX ? -29 : 0);
            make.left.mas_equalTo(iPhoneX ? 29 : 0);
        }else {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }
        make.height.mas_equalTo(LiveToolViewHeight);
        if(self.screenLandscape) {
            make.bottom.equalTo(self.mas_bottom).offset(-20);
        }else {
            make.bottom.equalTo(self.mas_bottom).offset(-15 - VH_KBottomSafeMargin);
        }
    }];
    
    [self.countDownLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    
    [self.resolutionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(VH_KStatusBarHeight);
        make.height.equalTo(@20);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"点击详情view");
}


//是否显示聊天view
- (void)hiddenMessageView:(BOOL)hidden {
    self.chatView.hidden = hidden;
}

//是否显示主持人头像/昵称视图
- (void)hiddenHostInfoView:(BOOL)hidden {
    self.topToolView.introBgView.hidden = hidden;
}

//设置是否切换文档演示样式的UI
- (void)showDocUI:(BOOL)docUI {
    _openDocView = docUI;
    [self.bottomToolView showDocScenceBtns:docUI];
    self.topToolView.hidden = docUI;
    if(!docUI) {
        //非文档演示，取消清屏（防止一直处于上次清屏状态）
        [self.bottomToolView cancelClear];
    }
}

//显示隐藏文档无关view(聊天列表、聊天按钮、文档列表)
- (void)hiddenDocUnRelationView:(BOOL)hidden {
    [self hiddenMessageView:hidden];
    [self.bottomToolView hiddenDocListBtn:hidden];
    [self.bottomToolView hiddenChatBtn:hidden];
}


//当前画笔弹窗是否在显示
- (BOOL)brushPopViewIsShow {
    if(_brushView && _brushView.hidden == NO) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - VHLiveBroadcastInfoDetailBootomViewDelegate
///隐藏/显示文档无关功能
- (void)liveDetailBottomView:(VHLiveBroadcastInfoDetailBootomView *)toolView hiddenDocUnRelationView:(BOOL)hidden {
    if([self.delegate respondsToSelector:@selector(liveDetailView:hiddenDocUnRelationView:)]) {
        [self.delegate liveDetailView:self hiddenDocUnRelationView:hidden];
    }
}

///说点什么
- (void)chatBtnClickToolView:(VHLiveBroadcastInfoDetailBootomView *)toolView {
    [self.keyboardView becomeFirstResponder];
}

///文档演示
- (void)documentShowBtnClickToolView:(VHLiveBroadcastInfoDetailBootomView *)toolView {
    if([self.delegate respondsToSelector:@selector(liveDetailViewOpenDocumentView:)]) {
        [self.delegate liveDetailViewOpenDocumentView:self];
    }
}

///成员列表
- (void)liveDetailBottomViewMemberBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView {
    if([self.delegate respondsToSelector:@selector(liveDetailViewOpenMemberListView:)]) {
        [self.delegate liveDetailViewOpenMemberListView:self];
    }
}

///文档选择
- (void)liveDetailBottomViewDocumentListBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView {
    if (_delegate && [_delegate respondsToSelector:@selector(liveDetailViewDocumentListBtnClick:)]) {
        [self.delegate liveDetailViewDocumentListBtnClick:self];
    }
}

///文档画笔
- (void)liveDetailBottomViewDocumentBrushBtnClick:(VHLiveBroadcastInfoDetailBootomView *)toolView showBrushView:(BOOL)show {
    if(show && ![self.delegate liveDetailViewCanBrush]) {
        VH_ShowToast(@"请先演示文档");
        return;
    }
    //文档弹窗开启
    [self.brushView showPopView:show];
    [self bringSubviewToFront:self.brushView];
    if([self.delegate respondsToSelector:@selector(brushPopView:startBrushState:)]) {
        [self.delegate brushPopView:self.brushView startBrushState:show];
    }
}

///上麦/下麦
- (void)toolView:(VHLiveBroadcastInfoDetailBootomView *)toolView upMicrophoneWithBtn:(UIButton *)button {
    if([self.delegate respondsToSelector:@selector(liveDetailView:upMicrophoneActionBtn:)]) {
        [self.delegate liveDetailView:self upMicrophoneActionBtn:button];
    }
}

///取消上麦
- (void)toolView:(VHLiveBroadcastInfoDetailBootomView *)toolView cancelMicrophoneWithBtn:(UIButton *)button {
    if([self.delegate respondsToSelector:@selector(liveDetailView:cancaelUpMicrophoneActionBtn:)]) {
        [self.delegate liveDetailView:self cancaelUpMicrophoneActionBtn:button];
    }
}


#pragma mark - VHLiveBroadcastInfoDetailTopViewDelegate

///退出按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickClostBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(liveDetaiViewClickCloseBtn:)]) {
        [self.delegate liveDetaiViewClickCloseBtn:self];
    }
}

///前后摄像头切换
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickCameraSwitchBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(liveDetaiViewClickCameraSwitchBtn:)]) {
        [self.delegate liveDetaiViewClickCameraSwitchBtn:self];
    }
}

///美颜按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickBeautyBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(liveDetaiViewClickBeautyBtn:openBeauty:)]) {
        [self.delegate liveDetaiViewClickBeautyBtn:self openBeauty:!button.selected];
    }
}

///语音按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickVoiceBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(liveDetaiViewClickMicrophoneBtn:voiceBtn:)]) {
        [self.delegate liveDetaiViewClickMicrophoneBtn:self voiceBtn:button];
    }
}

///视频按钮点击
- (void)liveTopToolView:(VHLiveBroadcastInfoDetailTopView *)topView clickVideoBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(liveDetaiViewClickCameraOpenBtn:videoBtn:)]) {
        [self.delegate liveDetaiViewClickCameraOpenBtn:self videoBtn:button];
    }
}

#pragma mark - VHKeyboardToolViewDelegate
//聊天内容发送按钮事件回调
- (void)keyboardToolView:(VHKeyboardToolView *)view sendText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(liveDetaiView:sendText:)]) {
        [self.delegate liveDetaiView:self sendText:text];
    }
}


#pragma mark - 懒加载
- (VHLiveBroadcastInfoDetailTopView *)topToolView
{
    if (!_topToolView) {
        _topToolView = [[VHLiveBroadcastInfoDetailTopView alloc] initWithScreenLandscape:self.screenLandscape];
        _topToolView.delegate = self;
    }return _topToolView;
}

- (VHLiveInfoDetailChatView *)chatView
{
    if (!_chatView) {
        _chatView = [VHLiveInfoDetailChatView new];
    }return _chatView;
}

- (VHLiveBroadcastInfoDetailBootomView *)bottomToolView
{
    if (!_bottomToolView) {
        _bottomToolView = [[VHLiveBroadcastInfoDetailBootomView alloc] initWithSpearker:self.isSpeaker guest:self.isGuest];
        _bottomToolView.delegate = self;
    }return _bottomToolView;
}


- (VHKeyboardToolView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[VHKeyboardToolView alloc] init];
        _keyboardView.delegate = self;
        [self addSubview:_keyboardView];
    }
    return _keyboardView;
}

- (UILabel *)countDownLab
{
    if (!_countDownLab) {
        _countDownLab = [[UILabel alloc] init];
        _countDownLab.backgroundColor = MakeColorRGBA(0x000000,0.3);
        _countDownLab.layer.cornerRadius = 60;
        _countDownLab.clipsToBounds = YES;
        _countDownLab.font = FONT_FZZZ(70);
        _countDownLab.textAlignment = NSTextAlignmentCenter;
        _countDownLab.textColor = [UIColor whiteColor];
        _countDownLab.hidden = YES;
    }
    return _countDownLab;
}

- (VHDocBrushPopView *)brushView
{
    if (!_brushView) {
        _brushView = [[VHDocBrushPopView alloc] initWithDelegate:self.delegate];
        [self addSubview:_brushView];
        [_brushView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(_brushView);
            if(self.screenLandscape) {
                make.right.equalTo(self).offset(-44);
            }else {
                make.right.equalTo(self).offset(-15);
            }
            make.bottom.equalTo(self.bottomToolView.mas_top).offset(-8);
        }];
    }
    return _brushView;
}


- (UILabel *)resolutionLab {
    if(!_resolutionLab) {
        _resolutionLab = [[UILabel alloc] init];
        _resolutionLab.textColor = [UIColor whiteColor];
        _resolutionLab.font = [UIFont systemFontOfSize:10];
        _resolutionLab.textAlignment = NSTextAlignmentRight;
    }
    return _resolutionLab;
}


@end

