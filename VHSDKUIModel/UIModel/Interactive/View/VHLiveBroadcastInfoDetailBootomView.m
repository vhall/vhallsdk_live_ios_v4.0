//
//  VHLiveBroadcastInfoDetailBootomView.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#define KUpMicTime 30 //上麦倒计时

#import "VHLiveBroadcastInfoDetailBootomView.h"
#import "VHLiveWeakTimer.h"

@interface VHLiveBroadcastInfoDetailBootomView ()
/** 是否为显示文档时的按钮样式场景 */
@property (nonatomic, assign) BOOL isDocScene;
/** 上麦倒计时timer */
@property (nonatomic, strong) NSTimer *countDownTimer;
/** 上麦倒计时 */
@property (nonatomic, assign) NSInteger upMicTime;
/// 聊天按钮
@property (nonatomic , strong) UIButton * chatBtn;
/** 是否为嘉宾 */
@property (nonatomic, assign) BOOL isGuest;

/** 非文档场景下工具（默认显示） */
@property (nonatomic, strong) UIView *normalBtnsView;
/** 进入文档演示 */
@property (nonatomic, strong) UIButton *docShowBtn;
/** 上/下麦按钮 */
@property (nonatomic, strong) UIButton *upMicBtn;
/** 成员列表按钮 */
@property (nonatomic, strong) UIButton *memberBtn;


/** 文档场景下的工具（默认隐藏） */
@property (nonatomic, strong) UIView *docBtnsView;
/** 清屏按钮 */
@property (nonatomic, strong) UIButton *clearBtn;
/** 文档列表按钮 */
@property (nonatomic, strong) UIButton *docListBtn;
/** 画笔按钮 */
@property (nonatomic, strong) UIButton *brushBtn;

@end

@implementation VHLiveBroadcastInfoDetailBootomView

- (instancetype)initWithSpearker:(BOOL)isSpeaker guest:(BOOL)isGuest {
    self = [super init];
    if (self) {
        _isSpeaker = isSpeaker;
        _isGuest = isGuest;
        self.upMicTime = KUpMicTime;
        [self configUI];
        [self configFrame];
    }
    return self;
}

#pragma mark --- 初始化控件
- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    //普通场景工具父视图
    [self addSubview:self.normalBtnsView];
    //文档场景工具父视图
    [self addSubview:self.docBtnsView];
    //说点什么
    [self addSubview:self.chatBtn];
}

- (void)configFrame {
    [self.normalBtnsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.height.centerY.equalTo(self);
        make.width.equalTo(self.normalBtnsView);
    }];
    [self.docBtnsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.height.centerY.equalTo(self);
        make.width.equalTo(self.docBtnsView);
    }];
    
    [self.chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(15);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(self);
    }];
    
    [self updataSubBtnFrame];
}

//更新不同场景下按钮的展示
- (void)updataSubBtnFrame {
    if(self.isSpeaker) { //主讲人才显示画笔和文档列表按钮
        _brushBtn.hidden = NO;
        _docListBtn.hidden = NO;
        [_brushBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.right.centerY.equalTo(_docBtnsView);
        }];
        
        [_docListBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.equalTo(_docBtnsView);
            make.right.equalTo(_brushBtn.mas_left).offset(-10);
        }];
        
        [_clearBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.left.equalTo(_docBtnsView);
            make.right.equalTo(_docListBtn.mas_left).offset(-10);
        }];
        
        if(_clearBtn.selected) {//当前正清屏中，隐藏文档列表按钮
            [self hiddenDocListBtn:YES];
        }
    }else { //非主讲人，只显示清屏按钮
        _brushBtn.hidden = YES;
        _docListBtn.hidden = YES;
        
        [_clearBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.left.right.equalTo(_docBtnsView);
        }];
    }
    
    if(self.isGuest) { //嘉宾端才显示上麦按钮
        _upMicBtn.hidden = NO;
        [_docShowBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.equalTo(_normalBtnsView);
            make.right.equalTo(_memberBtn.mas_left).offset(-10);
        }];
        
        [_upMicBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.left.equalTo(_normalBtnsView);
            make.right.equalTo(_docShowBtn.mas_left).offset(-10);
        }];
    }else {
        _upMicBtn.hidden = YES;
        [_docShowBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.equalTo(_normalBtnsView);
            make.right.equalTo(_memberBtn.mas_left).offset(-10);
            make.left.equalTo(_normalBtnsView);
        }];
    }
}

#pragma mark - Public
//取消画笔选择
- (void)cancelSelectBrush {
    if(self.brushBtn.selected) {
        [self btnClickAction:self.brushBtn];
    }
}

//取消清屏
- (void)cancelClear {
    if(self.clearBtn.selected) {
        [self btnClickAction:self.clearBtn];
    }
}

//设置成主讲人，显示文档列表与画笔按钮
- (void)setIsSpeaker:(BOOL)isSpeaker {
    _isSpeaker = isSpeaker;
    [self updataSubBtnFrame];
}


//是否显示文档演示时的工具按钮
- (void)showDocScenceBtns:(BOOL)isDoc {
    _isDocScene = isDoc;
    if(isDoc) {
        self.docBtnsView.hidden = NO;
        self.normalBtnsView.hidden = YES;
    }else {
        self.docBtnsView.hidden = YES;
        self.normalBtnsView.hidden = NO;
    }
}


//开始上麦倒计时
- (void)startUpMicCountDownTime {
    self.countDownTimer = [VHLiveWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
    [self.upMicBtn setImage:nil forState:UIControlStateNormal];
}

//显示/隐藏聊天按钮
- (void)hiddenChatBtn:(BOOL)hidden {
    self.chatBtn.hidden = hidden;
}

//显示/隐藏文档列表按钮
- (void)hiddenDocListBtn:(BOOL)hidden {
    self.docListBtn.hidden = hidden;
    if(self.isSpeaker) { //如果是主讲人
        [self.clearBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.centerY.left.equalTo(_docBtnsView);
            if(hidden) {
                make.right.equalTo(_brushBtn.mas_left).offset(-10);
            }else {
                make.right.equalTo(_docListBtn.mas_left).offset(-10);
            }
        }];
    }else { //非主讲人，不显示文档列表，与画笔
        self.docListBtn.hidden = YES;
    }
}

//结束倒计时 upMicSuccess：YES，上麦成功结束倒计时 NO，上麦申请超时等
- (void)endTimeByUpMicSuccess:(BOOL)upMicSuccess {
    _upMicTime = KUpMicTime;
    [self.upMicBtn setTitle:@"" forState:UIControlStateNormal];
    [self.upMicBtn setImage:BundleUIImage(@"live_bottomTool_onMic") forState:UIControlStateNormal];
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    if(upMicSuccess) {
        self.upMicBtn.selected = YES;
    }else {
        self.upMicBtn.selected = NO;
    }
}

//当前是否已上麦（上麦按钮是否选中）
- (BOOL)upMicBtnSelected {
    return self.upMicBtn.selected;
}

#pragma mark - Private

- (void)countDownAction {
    if(_upMicTime <= 0) {
        [self endTimeByUpMicSuccess:NO];
    }else {
        [self.upMicBtn setTitle:[NSString stringWithFormat:@"%zds",_upMicTime] forState:UIControlStateNormal];
        _upMicTime--;
    }
}


#pragma mark - UI事件
- (void)btnClickAction:(UIButton *)button {
    if(button == self.upMicBtn) { //上/下麦
        if(self.countDownTimer) { //当前正在上麦倒计时中，取消上麦
            if ([self.delegate respondsToSelector:@selector(toolView:cancelMicrophoneWithBtn:)]) {
                [self.delegate toolView:self cancelMicrophoneWithBtn:button];
            }
            return;
        }
        if ([self.delegate respondsToSelector:@selector(toolView:upMicrophoneWithBtn:)]) {
            [self.delegate toolView:self upMicrophoneWithBtn:button];
        }
    }else if (button == self.docShowBtn) { //文档演示
        if ([self.delegate respondsToSelector:@selector(documentShowBtnClickToolView:)]) {
            [self.delegate documentShowBtnClickToolView:self];
        }
    }else if (button == self.memberBtn) { //成员
        if ([self.delegate respondsToSelector:@selector(liveDetailBottomViewMemberBtnClick:)]) {
            [self.delegate liveDetailBottomViewMemberBtnClick:self];
        }
    }else if (button == self.clearBtn) { //隐藏文档无关功能
        if ([self.delegate respondsToSelector:@selector(liveDetailBottomView:hiddenDocUnRelationView:)]) {
            button.selected = !button.selected;
            [self.delegate liveDetailBottomView:self hiddenDocUnRelationView:button.selected];
        }
    }else if (button == self.docListBtn) { //文档选择
        if ([self.delegate respondsToSelector:@selector(liveDetailBottomViewDocumentListBtnClick:)]) {
            [self.delegate liveDetailBottomViewDocumentListBtnClick:self];
        }
    }else if (button == self.brushBtn) { //画笔
        if ([self.delegate respondsToSelector:@selector(liveDetailBottomViewDocumentBrushBtnClick:showBrushView:)]) {
            button.selected = !button.selected;
            [self.delegate liveDetailBottomViewDocumentBrushBtnClick:self showBrushView:button.selected];
        }
    }
}

- (void)chatBtnClick {
    if ([self.delegate respondsToSelector:@selector(chatBtnClickToolView:)]) {
        [self.delegate chatBtnClickToolView:self];
    }
}


#pragma mark - 懒加载
- (UIButton *)chatBtn
{
    if (!_chatBtn) {
        _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatBtn.layer.cornerRadius = LiveToolViewHeight/2.0;
        _chatBtn.backgroundColor = MakeColorRGBA(0x000000,0.3);
        _chatBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
        _chatBtn.titleLabel.font = FONT_FZZZ(14);
        [_chatBtn setTitle:@"说点什么吧…" forState:UIControlStateNormal];
        [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(chatBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatBtn;
}


- (UIView *)normalBtnsView
{
    if (!_normalBtnsView) {
        _normalBtnsView = [[UIView alloc] init];
//        _normalBtnsView.backgroundColor = [UIColor redColor];
        
        //成员列表按钮
        _memberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_memberBtn setImage:BundleUIImage(@"live_bottomTool_member") forState:UIControlStateNormal];
        [_memberBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
//        _memberBtn.layer.cornerRadius = 18;
//        _memberBtn.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.3];
        [_normalBtnsView addSubview:_memberBtn];
        [_memberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(LiveToolViewHeight));
            make.right.centerY.equalTo(_normalBtnsView);
        }];
        
        //文档按钮
        _docShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_docShowBtn setImage:BundleUIImage(@"live_bottomTool_doc") forState:UIControlStateNormal];
        [_docShowBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
//        _docShowBtn.layer.cornerRadius = 18;
//        _docShowBtn.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.3];
        [_normalBtnsView addSubview:_docShowBtn];
        
        //上下麦按钮
        _upMicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upMicBtn setImage:BundleUIImage(@"live_bottomTool_onMic") forState:UIControlStateNormal];
        [_upMicBtn setImage:BundleUIImage(@"live_bottomTool_offMic") forState:UIControlStateSelected];
        [_upMicBtn setTitleColor:MakeColorRGBA(0xFC5659,0.8) forState:UIControlStateNormal];
        _upMicBtn.titleLabel.font = FONT_FZZZ(14);
        [_upMicBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        _upMicBtn.layer.cornerRadius = 18;
        _upMicBtn.backgroundColor = MakeColorRGBA(0x000000,0.3);
        [_normalBtnsView addSubview:_upMicBtn];
    }
    
    return _normalBtnsView;
}

- (UIView *)docBtnsView
{
    if (!_docBtnsView)
    {
        _docBtnsView = [[UIView alloc] init];
        
        //画笔按钮
        _brushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_brushBtn setImage:BundleUIImage(@"live_bottomTool_docBrush") forState:UIControlStateNormal];
        [_brushBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_docBtnsView addSubview:_brushBtn];

        //文档列表按钮
        _docListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_docListBtn setImage:BundleUIImage(@"live_bottomTool_doc") forState:UIControlStateNormal];
        [_docListBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_docBtnsView addSubview:_docListBtn];
        
        //清屏按钮
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:BundleUIImage(@"live_bottomTool_clear") forState:UIControlStateNormal];
        [_clearBtn setImage:BundleUIImage(@"live_bottomTool_cancelClear") forState:UIControlStateSelected];
        [_clearBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_docBtnsView addSubview:_clearBtn];
    }
    return _docBtnsView;
}

@end
