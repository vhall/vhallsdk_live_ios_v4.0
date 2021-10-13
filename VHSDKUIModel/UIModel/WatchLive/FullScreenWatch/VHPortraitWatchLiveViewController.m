//
//  VHPortraitWatchLiveViewController.m
//  UIModel
//
//  Created by xiongchao on 2020/9/22.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "VHPortraitWatchLiveViewController.h"
#import "Masonry.h"
#import <VHLiveSDK/VHallApi.h>
#import "UIAlertController+ITTAdditionsUIModel.h"
#import "MBProgressHUD.h"
#import "VHPortraitWatchLiveDecorateView.h"
#import "VHinteractiveViewController.h"
#import "VHInvitationAlert.h"

@interface VHPortraitWatchLiveViewController () <VHallMoviePlayerDelegate,VHPortraitWatchLiveDecorateViewDelegate,VHallChatDelegate,VHinteractiveViewControllerDelegate,VHInvitationAlertDelegate> {
    BOOL _haveLoadHistoryChat; //是否已加载历史聊天记录
    BOOL _docShow; //文档是否显示
}
/** 承载文档view的父视图 */
@property (nonatomic, strong) UIView *docContentView;
/** 承载直播视频画面的父视图 */
@property (nonatomic, strong) UIView *liveVideoContentView;
/** 直播画面窗口拖拽手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *liveVideoContentViewPan;
/** 视频view上层子控件的父视图 */
@property (nonatomic, strong) VHPortraitWatchLiveDecorateView *decorateView;
/** 播放器对象 */
@property (nonatomic, strong) VHallMoviePlayer *moviePlayer;
/** 返回按钮 */
@property (nonatomic, strong) UIButton *backBtn;
/** 聊天对象 */
@property (nonatomic, strong) VHallChat *vhallChat;
/** 互动控制器 */
@property (nonatomic, strong) VHinteractiveViewController *interactiveVC;
/** 开播参数 */
@property (nonatomic, strong) NSMutableDictionary *playParam;
/** 主持人邀请上麦弹窗 */
@property (nonatomic, strong) VHInvitationAlert *invitationAlertView;

@end

@implementation VHPortraitWatchLiveViewController
- (void)dealloc
{
    NSLog(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSNotificationCenter defaultCenter] ;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //关闭设备自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //开启设备自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configFrame];
    //方式一：预加载方式
//    [self.moviePlayer preLoadRoomWithParam:self.playParam];
    //方式二：非预加载方式
    [self startPlayLive];
}

- (void)startPlayLive {
    //开播
    [self.moviePlayer startPlay:self.playParam];
}

- (void)configUI {
    [self.view addSubview:self.liveVideoContentView];
    [self.liveVideoContentView addSubview:self.moviePlayer.moviePlayerView];
    [self.view addSubview:self.decorateView];
    [self.view addSubview:self.backBtn];
}

- (void)configFrame {
    
    self.liveVideoContentView.frame = self.view.bounds;
    
    [self.moviePlayer.moviePlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liveVideoContentView);
    }];
    
    [self.decorateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(30, 30)));
        make.left.equalTo(@(15));
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(@(20));
        }
    }];
}

//加载历史聊天记录
- (void)loadHistoryChatData {
    if(_haveLoadHistoryChat == NO) {
        [_vhallChat getHistoryWithStartTime:nil pageNum:1 pageSize:20 success:^(NSArray <VHallChatModel *> *msgs) {
            [self.decorateView receiveMessage:msgs];
        } failed:^(NSDictionary *failedData) {
            NSString* errorInfo = [NSString stringWithFormat:@"%@---%@", failedData[@"content"], failedData[@"code"]];
            NSLog(@"获取历史聊天记录失败：%@",errorInfo);
        }];
        _haveLoadHistoryChat = YES;
    }
}


//停止看直播，进入互动控制器
- (void)showInteractiveVC {
    //停止看直播
    [self.moviePlayer stopPlay];
    //隐藏网速与上麦按钮
    self.decorateView.networkSpeedLab.hidden = self.decorateView.upMicBtnView.hidden = YES;
    //添加互动控制器view，放在文档上面
    [self.view insertSubview:self.interactiveVC.view aboveSubview:self.docContentView];
    if(_docContentView.hidden == NO) { //如果此时文档正显示，则互动view小窗展示
        CGAffineTransform transFrom = CGAffineTransformMakeScale(0.5, 0.5);
        _interactiveVC.view.transform = CGAffineTransformTranslate(transFrom, VHScreenWidth * 0.5, -VHScreenHeight * 0.5);
    }
    //隐藏直播view
    self.liveVideoContentView.hidden = YES;
}


#pragma mark - UI事件
- (void)backBtnClick {
    if(_interactiveVC) { //退出时，如果正在互动，需要先下麦，否则其他端成员列表还会一直显示当前用户正在上麦中
        [_interactiveVC closeButtonClick:nil];
    }
    [self.moviePlayer destroyMoivePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoContentViewPanAction:(UIPanGestureRecognizer *)pan {
    CGPoint offset = [pan translationInView:self.liveVideoContentView];
//    NSLog(@"offset = %@",NSStringFromCGPoint(offset));
    CGFloat viewWidth = self.liveVideoContentView.frame.size.width;
    CGFloat viewHeight = self.liveVideoContentView.frame.size.height;
    CGFloat centerX = MAX(viewWidth/2, MIN([UIScreen mainScreen].bounds.size.width - viewWidth/2,CGRectGetMidX(self.liveVideoContentView.frame) + offset.x));
    CGFloat centerY = MAX(viewHeight/2, MIN([UIScreen mainScreen].bounds.size.height - viewHeight/2, CGRectGetMidY(self.liveVideoContentView.frame) + offset.y));
    self.liveVideoContentView.center = CGPointMake(centerX, centerY);
    [pan setTranslation:CGPointZero inView:self.liveVideoContentView];
}


#pragma mark - VHallMoviePlayerDelegate
/**
 *  视频预加载完成可以调用播放接口
 *  activeState 预加载完成时活动状态
 *  error 为空时频预加载完成
 */
- (void)preLoadVideoFinish:(VHallMoviePlayer*)moviePlayer activeState:(VHMovieActiveState)activeState error:(NSError*)error {
    if(error) {
        NSLog(@"视频预加载失败---error = %@   活动状态 = %zd",error,activeState);
        [UIAlertController showAlertControllerTitle:@"视频预加载失败" msg:error.localizedDescription btnTitle:@"确定" callBack:nil];
    }else {
        //加载历史聊天记录
        [self loadHistoryChatData];
        NSLog(@"视频预加载完成---活动状态 = %zd",activeState);
        if(activeState == VHMovieActiveStateLive) {
            [self startPlayLive];
        }else {
            [UIAlertController showAlertControllerTitle:@"提示" msg:@"当前活动未在直播" btnTitle:@"确定" callBack:nil];
        }
    }
}

/**
 *  播放连接成功
 */
- (void)connectSucceed:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info {
    NSLog(@"播放连接成功---info = %@",info);
    //加载历史聊天记录
    [self loadHistoryChatData];
}

/**
 *  缓冲开始回调
 */
- (void)bufferStart:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info {
    NSLog(@"缓冲开始回调---info = %@",info);
    [MBProgressHUD showHUDAddedTo:self.liveVideoContentView animated:YES];
}

/**
 *  缓冲结束回调
 */
-(void)bufferStop:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info {
    NSLog(@"缓冲结束回调---info = %@",info);
    [MBProgressHUD hideHUDForView:self.liveVideoContentView animated:YES];
}

/**
 *  下载速率的回调
 *
 *  @param moviePlayer 播放器实例
 *  @param info        下载速率信息 单位kbps
 */
- (void)downloadSpeed:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info {
    NSLog(@"下载速率的回调---info = %@",info);
    NSString *netWorkSpeed = info[@"content"];
    self.decorateView.networkSpeedLab.text = [NSString stringWithFormat:@"%@kb/s",netWorkSpeed];
}

/**
 *  Streamtype
 *
 *  @param moviePlayer moviePlayer
 *  @param info        info
 */
- (void)recStreamtype:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info {
    
}

/**
 *  播放时错误的回调
 *
 *  @param livePlayErrorType 直播错误类型
 */
- (void)playError:(VHSaasLivePlayErrorType)livePlayErrorType info:(NSDictionary*)info {
    NSLog(@"播放时错误的回调livePlayErrorType = %zd---info = %@",livePlayErrorType,info);
    [MBProgressHUD hideHUDForView:self.liveVideoContentView animated:YES];
    NSString *errorStr = info[@"content"];
    [UIAlertController showAlertControllerTitle:@"提示" msg:errorStr btnTitle:@"确定" callBack:nil];
}

/**
 *  视频活动状态回调
 *
 *  @param activeState  视频活动状态
 */
- (void)ActiveState:(VHMovieActiveState)activeState {
    NSLog(@"视频活动状态回调---activeState = %zd",activeState);
}

/**
 *  获取当前视频播放模式
 *
 *  @param playMode  视频播放模式
 VHMovieVideoPlayModeNone            = 0,    //不存在
 VHMovieVideoPlayModeMedia           = 1,    //单视频
 VHMovieVideoPlayModeTextAndVoice    = 2,    //文档＋声音
 VHMovieVideoPlayModeTextAndMedia    = 3,    //文档＋视频
 VHMovieVideoPlayModeVoice           = 4,    //单音频
 */
- (void)VideoPlayMode:(VHMovieVideoPlayMode)playMode isVrVideo:(BOOL)isVrVideo {
    NSLog(@"当前视频播放模式---playMode = %ld---isVrVideo = %d",(long)playMode,isVrVideo);
}

/**
 *  获取当前视频支持的所有播放模式
 *
 *  @param playModeList 视频播放模式列表
 */
- (void)VideoPlayModeList:(NSArray*)playModeList {
    NSLog(@"获取当前视频支持的所有播放模式---playModeList = %@",playModeList);
}

/**
 *  该直播支持的清晰度列表
 *
 *  @param definitionList  支持的清晰度列表
 */
- (void)VideoDefinitionList:(NSArray*)definitionList {
    NSLog(@"该直播支持的清晰度列表---definitionList = %@",definitionList);
}

/**
 *  主播开始推流消息
 *
 *  注意：H5和互动 活动 收到此消息后建议延迟 5s 开始播放
 */
- (void)LiveStart {
    NSLog(@"主播开始推流消息");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"直播已开启" btnTitle:@"确定" callBack:^{
            [self.moviePlayer startPlay:self.playParam];
        }];
    });
}
/**
 *  直播结束消息
 *
 *  直播结束消息
 */
- (void)LiveStoped {
    [UIAlertController showAlertControllerTitle:@"提示" msg:@"直播已结束" btnTitle:@"退出" callBack:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

/**
 *  播主发布公告
 *
 *  播主发布公告消息
 */
- (void)Announcement:(NSString*)content publishTime:(NSString*)time {
    
}

/**
 *  是否允许举手申请上麦 回调。
 *  @param player         VHallMoviePlayer实例
 *  @param isInteractive  当前活动是否支持互动功能
 *  @param state          主持人是否允许举手
 */
- (void)moviePlayer:(VHallMoviePlayer *)player isInteractiveActivity:(BOOL)isInteractive interactivePermission:(VHInteractiveState)state {
    NSLog(@"是否允许举手申请上麦回调---isInteractive = %d  state = %zd",isInteractive,state);
    if (isInteractive && (state == VHInteractiveStateHave)) { //支持互动 && 允许举手 ，显示举手按钮
        self.decorateView.upMicBtnView.hidden = NO;
    } else {
        self.decorateView.upMicBtnView.hidden = YES;
    }
}

/**
 *  主持人是否同意上麦申请回调
 *  @param player       VHallMoviePlayer实例
 *  @param attributes   参数 收到的数据
 *  @param error        错误回调 nil 同意上麦 不为空为不同意上麦
 */
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitationWithAttributes:(NSDictionary *)attributes error:(NSError *)error {
    NSLog(@"主持人是否同意上麦申请回调---attributes = %@  error = %@",attributes,error);
    if(!error) {
        //显示互动控制器
        [self showInteractiveVC];
    }else {
        VH_ShowToast(@"主持人已拒绝您上麦");
    }
}

/**
 *  主持人邀请你上麦
 *  @param player       VHallMoviePlayer实例
 *  @param attributes   参数 收到的数据
 */
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitation:(NSDictionary *)attributes {
    NSLog(@"主持人邀请你上麦回调---attributes = %@",attributes);
    _invitationAlertView = [[VHInvitationAlert alloc]initWithDelegate:self tag:1000 title:@"上麦邀请" content:@"主持人邀请您上麦，是否接受？"];
    [self.view addSubview:_invitationAlertView];
}

/**
 *  被踢出
 *
 *  @param player player
 *  @param isKickout 被踢出 取消踢出后需要重新进入
 */
- (void)moviePlayer:(VHallMoviePlayer*)player isKickout:(BOOL)isKickout {
    if(isKickout) {
        if(!_interactiveVC) { //互动被踢出，_interactiveVC已有提示
            VH_ShowToast(@"您已被踢出");
        }
        [_moviePlayer destroyMoivePlayer];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  主持人显示/隐藏文档
 *
 *  @param isHave  YES 此活动有文档演示
 *  @param isShow  YES 主持人显示观看端文档，NO 主持人隐藏观看端文档
 */
- (void)moviePlayer:(VHallMoviePlayer*)player isHaveDocument:(BOOL)isHave isShowDocument:(BOOL)isShow {
    if(_docShow != isShow) {
        [ProgressHud showToast:isShow?@"主持人打开文档":@"主持人关闭文档" offsetY:80];
        _docShow = isShow;
    }

    NSLog(@"此活动是否有文档：%d，是否显示观看端文档：%d",isHave ? 1 : 0,isShow ? 1 : 0);
    if(isHave && isShow) {
        self.docContentView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.liveVideoContentView.frame = CGRectMake(VHScreenWidth - 100, 20, 90, 160);
            //文档演示时，如果正在互动，缩小互动view
            if(_interactiveVC) {
                CGAffineTransform transFrom = CGAffineTransformMakeScale(0.5, 0.5);
                _interactiveVC.view.transform = CGAffineTransformTranslate(transFrom, VHScreenWidth * 0.5, -VHScreenHeight * 0.5);
            }
        } completion:^(BOOL finished) {
            self.liveVideoContentViewPan.enabled = YES;
        }];
    }else {
        self.docContentView.hidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.liveVideoContentView.frame = self.view.bounds;
            if(_interactiveVC) {
                _interactiveVC.view.transform = CGAffineTransformIdentity;
            }
        } completion:^(BOOL finished) {
            self.liveVideoContentViewPan.enabled = NO;
        }];
    }
}

/**
*  直播文档同步，直播文档有延迟，需要返回延迟的秒数，默认为直播缓冲时间
*/
- (NSTimeInterval)documentDelayTime:(VHallMoviePlayer *)player {
    if(_interactiveVC) { //如果当前正在互动，文档不需要延迟
        return 0;
    }else { //如果当前为直播，文档需要延迟一定时间
        return player.realityBufferTime / 1000.0 + 3;
    }
}

#pragma mark - VHallChatDelegate
/**
 * 收到上下线消息
 */
- (void)reciveOnlineMsg:(NSArray <VHallOnlineStateModel *> *)msgs {
    [self.decorateView receiveMessage:msgs];
}
/**
 * 收到聊天消息
 */
- (void)reciveChatMsg:(NSArray <VHallChatModel *> *)msgs {
    [self.decorateView receiveMessage:msgs];
}
/**
 * 收到自定义消息
 */
- (void)reciveCustomMsg:(NSArray <VHallCustomMsgModel *> *)msgs {
    [self.decorateView receiveMessage:msgs];
}

/**
 * 收到被禁言/取消禁言
 */
- (void)forbidChat:(BOOL)forbidChat {
    VH_ShowToast(forbidChat?@"您已被禁言":@"您已被取消禁言");
}

/**
 * 收到全体禁言/取消全体禁言
 */
- (void)allForbidChat:(BOOL)allForbidChat {
    VH_ShowToast(allForbidChat?@"全体已被禁言":@"全体已被取消禁言");
}

#pragma mark - VHInvitationAlertDelegate
- (void)alert:(VHInvitationAlert *)alert clickAtIndex:(NSInteger)index {
    [alert removeFromSuperview];
    alert = nil;
    if(index == 1) { //接受
        [self.moviePlayer replyInvitationWithType:1 finish:nil];
        //进入互动
        [self showInteractiveVC];
    } else if(index == 0) { //拒绝
        [self.moviePlayer replyInvitationWithType:2 finish:nil];
    }
}


#pragma mark - VHPortraitWatchLiveDecorateViewDelegate
//发送消息
- (void)decorateView:(VHPortraitWatchLiveDecorateView *)decorateView sendMessage:(NSString *)messageText {
    if(_vhallChat.isAllSpeakBlocked) {
        VH_ShowToast(@"已开启全体禁言");
        return;
    }
    if(_vhallChat.isSpeakBlocked) {
        VH_ShowToast(@"您已被禁言");
        return;
    }
    
    if ([messageText isEqualToString:@""]) {
        VH_ShowToast(@"发送的消息不能为空");
        return;
    }
    
    [_vhallChat sendMsg:messageText success:^{
        
    } failed:^(NSDictionary *failedData) {
        
        NSString* text = [NSString stringWithFormat:@"%@ %@", failedData[@"code"],failedData[@"content"]];
        VH_ShowToast(text);
    }];
}

//上麦按钮点击事件
- (void)decorateView:(VHPortraitWatchLiveDecorateView *)decorateView upMicBtnClick:(UIButton *)button {
    if(_vhallChat.isAllSpeakBlocked) {
        VH_ShowToast(@"已开启全体禁言");
        return;
    }
    if(_vhallChat.isSpeakBlocked) {
        VH_ShowToast(@"您已被禁言");
        return;
    }

    button.selected = !button.selected;
    __weak typeof(self) weakSelf = self;
    if (button.selected) {
        //申请上麦
        button.userInteractionEnabled = NO;
        [_moviePlayer microApplyWithType:1 finish:^(NSError *error) {
            button.userInteractionEnabled = YES;
            if(error) {
                NSString *msg = [NSString stringWithFormat:@"申请上麦失败: %@",error.description];
                VH_ShowToast(msg);
            } else {
                VH_ShowToast(@"申请上麦成功");
                //开启上麦倒计时
                [weakSelf.decorateView.upMicBtnView countdDown:30];
            }
        }];
    } else {
        //取消上麦申请
        button.userInteractionEnabled = NO;
        [_moviePlayer microApplyWithType:0 finish:^(NSError *error) {
            button.userInteractionEnabled = YES;
            if(error) {
                NSString *msg = [NSString stringWithFormat:@"取消上麦失败: %@",error.description];
                VH_ShowToast(msg);
            } else {
                VH_ShowToast(@"已取消上麦申请");
                //停止倒计时
                [weakSelf.decorateView.upMicBtnView stopCountDown];
            }
        }];
    }
}

//上麦倒计时结束
- (void)decorateViewUpMicTimeOver:(VHPortraitWatchLiveDecorateView *)decorateView {
    //取消上麦申请
    [_moviePlayer microApplyWithType:0 finish:^(NSError *error) {
        if(error)
            NSLog(@"取消上麦失败 %@",error);
    }];
}

//指定需要判断是否响应交互事件的视图
- (UIView *)decorateViewHitTestEventView {
    if(_interactiveVC) { //如果当前正在互动，在decorateView上进行UI交互时，需要判断是否响应互动工具按钮点击
        return _interactiveVC.toolView;
    }
    if(_docContentView && _docContentView.hidden == NO) {
        //如果当前正在显示文档，在decorateView上进行UI交互时，需要判断是否响应视频view的拖拽
        return _liveVideoContentView;
    }
    return nil;
}

#pragma mark - VHinteractiveViewControllerDelegate
//自行关闭互动控制器
- (void)interactiveViewClose:(VHinteractiveViewController *_Nonnull)controller byKickOut:(BOOL)kickOut{
    [_interactiveVC.view removeFromSuperview];
    _interactiveVC = nil;
    if(kickOut) {
        [_moviePlayer destroyMoivePlayer];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        //重新开启看直播
        [self.moviePlayer startPlay:self.playParam];
        //显示网速与上麦按钮
        self.decorateView.networkSpeedLab.hidden = self.decorateView.upMicBtnView.hidden = NO;
        //重新显示直播view
        self.liveVideoContentView.hidden = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 懒加载

- (NSMutableDictionary *)playParam
{
    if (!_playParam)
    {
        _playParam = [[NSMutableDictionary alloc]init];
        _playParam[@"id"] =  _roomId;
        if (_kValue && _kValue.length>0) {
            _playParam[@"pass"] = _kValue;
        }
//        _playParam[@"name"] = [UIDevice currentDevice].name;
//        _playParam[@"email"] = [NSString stringWithFormat:@"%@@qq.com",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];

    }
    return _playParam;
}

- (UIView *)liveVideoContentView
{
    if (!_liveVideoContentView)
    {
        _liveVideoContentView = [[UIView alloc] init];
        _liveVideoContentView.backgroundColor = [UIColor blackColor];
        //直播视频拖拽手势，开启文档后，可拖拽直播视频
        _liveVideoContentViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(videoContentViewPanAction:)];
        _liveVideoContentViewPan.enabled = NO; //默认不可拖拽，文档演示时，展示视频小窗后开启
        [_liveVideoContentView addGestureRecognizer:_liveVideoContentViewPan];
    }
    return _liveVideoContentView;
}

- (VHPortraitWatchLiveDecorateView *)decorateView
{
    if (!_decorateView)
    {
        _decorateView = [[VHPortraitWatchLiveDecorateView alloc] initWithDelegate:self];
        _decorateView.backgroundColor = [UIColor clearColor];
    }
    return _decorateView;
}

- (UIButton *)backBtn
{
    if (!_backBtn)
    {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:BundleUIImage(@"返回.png") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIView *)docContentView
{
    if (!_docContentView)
    {
        _docContentView = [[UIView alloc] init];
        //添加文档view
        [_docContentView addSubview:self.moviePlayer.documentView];
        [self.moviePlayer.documentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_docContentView);
        }];
        //文档view放在直播视频view下
        [self.view insertSubview:_docContentView belowSubview:self.liveVideoContentView];
        [_docContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _docContentView;
}

- (VHallMoviePlayer *)moviePlayer
{
    if (!_moviePlayer)
    {
        _moviePlayer = [[VHallMoviePlayer alloc] initWithDelegate:self];
        _moviePlayer.movieScalingMode = VHRTMPMovieScalingModeAspectFit; //设置视频填充模式
        _moviePlayer.defaultDefinition = VHMovieDefinitionHD; //设置视频清晰度
        _moviePlayer.bufferTime = 6;  //设置缓冲时间
        
        //聊天对象初始化
        _vhallChat = [[VHallChat alloc] initWithMoviePlayer:_moviePlayer];
        _vhallChat.delegate = self;
    }
    return _moviePlayer;
}

- (VHinteractiveViewController *)interactiveVC
{
    if (!_interactiveVC)
    {
        VHinteractiveViewController *interactiveVC = [[VHinteractiveViewController alloc] init];
        interactiveVC.joinRoomPrams = self.playParam;
        interactiveVC.inavBeautifyFilterEnable = self.interactBeautifyEnable;
        interactiveVC.inav_num = self.moviePlayer.webinarInfo.inav_num;
        interactiveVC.delegate = self;
        _interactiveVC = interactiveVC;
    }
    return _interactiveVC;
}


@end
