//
//  VHPortraitWatchLiveDecorateView.m
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "VHPortraitWatchLiveDecorateView.h"
#import "Masonry.h"
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveSurveyTableViewCell.h"
#import "VHPortraitWatchLiveChatTableViewCell.h"
#import "VHKeyboardToolView.h"
@interface VHPortraitWatchLiveDecorateView () <UITableViewDelegate,UITableViewDataSource,VHKeyboardToolViewDelegate,MicCountDownViewDelegate>
{
    VHKeyboardToolView * _messageToolView;  //输入框
}
/** 网速 */
@property (nonatomic, strong) UILabel *networkSpeedLab;
/** 背景滚动视图 */
@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
/** 聊天列表 */
@property (nonatomic, strong) UITableView *chatListView;
/** 消息 */
@property (nonatomic, strong) NSMutableArray *chatDataArray;
/** 说点什么 */
@property (nonatomic, strong) UIButton *chatBtn;
/** 上麦按钮view */
@property (nonatomic, strong) MicCountDownView *upMicBtnView;

@end

@implementation VHPortraitWatchLiveDecorateView

- (void)dealloc
{
    [_upMicBtnView stopCountDown];
}

- (instancetype)initWithDelegate:(id<VHPortraitWatchLiveDecorateViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        _chatDataArray = [NSMutableArray array];
        [self configUI];
        [self configFrame];
    }
    return self;
}

- (void)configUI {
    [self addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.leftView];
    [self.bgScrollView addSubview:self.rightView];
    [self.leftView addSubview:self.networkSpeedLab];
    [self.leftView addSubview:self.chatListView];
    [self.leftView addSubview:self.chatBtn];
}

- (void)configFrame {
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.bgScrollView);
        make.height.width.equalTo(self);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.bgScrollView);
        make.left.equalTo(self.leftView.mas_right);
        make.height.width.equalTo(self);
    }];
    
    [self.networkSpeedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.equalTo(@(VH_KStatusBarHeight));
    }];
    
    [self.chatListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-50);
        make.bottom.mas_equalTo(-100);
        make.height.mas_equalTo(250);
    }];
    
    [self.chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(36);
        make.bottom.mas_equalTo(-(VH_KBottomSafeMargin + 20));
    }];
}

//设置网速
- (void)setNetSpeedText:(NSString *)speedText {
    self.networkSpeedLab.text = speedText;
}

//接收消息
- (void)receiveMessage:(NSArray *)msgArr {
    [self.chatDataArray addObjectsFromArray:msgArr];
    if(self.chatDataArray.count > 0) {
        [self.chatListView reloadData];
        [self.chatListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UI事件
//说点什么
- (void)chatBtnClick {
    _messageToolView = [[VHKeyboardToolView alloc] init];
    _messageToolView.delegate = self;
    [_messageToolView becomeFirstResponder];
    [[UIApplication sharedApplication].delegate.window addSubview:_messageToolView];
}

//上麦按钮点击事件
- (void)micUpClick:(UIButton *)btn {
    if([self.delegate respondsToSelector:@selector(decorateView:upMicBtnClick:)]) {
        [self.delegate decorateView:self upMicBtnClick:btn];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //判断是否有需要响应的交互视图
    if([self.delegate respondsToSelector:@selector(decorateViewHitTestEventView)]) {
        UIView *hitTestView = [self.delegate decorateViewHitTestEventView];
        if(hitTestView && hitTestView.userInteractionEnabled == YES && hitTestView.hidden == NO && hitTestView.alpha >= 0.01) {
            CGPoint testViewPoint = [self convertPoint:point toView:hitTestView];
            if ([hitTestView pointInside:testViewPoint withEvent:event]) {
                return [hitTestView hitTest:testViewPoint withEvent:event];
            }
        }
    }
    return [super hitTest:point withEvent:event];
}


#pragma mark VHKeyboardToolViewDelegate
- (void)keyboardToolView:(VHKeyboardToolView *)view sendText:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(decorateView:sendMessage:)]) {
        [self.delegate decorateView:self sendMessage:text];
    }
}


#pragma mark - MicCountDownViewDelegate
//倒计时结束回调
- (void)countDownViewDidEndCountDown:(MicCountDownView *)view {
    if([self.delegate respondsToSelector:@selector(decorateViewUpMicTimeOver:)]) {
        [self.delegate decorateViewUpMicTimeOver:self];
    }
}

#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatDataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.chatDataArray objectAtIndex:indexPath.row];
    static NSString * cellID = @"VHPortraitWatchLiveChatTableViewCell";
    VHPortraitWatchLiveChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[VHPortraitWatchLiveChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = model;
    return cell;
}


- (UIScrollView *)bgScrollView
{
    if (!_bgScrollView)
    {
        _bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.pagingEnabled = YES;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.backgroundColor = [UIColor clearColor];
        
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor clearColor];
        
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [UIColor clearColor];
    }
    return _bgScrollView;
}

- (UITableView *)chatListView
{
    if (!_chatListView)
    {
        _chatListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _chatListView.delegate = self;
        _chatListView.dataSource = self;
        _chatListView.backgroundColor = [UIColor clearColor];
        _chatListView.estimatedRowHeight = 45;
        _chatListView.estimatedSectionFooterHeight = 0;
        _chatListView.estimatedSectionHeaderHeight = 0;
        _chatListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _chatListView;
}

- (UILabel *)networkSpeedLab
{
    if (!_networkSpeedLab)
    {
        _networkSpeedLab = [[UILabel alloc] init];
        _networkSpeedLab.textColor = [UIColor greenColor];
        _networkSpeedLab.font = [UIFont systemFontOfSize:15];
    }
    return _networkSpeedLab;
}

- (UIButton *)chatBtn
{
    if (!_chatBtn)
    {
        _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatBtn.layer.cornerRadius = 36/2.0;
        _chatBtn.backgroundColor = MakeColorRGBA(0x000000, 0.3);
        _chatBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
        _chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_chatBtn setTitle:@"说点什么吧..." forState:UIControlStateNormal];
        [_chatBtn setTitleColor:MakeColorRGB(0xF2F2F2) forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(chatBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatBtn;
}

- (MicCountDownView *)upMicBtnView
{
    if (!_upMicBtnView)
    {
        _upMicBtnView = [[MicCountDownView alloc] init];
        [_upMicBtnView.button addTarget:self action:@selector(micUpClick:) forControlEvents:UIControlEventTouchUpInside];
        _upMicBtnView.delegate = self;
        
        [self.leftView addSubview:_upMicBtnView];
        [self.upMicBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.centerY.mas_equalTo(self.chatBtn);
        }];
    }
    return _upMicBtnView;
}

@end
