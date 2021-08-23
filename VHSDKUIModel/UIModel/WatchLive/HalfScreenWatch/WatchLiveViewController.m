//
//  WatchRTMPViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "WatchLiveViewController.h"
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"
#import "WatchLiveQATableViewCell.h"
#import "WatchLiveSurveyTableViewCell.h"
#import "WatchLiveLotteryViewController.h"
#import "VHMessageToolView.h"
#import <VHLiveSDK/VHallApi.h>
#import "MBProgressHUD.h"
#import "AnnouncementView.h"
#import "SignView.h"
#import "BarrageRenderer.h"
#import "SZQuestionItem.h"
#import "VHQuestionCheckBox.h"
#import "Reachability.h"
#import "DLNAView.h"
#import "MicCountDownView.h"
#import "VHinteractiveViewController.h"
#import "VHInvitationAlert.h"
#import "VHSurveyViewController.h"
#import "LaunchLiveViewController.h"
#import "UIAlertController+ITTAdditionsUIModel.h"
#import "MJRefresh.h"
#import "VHScrollTextView.h"
#import "Masonry.h"

# define DebugLog(fmt, ...) NSLog((@"\n[文件名:%s]\n""[函数名:%s]\n""[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

static AnnouncementView* announcementView = nil;
@interface WatchLiveViewController ()<VHallMoviePlayerDelegate, VHallChatDelegate, VHallQAndADelegate, VHallLotteryDelegate,VHallSignDelegate,VHallSurveyDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,VHMessageToolBarDelegate,MicCountDownViewDelegate,VHInvitationAlertDelegate,VHSurveyViewControllerDelegate,DLNAViewDelegate,VHWebinarInfoDelegate>
{
    VHallChat         *_chat;       //聊天
    VHallQAndA        *_QA;         //问答
    VHallLottery      *_lottery;    //抽奖
    VHallSign         *_sign;       //签到
    VHallSurvey       *_survey;      //问卷
    BarrageRenderer   *_renderer;   //弹幕
    
    UIImageView       *_logView;    //当播放音频时显示的图片
    WatchLiveLotteryViewController *_lotteryVC; //抽奖VC
    BOOL _isMute;          //是否静音
    BOOL _loadedChatHistoryList;  //是否请求过历史聊天记录
    int  _bufferCount;  //卡顿次数
    BOOL _isVr;     //是否支持vr
    BOOL _isRender; //
    BOOL _isQuestion_status; //问答开启状态
    BOOL _docShow;  //文档是否显示
    
    NSMutableArray    *_QADataArray;  //问答数据源
    NSArray           *_videoLevePicArray;//视频质量等级图片
    NSMutableArray    *_videoPlayModel;//播放模式
    NSMutableDictionary *announcementContentDic;//公告内容
    NSArray* _definitionList; //支持的分辨率
}

@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIButton *lotteryBtn; //抽奖按钮
@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *docConentView;//文档view容器
@property (weak, nonatomic) IBOutlet UIView *docAreaView;//文档显示区域
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;
@property(nonatomic,assign) BOOL     connectedNetWork;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIButton *docBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *QABtn;
@property (nonatomic, strong) UIButton *currentSelectedButton;
@property (weak, nonatomic) IBOutlet UILabel *onlineLab; //在线人数
@property (weak, nonatomic) IBOutlet UILabel *pvLab; //活动热度

@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic,assign) VHMovieVideoPlayMode playModelTemp;
@property (weak, nonatomic) IBOutlet UILabel *noDocTipTextLab; //无文档时的提示view
@property(nonatomic,strong)  Reachability     *reachAbility;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn0;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn0;
@property (nonatomic,strong) VHMessageToolView * messageToolView;  //输入框
@property (weak, nonatomic) IBOutlet UIButton *GyroBtn; //陀螺仪开关，支持vr才有效
@property (weak, nonatomic) IBOutlet UIButton *sendCustomMsgBtn; //发送自定义消息按钮

@property (weak, nonatomic) IBOutlet UIButton *fullscreenBtn;
@property (weak, nonatomic) IBOutlet UIButton *rendererOpenBtn;
@property (nonatomic, strong) NSArray *surveyResultArray;//问卷结果

@property (nonatomic, strong) NSMutableArray    *chatDataArray;
@property (weak, nonatomic) IBOutlet UIButton *dlnaBtn;
@property(nonatomic,strong)   DLNAView           *dlnaView;
@property (weak, nonatomic) IBOutlet UIButton *chatTextFieldBtn;


@property (nonatomic, strong) VHallMoviePlayer  *moviePlayer;//播放器

@property (nonatomic, strong) MicCountDownView *countDowwnView;
@property (nonatomic, strong) VHInvitationAlert *invitationAlertView;

//v4.0.0 新版问卷功能类
@property (nonatomic, strong) VHSurveyViewController *surveyController;
/// 投屏权限
@property (nonatomic , assign) BOOL   isCast_screen;
@property (nonatomic, assign) NSInteger chatListPage; //聊天记录页码，默认1
@property (nonatomic, strong) VHScrollTextView *scrollTextView;     ///<跑马灯
@end

@implementation WatchLiveViewController

#pragma mark - Lifecycle Method
- (id)init
{
    self = LoadVCNibName;
    if (self) {
        [self initDatas];
    }
    return self;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    //非预加载方式，直接播放，在收到"播放连接成功回调"后，才能使用聊天、签到等功能
    [self.moviePlayer startPlay:[self playParam]];
    //预加载视频，收到"预加载成功回调"后，即可使用聊天等功能，择机调用 startPlay 正式开播，用于开播之前使用聊天、签到等功能
//    [self.moviePlayer preLoadRoomWithParam:[self playParam]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_moviePlayer reconnectPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_moviePlayer pausePlay];

    [_countDowwnView stopCountDown];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(announcementView && !announcementView.hidden)
    {
        announcementView.content = announcementView.content;
    }
    //开启扬声器播放
    [VHallMoviePlayer audioOutput:YES];
}

-(void)viewWillLayoutSubviews
{
    if (_isVr && _GyroBtn.selected) {
        [_moviePlayer setUILayoutOrientation:[[UIDevice currentDevice]orientation]];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _moviePlayer.moviePlayerView.frame = self.backView.bounds;
    _logView.frame = _moviePlayer.moviePlayerView.bounds;
    _lotteryVC.view.frame = _showView.bounds;
    [SignView layoutView:self.view.bounds];
}


- (void)dealloc
{
    [_moviePlayer destroyMoivePlayer];
    
    if (_chat) {
        _chat = nil;
    }
    
    if (_QA) {
        _QA = nil;
    }
    
    if (_lottery) {
        _lottery = nil;
    }
    
    if (_lotteryVC) {
        [_lotteryVC.view removeFromSuperview];
        [_lotteryVC removeFromParentViewController];
        _lotteryVC = nil;
    }
    
    if (_sign) {
        _sign.delegate = nil;
    }
    if (_survey) {
        _survey.delegate = nil;
    }
    //允许自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    VHLog(@"%@ dealloc",[[self class] description]);
}


#pragma mark - Private Method

-(void)addPanGestureRecognizer
{
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [_moviePlayer.moviePlayerView addGestureRecognizer:panGesture];
}

-(void)initDatas
{
    _isMute = NO;
    _chatDataArray = [NSMutableArray array];
    _QADataArray = [NSMutableArray array];
}

- (void)initViews
{
    [self configChatViewRefreshWithBtn:self.chatBtn];
    
    _chatView.tableFooterView = [[UIView alloc] init];
    _chatView.estimatedRowHeight = 80;
    _chatView.estimatedSectionFooterHeight = 0;
    _chatView.estimatedSectionHeaderHeight = 0;

    //阻止设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];

    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
    self.view.clipsToBounds = YES;
    _moviePlayer.movieScalingMode = VHRTMPMovieScalingModeAspectFit;
    _moviePlayer.defaultDefinition = VHMovieDefinitionHD;
    _moviePlayer.bufferTime = (int)_bufferTimes;

    //_chat & QA 在播放之前初始化并设置代理
    _chat = [[VHallChat alloc] initWithMoviePlayer:_moviePlayer];
    _chat.delegate = self;
    _QA = [[VHallQAndA alloc] initWithMoviePlayer:_moviePlayer];
    _QA.delegate = self;
    _lottery = [[VHallLottery alloc] initWithMoviePlayer:_moviePlayer];
    _lottery.delegate = self;
    _sign = [[VHallSign alloc] initWithMoviePlayer:_moviePlayer];
    _sign.delegate = self;
    _survey = [[VHallSurvey alloc] initWithMoviePlayer:_moviePlayer];
    _survey.delegate = self;
    
    _logView = [[UIImageView alloc] initWithImage:BundleUIImage(@"vhallLogo")];
    _logView.backgroundColor = [UIColor whiteColor];
    _logView.contentMode = UIViewContentModeCenter;
    
    self.view.backgroundColor = [UIColor blackColor];
    _moviePlayer.moviePlayerView.frame = self.backView.bounds;
    [self.backView addSubview:_moviePlayer.moviePlayerView];
    [self.backView sendSubviewToBack:_moviePlayer.moviePlayerView];
    [_moviePlayer.moviePlayerView addSubview:_logView];    
    [self.view bringSubviewToFront:self.backView];
    
    _docConentView.hidden = YES;
    _logView.hidden = YES;
    _videoLevePicArray = @[@"原画",@"超清",@"高清",@"标清",@""];
    _videoPlayModel = [NSMutableArray array];

    [self initBarrageRenderer];
    
    //申请上麦视图
    _countDowwnView = [[MicCountDownView alloc] initWithFrame:CGRectMake(VHScreenWidth-48, VHScreenHeight-200, 40, 40)];
    [_countDowwnView.button addTarget:self action:@selector(micUpClick:) forControlEvents:UIControlEventTouchUpInside];
    _countDowwnView.delegate = self;
    [_countDowwnView hiddenCountView]; //默认隐藏上麦按钮
    [self.view addSubview:_countDowwnView];
    
    //监听网络变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:kReachabilityChangedNotification object:nil];
    _reachAbility = [Reachability reachabilityForInternetConnection];
    [_reachAbility startNotifier];
    
    self.currentSelectedButton = self.chatBtn;
}

-(void)alertWithMessage:(VHMovieVideoPlayMode)state
{
    NSString*message = nil;
    switch (state) {
        case VHMovieVideoPlayModeNone:
            message = @"无内容";
            break;
        case VHMovieVideoPlayModeMedia:
            message = @"纯视频";
            break;
        case VHMovieVideoPlayModeTextAndVoice:
            message = @"文档＋声音";
            break;
        case VHMovieVideoPlayModeTextAndMedia:
            message = @"文档＋视频";
            break;

        default:
            break;
    }
    [self showMsgInWindow:message afterDelay:2];
}

//tableView刷新设置
- (void)configChatViewRefreshWithBtn:(UIButton *)button {
    
    if(button == self.chatBtn) { //聊天
        __weak typeof(self) weakSelf = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf loadHistoryChatWithPage:weakSelf.chatListPage + 1];
        }];
        [header setTitle:@"下拉加载更多" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立即加载更多" forState:MJRefreshStatePulling];
        [header setTitle:@"暂无更多" forState:MJRefreshStateNoMoreData];
        [header setTitle:@"正在加载更多的数据中..." forState:MJRefreshStateRefreshing];
        header.lastUpdatedTimeLabel.hidden = YES;
        self.chatView.mj_header = header;

        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadHistoryChatWithPage:1];
        }];
        [footer setTitle:@"上拉刷新" forState:MJRefreshStateIdle];
        [footer setTitle:@"松开立即刷新" forState:MJRefreshStatePulling];
        [footer setTitle:@"正在刷新数据中..." forState:MJRefreshStateRefreshing];
        self.chatView.mj_footer = footer;
    }else if(button == self.QABtn) { //问答
        __weak typeof(self) weakSelf = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf loadQAListNewData];
        }];
        self.chatView.mj_header = header;
        self.chatView.mj_footer = nil;
    }
}

//弹幕
- (void)initBarrageRenderer
{
    _renderer = [[BarrageRenderer alloc]init];
    [_moviePlayer.moviePlayerView addSubview:_renderer.view];
    _renderer.canvasMargin = UIEdgeInsetsMake(20, 10,30, 10);
    // 若想为弹幕增加点击功能, 请添加此句话, 并在Descriptor中注入行为
//    _renderer.view.userInteractionEnabled = YES;
    [_moviePlayer.moviePlayerView sendSubviewToBack:_renderer.view];
}

- (NSDictionary *)playParam {
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    param[@"id"] =  _roomId;
    if (_kValue &&_kValue.length>0) {
        param[@"pass"] = _kValue;
    }
//    param[@"name"] = [UIDevice currentDevice].name;
//    param[@"email"] = [NSString stringWithFormat:@"%@@qq.com",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    return param;
}

//踢出
- (void)kickOutAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您已被踢出房间" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [_renderer stop];
        [_moviePlayer stopPlay];
        [_moviePlayer destroyMoivePlayer];
        
        UIViewController *vc = self;
        Class homeVcClass = NSClassFromString(@"VHHomeViewController");
        while (![vc isKindOfClass:homeVcClass]) {
            vc = vc.presentingViewController;
        }
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:NO completion:nil];
}


#pragma mark - 手势
//音量调节
- (void)handlePan:(UIPanGestureRecognizer*)pan
{
    float baseY = 200.0f;
    CGPoint translation = CGPointZero;
    static float volumeSize = 0.0f;
    CGPoint currentLocation = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        translation = [pan translationInView:self.view];
        volumeSize = [VHallMoviePlayer getSysVolumeSize];
    }else if(pan.state == UIGestureRecognizerStateChanged)
    {
        float y = currentLocation.y-translation.y;
        float changeSize = ABS(y)/baseY;
        if (y>0){
            [VHallMoviePlayer setSysVolumeSize:volumeSize-changeSize];
        }else{
            [VHallMoviePlayer setSysVolumeSize:volumeSize+changeSize];
        }
    }
}

//放大文档手势
- (void)changeDocSize:(UIPinchGestureRecognizer *)pinch
{
    //获取比例
    CGFloat scale = pinch.scale;
    //通过仿射变换实现缩放
    _moviePlayer.documentView.transform = CGAffineTransformScale(_moviePlayer.documentView.transform, scale, scale);
    //防止比例叠加
    pinch.scale = 1;
}

//拖拽文档手势
-(void)panDocAction:(UIPanGestureRecognizer *)pan
{
    //获取移动的大小
    CGPoint point = [pan translationInView:pan.view];
    //更改视图的中心点坐标
    CGPoint points = _moviePlayer.documentView.center;
    points.x += point.x;
    points.y += point.y;
    _moviePlayer.documentView.center = points;
    //每次都清空一下，消除坐标叠加
    [pan setTranslation:CGPointZero inView:pan.view];
}

#pragma mark - 注册通知
- (void)registerLiveNotification
{
    //已经进入活跃状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

#pragma mark - 上麦/取消上麦
- (void)micUpClick:(UIButton *)sender {
    
    if(_chat.isAllSpeakBlocked)
    {
        [self showMsgInWindow:@"已开启全体禁言" afterDelay:2];
        return;
    }

    if(_chat.isSpeakBlocked)
    {
        [self showMsgInWindow:@"您已被禁言" afterDelay:2];
        return;
    }

    sender.selected = !sender.selected;
    
    __weak typeof(self) wf = self;
    if (sender.selected) {
        
        //申请上麦
        [_moviePlayer microApplyWithType:1 finish:^(NSError *error) {
            if(error)
            {
                NSString *msg = [NSString stringWithFormat:@"申请上麦失败：%@",error.description];
                [wf showMsgInWindow:msg afterDelay:2];
            }
            else
            {
                [wf showMsgInWindow:@"申请上麦成功" afterDelay:2];
                //开启上麦倒计时
                [wf.countDowwnView countdDown:30];
            }
        }];
    }
    else {
        //取消上麦申请
        [_moviePlayer microApplyWithType:0 finish:^(NSError *error) {
            if(error)
            {
                NSString *msg = [NSString stringWithFormat:@"取消上麦失败：%@",error.description];
                [wf showMsgInWindow:msg afterDelay:2];
            }
            else
            {
                [wf showMsgInWindow:@"已取消申请" afterDelay:2];
                //停止倒计时
                [wf.countDowwnView stopCountDown];
            }
        }];
    }
}

#pragma mark - 暂停/播放按钮点击
- (IBAction)stopWatchBtnClick:(id)sender
{
    _definitionBtn0.hidden = YES;
    if (_moviePlayer.playerState == VHPlayerStatePlaying)//暂停
    {
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
        _bitRateLabel.text = @"";
        _bufferCount = 0;
        _bufferCountLabel.text = [NSString stringWithFormat:@"卡顿：%d",_bufferCount];
        _startAndStopBtn.selected = NO;
        [_moviePlayer pausePlay];
        
        if (self.playModelTemp == VHMovieVideoPlayModeTextAndVoice || self.playModelTemp == VHMovieVideoPlayModeVoice) {
            self.liveTypeLabel.text = @"已暂停音频播放";
        }
    }
    else if (_moviePlayer.playerState == VHPlayerStatePause)
    {
        [_moviePlayer reconnectPlay];
    }
    else if (_moviePlayer.playerState == VHPlayerStateStoped)
    {
        [self.moviePlayer startPlay:[self playParam]];
    }
}

#pragma mark - 小文档/大文档切换

- (IBAction)changeDocFrameBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    //还原文档缩放
    _moviePlayer.documentView.transform = CGAffineTransformIdentity;
    if(sender.selected)
    {
        _moviePlayer.documentView.frame = CGRectMake(100, 100, 160, 90);
        [self.view addSubview:_moviePlayer.documentView];
    }
    else{
        _moviePlayer.documentView.frame = self.docAreaView.bounds;
        [self.docAreaView addSubview:_moviePlayer.documentView];
    }
}

#pragma mark - 返回按钮点击
- (IBAction)closeBtnClick:(id)sender {
    [_renderer stop];
    [_moviePlayer stopPlay];
    [_moviePlayer destroyMoivePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 静音按钮点击
- (IBAction)muteBtnClick:(UIButton *)sender {
    _isMute = !_isMute;
    [_moviePlayer setMute:_isMute];
    sender.selected = _isMute;
    [VHallMoviePlayer audioOutput:YES];
    [self showMsgInWindow:_isMute ? @"已静音" : @"已取消静音" afterDelay:2];
}

#pragma mark - 视频屏幕自适应模式
- (IBAction)allScreenBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _moviePlayer.movieScalingMode = VHRTMPMovieScalingModeAspectFill;
    }else{
        _moviePlayer.movieScalingMode = VHRTMPMovieScalingModeAspectFit;
    }
    [self showMsgInWindow:[NSString stringWithFormat:@"切换裁切模式%zd",_moviePlayer.movieScalingMode] afterDelay:2];
}

#pragma mark - 详情
- (IBAction)detailsButtonClick:(UIButton *)sender {

    [self.view endEditing:YES];
    self.docConentView.hidden = YES;
    self.chatView.hidden = YES;
    self.bottomView.hidden = YES;
    _lotteryVC.view.hidden = YES;
    self.detailBtn.selected = YES;
    self.docBtn.selected = self.chatBtn.selected = self.QABtn.selected = self.lotteryBtn.selected = NO;
    self.currentSelectedButton = sender;
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {

    [self.view endEditing:YES];
    self.docConentView.hidden = NO;
    _lotteryVC.view.hidden = YES;
    self.chatView.hidden = YES;
    self.bottomView.hidden = YES;
    
    self.detailBtn.selected = self.chatBtn.selected = self.QABtn.selected = self.lotteryBtn.selected = NO;
    self.docBtn.selected = YES;
    
    self.currentSelectedButton = sender;
}

#pragma mark - 聊天
- (IBAction)chatButtonClick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [self configChatViewRefreshWithBtn:sender];
    
    self.docConentView.hidden = YES;
    _lotteryVC.view.hidden = YES;
    self.chatView.hidden = NO;
    self.sendCustomMsgBtn.hidden = NO;
    self.bottomView.hidden = NO;
    self.detailBtn.selected = self.docBtn.selected = self.QABtn.selected = self.lotteryBtn.selected = NO;
    self.chatBtn.selected = YES;
    self.currentSelectedButton = sender;
    [self.chatTextFieldBtn setTitle:@"  我来说两句" forState:UIControlStateNormal];
    
    [self reloadDataWithDataSource:_chatDataArray animated:NO];
    
    if (!_loadedChatHistoryList)
    {
        [self loadHistoryChatWithPage:1];
    }
}

//获取历史聊天记录
- (void)loadHistoryChatWithPage:(NSInteger)page {
    __weak typeof(self) weakSelf = self;
    [_chat getHistoryWithStartTime:nil pageNum:page pageSize:20 success:^(NSArray <VHallChatModel *> *msgs) {
        if(page == 1) {
            weakSelf.chatDataArray = [NSMutableArray arrayWithArray:msgs];
            weakSelf.chatListPage = 1;
            
            [weakSelf reloadDataWithDataSource:weakSelf.chatDataArray animated:YES];
            
            _loadedChatHistoryList = YES;
        }else {
            if (msgs.count > 0) {
                weakSelf.chatListPage ++;
                
                //防止获取的聊天记录与实时消息重复，需要过滤
                NSMutableArray *mutaArr = [NSMutableArray arrayWithArray:msgs];
                for(VHallChatModel *message in weakSelf.chatDataArray) {
                    for(VHallChatModel *newMessage in mutaArr.reverseObjectEnumerator) {
                        if([newMessage.msg_id isEqualToString:message.msg_id]) {
                            [mutaArr removeObject:newMessage];
                        }
                    }
                }
                
                NSRange range = NSMakeRange(0,mutaArr.count);
                [weakSelf.chatDataArray insertObjects:mutaArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                [weakSelf.chatView reloadData];
            }
        }
        [weakSelf.chatView.mj_header endRefreshing];
        [weakSelf.chatView.mj_footer endRefreshing];
    } failed:^(NSDictionary *failedData) {
        NSString* errorInfo = [NSString stringWithFormat:@"%@---%@", failedData[@"content"], failedData[@"code"]];
        NSLog(@"获取历史聊天记录失败：%@",errorInfo);
        [weakSelf.chatView.mj_footer endRefreshing];
        [weakSelf.chatView.mj_header endRefreshing];
    }];
}

#pragma mark - 我来说两句
- (IBAction)sendChatBtnClick:(id)sender
{
    if(_chat.isAllSpeakBlocked)
    {
        [self showMsgInWindow:@"已开启全体禁言" afterDelay:2];
        return;
    }

    if(_chat.isSpeakBlocked)
    {
        [self showMsgInWindow:@"您已被禁言" afterDelay:2];
        return;
    }
    
    [self.messageToolView beginTextViewInView];
}

- (VHMessageToolView *)messageToolView
{
    if (!_messageToolView)
    {
        _messageToolView = [[VHMessageToolView alloc] init];
        _messageToolView.delegate = self;
        _messageToolView.maxLength = 140;
        [self.view addSubview:_messageToolView];
    }
    return _messageToolView;
}

#pragma mark - messageToolViewDelegate
- (void)didSendText:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        [self showMsgInWindow:@"发送的消息不能为空" afterDelay:2];
        return;
    }
    __weak typeof(self) weakSelf = self;
    //发送聊天
    if (self.currentSelectedButton == _chatBtn) {
        [_chat sendMsg:text success:^{
            
            [weakSelf.messageToolView endEditing:YES];
            
        } failed:^(NSDictionary *failedData) {
            
            NSString *tipMsg = [NSString stringWithFormat:@"%@",failedData[@"content"]];
            [weakSelf showMsgInWindow:tipMsg afterDelay:2];
        }];
        
        return;
    }
    //发送问答提问
    if (self.currentSelectedButton == _QABtn) {
        
        [_QA sendMsg:text success:^{
            
            [weakSelf.messageToolView endEditing:YES];
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@",failedData[@"content"]];
            [weakSelf showMsgInWindow:code afterDelay:2];
        }];
        
        return;
    }
}


#pragma mark - 发送自定义消息
- (IBAction)customMsgBtnClick:(id)sender
{
    NSMutableDictionary * json = [NSMutableDictionary dictionary];
    json[@"key"] = @"value";
    json[@"num"] = @"0.12";
    json[@"name"] = @"小明";
    NSString * jsonStr = [UIModelTools jsonStringWithObject:json];
//    NSString *jsonStr = @"{\"key\":\"value\",\"name\":\"小明\",\"phone\":18300001111}";
    __weak typeof(self) wf = self;
    [_chat sendCustomMsg:jsonStr success:^{
        [wf showMsgInWindow:@"发送成功" afterDelay:2];
    } failed:^(NSDictionary *failedData) {
        
        NSString* tipMsg = [NSString stringWithFormat:@"%@",failedData[@"content"]];
        [wf showMsgInWindow:tipMsg afterDelay:2];
    }];
    
}


#pragma mark - 问答
- (IBAction)QAButtonClick:(UIButton *)sender {
    if (!_isQuestion_status) {
        [self showMsgInWindow:@"主播关闭了问答" afterDelay:2];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self configChatViewRefreshWithBtn:sender];

    self.docConentView.hidden = YES;
    self.sendCustomMsgBtn.hidden = YES;
    _lotteryVC.view.hidden = YES;
    self.chatView.hidden = NO;
    self.bottomView.hidden = NO;
    self.lotteryBtn.selected = self.chatBtn.selected = self.docBtn.selected = self.detailBtn.selected = NO;
    self.QABtn.selected = YES;
    self.currentSelectedButton = sender;
    [self.chatTextFieldBtn setTitle:@"  发起提问" forState:UIControlStateNormal];
    
    [self reloadDataWithDataSource:_QADataArray animated:NO];

    if(_QADataArray.count == 0) {
        [self loadQAListNewData];
    }
}


//获取问答列表
- (void)loadQAListNewData {
    __weak typeof(self) weakself = self;
    [_QA getQAndAHistoryWithType:YES success:^(NSArray<VHallQAModel *> *msgs) {
        _QADataArray = [NSMutableArray array];
        for (VHallQAModel * qaModel in msgs) {
            [_QADataArray addObject:qaModel.questionModel];

            if (qaModel.answerModels.count > 0) {
                [_QADataArray addObjectsFromArray:qaModel.answerModels];
            }
        }
        if (_QABtn.selected) {
            [self reloadDataWithDataSource:_QADataArray animated:YES];
        }
        [weakself.chatView.mj_header endRefreshing];
    } failed:^(NSDictionary *failedData) {
        NSString* tipMsg = [NSString stringWithFormat:@"%@",failedData[@"content"]];
        [weakself showMsgInWindow:tipMsg afterDelay:2];
        [weakself.chatView.mj_header endRefreshing];
    }];
}

- (void)reloadDataWithDataSource:(NSArray *)dataSource animated:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_chatView reloadData];
        if(dataSource.count > 0) {
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    });
}


#pragma mark - 抽奖
//抽奖按钮点击
- (IBAction)lotteryBtnClick:(UIButton *)sender {
    
    self.docConentView.hidden = YES;
    self.chatView.hidden = YES;
    self.bottomView.hidden = YES;
    _lotteryVC.view.hidden = NO;
    
    self.detailBtn.selected = self.docBtn.selected = self.QABtn.selected = self.chatBtn.selected = NO;
    self.lotteryBtn.selected = YES;
    self.currentSelectedButton = sender;
}

#pragma mark - 分辨率切换
- (IBAction)definitionBtnCLicked:(UIButton *)sender {
    if(!_startAndStopBtn.selected) return;
    if(_definitionList.count == 0) {
        return;
    }
    
    VHMovieDefinition _leve = _moviePlayer.curDefinition;
    BOOL isCanPlayDefinition = NO;
    
    while (!isCanPlayDefinition) {
        _leve++;
        if(_leve >= 4) {
            _leve = 0;
        }
        for (NSNumber* definition in _definitionList) {
            if(definition.intValue == _leve)
            {
                isCanPlayDefinition = YES;
                break;
            }
        }
    }
    
    if(_moviePlayer.curDefinition == _leve) {
        return;
    }
        
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    [_moviePlayer setCurDefinition:_leve];
    _playModeBtn0.selected = NO;
    [_definitionBtn0 setImage:BundleUIImage(_videoLevePicArray[_moviePlayer.curDefinition]) forState:UIControlStateNormal];
    _playModelTemp = _moviePlayer.playMode;
}

#pragma mark - 播放模式，是否纯音频直播
- (IBAction)playModeBtnCLicked:(UIButton *)sender {
    if(!_startAndStopBtn.selected) {
        [self showMsgInWindow:@"请先开始播放" afterDelay:2];
        return;
    };
    sender.selected = !sender.selected;
    
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    if (sender.selected)
    {
        _playModelTemp = VHMovieVideoPlayModeVoice;
        _playModeBtn0.selected = YES;
        [_moviePlayer setCurDefinition:VHMovieDefinitionAudio];
        _logView.hidden = NO;
        _liveTypeLabel.text = @"音频播放中";
        _definitionBtn0.hidden = YES;
        [self showMsgInWindow:@"已切换为音频播放" afterDelay:2];
    }else
    {
        _playModeBtn0.selected = NO;
        _playModelTemp = VHMovieVideoPlayModeMedia;
        [_moviePlayer setCurDefinition:VHMovieDefinitionOrigin];
        _logView.hidden = YES;
        _liveTypeLabel.text = @"";
        _definitionBtn0.hidden = NO;
        [self showMsgInWindow:@"已切换为视频播放" afterDelay:2];
    }
}

#pragma mark - 弹幕开关
- (IBAction)barrageBtnClick:(id)sender
{
    _rendererOpenBtn.selected = !_rendererOpenBtn.selected;
    if (_rendererOpenBtn.selected)
    {
        [_renderer start];
        [self showMsgInWindow:@"已开启弹幕" afterDelay:2];
    }else
    {
        [_renderer stop];
        [self showMsgInWindow:@"已关闭弹幕" afterDelay:2];
    }
    
}

#pragma mark - 陀螺开关

- (IBAction)startGyroClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_moviePlayer setUsingGyro:YES];
        [self showMsgInWindow:@"已开启陀螺仪" afterDelay:2];
    }else {
        [_moviePlayer setUsingGyro:NO];
        [self showMsgInWindow:@"已关闭陀螺仪" afterDelay:2];
    }
}


#pragma mark  网络变化

- (void)networkChange:(NSNotification *)notification {
    Reachability *currReach = [notification object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    //如果没有连接到网络就弹出提醒实况
    if(status == NotReachable)
    {
        _connectedNetWork =NO;
        return;
    }
    if (status == ReachableViaWiFi || status == ReachableViaWWAN) {
        if ((_connectedNetWork == NO) && _moviePlayer) {
            [_moviePlayer reconnectSocket];
        }
        _connectedNetWork =YES;
        
    }
}

#pragma mark - 切换横竖屏
- (IBAction)fullscreenBtnClicked:(UIButton*)sender {

    sender.selected = !sender.selected;
    if(sender.selected) { //横屏
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    } else { //退出横屏
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - 投屏

- (IBAction)DlNAClick:(id)sender
{
    if (!self.isCast_screen) {
        [self showMsg:@"无投屏权限，如需使用请咨询您的销售人员或拨打客服电话：400-888-9970" afterDelay:2];
        return;
    }
    if(![self.dlnaView showInView:self.view moviePlayer:_moviePlayer])
    {
        [self showMsg:@"投屏失败，投屏前请确保当前视频正在播放" afterDelay:2];
        return;
    }
    
    [_moviePlayer pausePlay];
    
    __weak typeof(self)wf = self;
    self.dlnaView.closeBlock = ^{
        [wf.moviePlayer reconnectPlay];
    };
}

//投屏代理回调 DLNAViewDelegate
- (void)dlnaControlState:(DLNAControlStateType)type errormsg:(NSString *)msg
{
    [self showMsg:msg afterDelay:2];
}

-(DLNAView *)dlnaView
{
    if (!_dlnaView) {
        _dlnaView = [[DLNAView alloc] initWithFrame:self.view.bounds];
        _dlnaView.delegate = self;
    }
    return _dlnaView;
}

#pragma mark - tableView 代理方法
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
  __weak  typeof(self) weakSelf =self;
    if (_chatBtn.selected)
    {
        id model = [_chatDataArray objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[VHallOnlineStateModel class]]) //上下线消息
        {
            static NSString * indetify = @"WatchLiveOnlineCell";
            cell = [tableView dequeueReusableCellWithIdentifier:indetify];
            if (!cell) {
                cell = [[WatchLiveOnlineTableViewCell alloc]init];
            }
            ((WatchLiveOnlineTableViewCell *)cell).model = model;
        } else if([model isKindOfClass:[VHallSurveyModel class]]) //问卷消息
        {
            static NSString * indetify = @"WatchLiveSurveyTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:indetify];
            if (!cell) {
                cell = [[WatchLiveSurveyTableViewCell alloc]init];
            }
            ((WatchLiveSurveyTableViewCell *)cell).model = model;
            ((WatchLiveSurveyTableViewCell *)cell).clickSurveyItem=^(VHallSurveyModel *model) {
                [weakSelf performSelector:@selector(clickSurvey:) withObject:model];
            };
        }
        else //聊天消息
        {
            static NSString * indetify = @"WatchLiveChatCell";
            cell = [tableView dequeueReusableCellWithIdentifier:indetify];
            if (!cell) {
                cell = [[WatchLiveChatTableViewCell alloc]init];
            }
            ((WatchLiveChatTableViewCell *)cell).model = model;
        }
    }
    else if (_QABtn.selected)
    {//问答消息
        static NSString * qaIndetify = @"WatchLiveQACell";
        cell = [tableView dequeueReusableCellWithIdentifier:qaIndetify];
        if (!cell) {
            cell = [[WatchLiveQATableViewCell alloc]init];
        }
        ((WatchLiveQATableViewCell *)cell).model = [_QADataArray objectAtIndex:indexPath.row];
    }
    else
    {
        static NSString * qaIndetify = @"identifiCell";
        cell = [tableView dequeueReusableCellWithIdentifier:qaIndetify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:qaIndetify];
        }
    }
    return cell;
}



- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (_chatBtn.selected) {
    
        return _chatDataArray.count;
    }
    
    if (_QABtn.selected) {
        return _QADataArray.count;
    }
    return 0;
}


#pragma mark - VHMoviePlayerDelegate
- (void)preLoadVideoFinish:(VHallMoviePlayer*)moviePlayer activeState:(VHMovieActiveState)activeState error:(NSError*)error
{
    if(error) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@（%zd）",error.localizedDescription,error.code];
        [UIAlertController showAlertControllerTitle:@"预加载视频信息失败" msg:errorMsg btnTitle:@"确定" callBack:nil];
    }else {
        if(activeState == VHMovieActiveStateLive) { //直播中
            //预加载完成后，可以使用聊天等功能，如：获取聊天记录
            [self chatButtonClick:self.chatBtn];
            //预加载完成后，择机调用播放
            [self.moviePlayer startPlay:[self playParam]];
            
        } else { //非直播
            [UIAlertController showAlertControllerTitle:@"提示" msg:@"当前活动未在直播" btnTitle:@"确定" callBack:nil];
        }
    }
}

- (void)moviePlayer:(VHallMoviePlayer *)player statusDidChange:(VHPlayerState)state
{
    if(state == VHPlayerStatePlaying) {
        _startAndStopBtn.selected = YES;
    }
}

//播放连接成功
- (void)connectSucceed:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    VHLog(@"播放连接成功：%@",info);
    VHWebinarInfo *webinarInfo = self.moviePlayer.webinarInfo;
    webinarInfo.delegate = self;
    if(webinarInfo) {
        if(webinarInfo.online_show) {
            self.onlineLab.text = [NSString stringWithFormat:@"在线人数（真实人数：%zd，虚拟人数：%zd）",webinarInfo.online_real,webinarInfo.online_virtual];
        }else {
            self.onlineLab.text = @"";
        }
        if(self.moviePlayer.webinarInfo.pv_show) {
            self.pvLab.text = [NSString stringWithFormat:@"活动热度（真实热度：%zd，虚拟热度：%zd）",webinarInfo.pv_real,webinarInfo.pv_virtual];
        }else {
            self.pvLab.text = @"";
        }
        
        if(webinarInfo.scrollTextInfo.scrolling_open == 1) { //开启跑马灯
            
            VHScrollTextView *scrollTextView = [[VHScrollTextView alloc] init];
            [moviePlayer.moviePlayerView addSubview:scrollTextView];
            [scrollTextView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(moviePlayer.moviePlayerView);
            }];
            [scrollTextView showScrollTextWithModel:webinarInfo.scrollTextInfo];
        }
    }
    //获取聊天记录
    [self chatButtonClick:self.chatBtn];
}

-(void)bufferStart:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    _bufferCount++;
    _bufferCountLabel.text = [NSString stringWithFormat:@"卡顿：%d",_bufferCount];
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
}

-(void)bufferStop:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
}

-(void)downloadSpeed:(VHallMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
}

- (void)recStreamtype:(VHallMoviePlayer*)moviePlayer info:(NSDictionary*)info
{
    VHStreamType streamType = (VHStreamType)[info[@"content"] intValue];
    if (streamType == VHStreamTypeVideoAndAudio) {
        _logView.hidden = YES;
    } else if(streamType == VHStreamTypeOnlyAudio){
        _logView.hidden = NO;
    }
}

- (void)playError:(VHSaasLivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;
{
    NSLog(@"播放时错误的回调livePlayErrorType = %zd---info = %@",livePlayErrorType,info);
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    NSString *errorStr = info[@"content"];
    NSInteger code = [info[@"code"] integerValue];
    
    [UIAlertController showAlertControllerTitle:@"提示" msg:[NSString stringWithFormat:@"%zd-%@",code,errorStr] btnTitle:@"确定" callBack:^{
        if(code == 20023) { //同一账号多端观看
            [_moviePlayer stopPlay];
            [_moviePlayer destroyMoivePlayer];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

//当前视频播放模式回调
-(void)VideoPlayMode:(VHMovieVideoPlayMode)playMode isVrVideo:(BOOL)isVrVideo
{
    _isVr = isVrVideo;
    if (!_isRender)
    {
        if (isVrVideo)
        {
            _GyroBtn.hidden = NO;
            _GyroBtn.selected = YES;
//            [_moviePlayer setRenderViewModel:VHRenderModelDewarpVR];
            [_moviePlayer setUsingGyro:YES];
        }else {
            _GyroBtn.hidden = YES;
            _GyroBtn.selected = NO;
//            [_moviePlayer setRenderViewModel:VHRenderModelOrigin];
            [_moviePlayer setUsingGyro:NO];
            [self addPanGestureRecognizer];
        }
        _isRender = YES;
    }

    
    VHLog(@"当前视频播放模式---%ld",(long)playMode);
    self.liveTypeLabel.text = @"";
    _playModelTemp = playMode;
    switch (playMode) {
        case VHMovieVideoPlayModeNone:
        case VHMovieVideoPlayModeMedia:
        case VHMovieVideoPlayModeTextAndMedia:
            _playModeBtn0.selected = NO;
            _playModeBtn0.enabled = YES;
            break;
        case VHMovieVideoPlayModeTextAndVoice:
        case VHMovieVideoPlayModeVoice:
        {
            self.liveTypeLabel.text = @"语音直播中";
        }
            _playModeBtn0.enabled = NO;
            break;
        default:
            break;
    }

    [self alertWithMessage:playMode];
}

- (void)VideoPlayModeList:(NSArray*)playModeList
{
    for (NSNumber *playMode in playModeList) {
        switch ([playMode intValue]) {
            case VHMovieVideoPlayModeMedia:
                [_videoPlayModel addObject:@"1"];
                break;
            case VHMovieVideoPlayModeTextAndVoice:
                [_videoPlayModel addObject:@"2"];
                break;
            case VHMovieVideoPlayModeTextAndMedia:
                [_videoPlayModel addObject:@"3"];
                break;
            case VHMovieVideoPlayModeVoice:
                [_videoPlayModel addObject:@"4"];
                break;
            default:
                break;
        }
    }
}

- (void)ActiveState:(VHMovieActiveState)activeState
{
    VHLog(@"activeState-%ld",(long)activeState);
}

//该直播支持的清晰度(分辨率)列表
- (void)VideoDefinitionList:(NSArray*)definitionList
{
    VHLog(@"可用分辨率%@ 当前分辨率：%ld",definitionList,(long)_moviePlayer.curDefinition);
    _definitionList = definitionList;
    _definitionBtn0.hidden = NO;
    [_definitionBtn0 setImage:BundleUIImage(_videoLevePicArray[_moviePlayer.curDefinition]) forState:UIControlStateNormal];
    if (_moviePlayer.curDefinition == VHMovieDefinitionAudio) {
        _playModelTemp = VHMovieVideoPlayModeVoice;
        _playModeBtn0.selected = YES;
        _liveTypeLabel.text = @"音频播放中";
        _definitionBtn0.hidden = YES;
    }
}

//直播开始回调
- (void)LiveStart{
    VHLog(@"LiveStart");
    __weak typeof(self) wf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"直播已开始" btnTitle:@"确定" callBack:^{
            [wf.moviePlayer startPlay:[wf playParam]];
        }];
    });
}

- (void)LiveStartDefinition
{
    
}

//直播已结束回调
- (void)LiveStoped
{
    VHLog(@"直播已结束");
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    _startAndStopBtn.selected = NO;
    [_moviePlayer stopPlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"直播已结束" btnTitle:@"确定" callBack:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    });
}

// 主持人是否允许举手
- (void)moviePlayer:(VHallMoviePlayer *)player isInteractiveActivity:(BOOL)isInteractive interactivePermission:(VHInteractiveState)state
{
    //显示举手按钮
    if (isInteractive && state == VHInteractiveStateHave) {
        [_countDowwnView showCountView];
    } else { //隐藏举手按钮
        [_countDowwnView hiddenCountView];
    }
}

// 主持人同意上麦回调
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitationWithAttributes:(NSDictionary *)attributes error:(NSError *)error {
    
    if (!error) {
        //退出全屏
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
//        [self rotateScreen:NO];
        _fullscreenBtn.selected = NO;
        //进入互动
        VHinteractiveViewController *controller = [[VHinteractiveViewController alloc] init];
        controller.joinRoomPrams = [self playParam];
        controller.pushResolution = self.interactResolution;
        controller.inavBeautifyFilterEnable = self.interactBeautifyEnable;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    }
}
// 主持人邀请你上麦
- (void)moviePlayer:(VHallMoviePlayer *)player microInvitation:(NSDictionary *)attributes
{
    _invitationAlertView = [[VHInvitationAlert alloc]initWithDelegate:self tag:1000 title:@"上麦邀请" content:@"主持人邀请您上麦，是否接受？"];
    [self.view addSubview:_invitationAlertView];
}
- (void)moviePlayer:(VHallMoviePlayer*)player isKickout:(BOOL)isKickout
{
    VHLog(@"您已被踢出");
    _startAndStopBtn.selected = NO;
    
    [self kickOutAction];
}
- (void)moviePlayer:(VHallMoviePlayer *)player isCast_screen:(BOOL)isCast_screen
{
    self.isCast_screen = isCast_screen;
}
- (void)moviePlayer:(VHallMoviePlayer *)player isQuestion_status:(BOOL)isQuestion_status
{
    _isQuestion_status = isQuestion_status;
}

- (void)moviePlayer:(VHallMoviePlayer*)player isHaveDocument:(BOOL)isHave isShowDocument:(BOOL)isShow
{
    if(isHave)
    {
        if(_docShow != isShow) {
            [self showMsgInWindow:isShow ? @"主持人打开文档" : @"主持人关闭文档" afterDelay:2];
            _docShow = isShow;
        }
        _moviePlayer.documentView.frame = self.docAreaView.bounds;
        [self.docAreaView addSubview:_moviePlayer.documentView];
    }
    _moviePlayer.documentView.hidden = !isShow;
    self.noDocTipTextLab.hidden = isShow;
    
    _moviePlayer.documentView.userInteractionEnabled = YES;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDocAction:)];
    [_moviePlayer.documentView addGestureRecognizer:pan];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(changeDocSize:)];
    [_moviePlayer.documentView addGestureRecognizer:pinch];
}

//返回文档延迟时间
- (NSTimeInterval)documentDelayTime:(VHallMoviePlayer *)player {
    return player.realityBufferTime / 1000.0 + 3;
}


#pragma mark - VHWebinarInfoDelegate
//房间人数改变回调
- (void)onlineChangeRealNum:(NSUInteger)online_real virtualNum:(NSUInteger)online_virtual {
    self.onlineLab.text = [NSString stringWithFormat:@"在线人数（真实人数：%zd，虚拟人数：%zd）",online_real,online_virtual];
}

#pragma mark - VHInvitationAlertDelegate
- (void)alert:(VHInvitationAlert *)alert clickAtIndex:(NSInteger)index
{
    [alert removeFromSuperview];
    alert = nil;
    if(index == 1)
    {
        [self.moviePlayer replyInvitationWithType:1 finish:nil];
        
        //退出全屏
//        [self rotateScreen:NO];
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
        _fullscreenBtn.selected = NO;
        
        //进入互动
        VHinteractiveViewController *controller = [[VHinteractiveViewController alloc] init];
        controller.joinRoomPrams = [self playParam];
        controller.pushResolution = self.interactResolution;
        controller.inavBeautifyFilterEnable = self.interactBeautifyEnable;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
    else if(index == 0)
    {
        [self.moviePlayer replyInvitationWithType:2 finish:nil];
    }
}
#pragma mark - MicCountDownViewDelegate
//举手倒计时结束回调
- (void)countDownViewDidEndCountDown:(MicCountDownView *)view {
    //取消上麦申请
    [_moviePlayer microApplyWithType:0 finish:^(NSError *error) {
        if(error)
            NSLog(@"取消申请上麦失败 %@",error.domain);
    }];
}

#pragma mark - 公告
- (void)Announcement:(NSString*)content publishTime:(NSString*)time
{
    VHLog(@"公告:%@",content);
    if (!announcementContentDic)
    {
        announcementContentDic = [[NSMutableDictionary alloc] init];
    }
    [announcementContentDic setObject:content forKey:@"announceContent"];
    [announcementContentDic setObject:time forKey:@"announceTime"];
    
    if(!announcementView)
    { //横屏时frame错误
        if (_showView.width < [UIScreen mainScreen].bounds.size.height)
        {
            announcementView = [[AnnouncementView alloc]initWithFrame:CGRectMake(0, 0, _showView.width, 35) content:content time:nil];
        }else {
            announcementView = [[AnnouncementView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 35) content:content time:nil];
        }
    }
    announcementView.content = [content stringByAppendingString:time];
    [_showView addSubview:announcementView];
}


#pragma mark - 抽奖相关
//-----------VHallLotteryDelegate-------------
//开始抽奖
- (void)startLottery:(VHallStartLotteryModel *)msg
{
    if (_lotteryVC) {
        [_lotteryVC.view removeFromSuperview];
        [_lotteryVC removeFromParentViewController];
        _lotteryVC = nil;
    }
    
    _lotteryVC = [[WatchLiveLotteryViewController alloc] init];
    _lotteryVC.lottery = _lottery;
    _lotteryVC.startLotteryModel = msg;
    _lotteryVC.view.frame = _showView.bounds;
    [_showView addSubview:_lotteryVC.view];
    
    [self lotteryBtnClick:self.lotteryBtn];
}

//结束抽奖
- (void)endLottery:(VHallEndLotteryModel *)msg
{
    if (!_lotteryVC) {
        _lotteryVC = [[WatchLiveLotteryViewController alloc] init];
        _lotteryVC.lottery = _lottery;
        _lotteryVC.view.frame = _showView.bounds;
        [_showView addSubview:_lotteryVC.view];
    }
    _lotteryVC.endLotteryModel = msg;
    [self lotteryBtnClick:self.lotteryBtn];
}


#pragma mark - IM消息相关
- (void)reciveOnlineMsg:(NSArray <VHallOnlineStateModel *> *)msgs
{
    [self reloadDataWithMsg:msgs];
}

- (void)reciveChatMsg:(NSArray <VHallChatModel *> *)msgs
{
    [self reloadDataWithMsg:msgs];
    if (msgs.count > 0) {
        //弹幕
        VHallChatModel* model = [msgs objectAtIndex:0];
        BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        descriptor.params[@"text"] = model.text;
        descriptor.params[@"textColor"] = MakeColorRGB(0xffffff);//MakeColor(random()%255, random()%255, random()%255, 1);
        //@(100 * (double)random()/RAND_MAX+50) 随机速度
        descriptor.params[@"speed"] = @(100);// 固定速度
        descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
        descriptor.params[@"side"] = @(BarrageWalkSideDefault);
//        descriptor.params[@"clickAction"] = ^{
//        };
        [_renderer receive:descriptor];
    }
}

- (void)reciveCustomMsg:(NSArray <VHallCustomMsgModel *> *)msgs
{
    [self reloadDataWithMsg:msgs];
}

- (void)forbidChat:(BOOL) forbidChat
{
    [self showMsg:forbidChat?@"您已被禁言":@"您已被取消禁言" afterDelay:2];
}

- (void)allForbidChat:(BOOL) allForbidChat
{
    [self showMsg:allForbidChat?@"已开启全体禁言":@"已取消全体禁言" afterDelay:2];
}


//-----------聊天私有方法------------
- (void)reloadDataWithMsg:(NSArray *)msgs {
    if (msgs.count == 0) {
        return;
    }
    [_chatDataArray addObjectsFromArray:msgs];
    if (_chatBtn.selected) {
        [self reloadDataWithDataSource:_chatDataArray animated:YES];
    }
}

#pragma mark - 问答相关
//----------------VHallQAndADelegate------------------
//主播开启问答
- (void)vhallQAndADidOpened:(VHallQAndA *)QA
{
    [self showMsgInWindow:@"主播开启了问答" afterDelay:2];
    _isQuestion_status = YES;
}

//主播关闭问答
- (void)vhallQAndADidClosed:(VHallQAndA *)QA
{
    [self showMsgInWindow:@"主播关闭了问答" afterDelay:2];
    [self chatButtonClick:self.chatBtn];
    _isQuestion_status = NO;
}

//收到问答
- (void)reciveQAMsg:(NSArray <VHallQAModel *> *)msgs
{
    for (VHallQAModel *qaModel in msgs) {
        //添加问题
        [_QADataArray addObject:qaModel.questionModel];
        if(qaModel.answerModels.count > 0) { //如果有回答
            BOOL showAnswer = NO; //是否有可显示的回答
            for(VHallAnswerModel *answer in qaModel.answerModels) {
                if(answer.is_open == YES || [qaModel.questionModel.join_id isEqualToString:self.moviePlayer.webinarInfo.join_id]) { // 公开的回答 || 私密回答自己的提问
                    [_QADataArray addObject:answer];
                    showAnswer = YES;
                }
            }
            if(showAnswer == NO) { //如果没有可显示的回答，则不添加问题
                [_QADataArray removeObject:qaModel.questionModel];
            }
        }
    }
    
    if (_QABtn.selected) {
        [self reloadDataWithDataSource:_QADataArray animated:YES];
    }
}

#pragma mark - 签到相关
//--------------VHallSignDelegate----------------
//签到开始的回调
- (void)startSign {
    __weak typeof(self) weakSelf = self;
    [SignView showSignWithTitle:_sign.title btnClickedBlock:^BOOL{
        [weakSelf SignBtnClicked];
        return NO;
    }];
}

//签到倒计时的回调
- (void)signRemainingTime:(NSTimeInterval)remainingTime
{
    NSLog(@"距结束%d秒",(int)remainingTime);
    [SignView remainingTime:remainingTime];
}

//签到结束的回调
- (void)stopSign
{
    [SignView close];
    [self showMsgInWindow:@"签到结束" afterDelay:2];
}

//----------------签到私有方法-----------------
//请求开始签到接口
- (void)SignBtnClicked {
    __weak typeof(self) weakSelf = self;
    [_sign signSuccessIsStop:YES success:^{
      [SignView close];
      [weakSelf showMsgInWindow:@"签到成功" afterDelay:2];
    } failed:^(NSDictionary *failedData) {
        [weakSelf showMsgInWindow:[NSString stringWithFormat:@"%@,错误码%@",failedData[@"content"],failedData[@"code"]] afterDelay:2];
        [_sign cancelSign];
        [SignView close];
    }];
}

#pragma mark -  问卷相关
//----------VHallSurveyDelegate------------
//flsh活动，发布问卷以下两个方法都会回调。如果使用webView的方式加载问卷，在-receivedSurveyWithURL:处理，如果仍保留旧版加载问卷方式，在-receiveSurveryMsgs:方法处理，处理方式不变。H5活动发布问卷，只回调-receivedSurveyWithURL：。

- (void)receivedSurveyWithURL:(NSURL *)surveyURL
{
    VHallSurveyModel *model = [[VHallSurveyModel alloc] init];
    model.surveyURL = surveyURL;
    [_chatDataArray addObject:model];//添加问卷消息到聊天列表

    if (_chatBtn.selected) {
        [self reloadDataWithDataSource:_chatDataArray animated:YES];
    }
}

- (void)receiveSurveryMsgs:(NSArray*)msgs {
    
}

//----------------VHSurveyViewControllerDelegate--------------

- (void)surveyviewControllerDidCloseed:(UIButton *)sender {
    [_surveyController.view removeFromSuperview];
    _surveyController = nil;
}

- (void)surveyViewControllerWebViewDidClosed:(VHSurveyViewController *)vc {
    [_surveyController.view removeFromSuperview];
    _surveyController = nil;
}

//提交成功
- (void)surveyViewControllerWebViewDidSubmit:(VHSurveyViewController *)vc msg:(NSDictionary *)body {
    [_surveyController.view removeFromSuperview];
    _surveyController = nil;
    [self showMsgInWindow:@"提交成功" afterDelay:2];
}

//--------点击展示问卷-------
// 显示问卷详情
- (void)clickSurvey:(VHallSurveyModel *)model
{
    if (![VHallApi isLoggedIn]) {
        [self showMsgInWindow:@"请登录" afterDelay:2];
        return;
    }
    
    //v4.0.0 及以上 使用webview 加载h5问卷详情
    if (model.surveyURL)
    {
        if (!_surveyController) {
            _surveyController = [[VHSurveyViewController alloc] init];
            _surveyController.delegate = self;
        }
        _surveyController.view.frame = self.view.bounds;
        _surveyController.url = model.surveyURL;
        [self.view addSubview:_surveyController.view];
    }
    // v4.0.0 版本以下
    else
    {
        //方式一：原生
//        __weak typeof(self) weakSelf =self;
//        self.fullscreenBtn.enabled =NO;
//        [_survey getSurveryContentWithSurveyId:model.surveyId webInarId:_roomId success:^(VHallSurvey *survey) {
//            weakSelf.fullscreenBtn.enabled = YES;
//            [weakSelf showSurveyVCWithSruveyModel:survey];
//        } failed:^(NSDictionary *failedData) {
//            weakSelf.fullscreenBtn.enabled = YES;
//            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//        }];
        
        //方式二：web页嵌入
        //如果未升级SDK，但是需要使用webView的方式展示问卷，使用以下方式加载。如不使用webView的方式仍使用以上方法即可。
        NSURL *surveyURL = [self surveyURLWithRoomId:self.roomId model:model];
        if (!_surveyController) {
            _surveyController = [[VHSurveyViewController alloc] init];
            _surveyController.delegate = self;
        }
        _surveyController.view.frame = self.view.bounds;
        _surveyController.url = surveyURL;
        [self.view addSubview:_surveyController.view];
    }
}

//原生调查问卷页面
-(void)showSurveyVCWithSruveyModel:(VHallSurvey*)survey
{
//    __weak typeof(self) weakSelf =self;
    NSMutableArray *titleArray=[[NSMutableArray alloc] init];
    NSMutableArray *optionArray=[[NSMutableArray alloc] init];
    NSMutableArray *typeArry  =[[NSMutableArray alloc] init];
    NSMutableArray *isMustSelectArray = [[NSMutableArray alloc] init];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_orderNum" ascending:NO];
    survey.questionArray =[survey.questionArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    for (VHallSurveyQuestion *question in survey.questionArray)
    {
        // 选项类型 （0问答 1单选 2多选）
        if (question.type == 0)
        {
            [typeArry addObject:@(3)];
        }else if (question.type ==1)
        {
            [typeArry addObject:@(1)];
        }else if (question.type ==2)
        {
            [typeArry addObject:@(2)];
        }
        else
            continue;
        [titleArray addObject:question.questionTitle];

        if (question.quesionSelectArray !=nil)
        {
            [optionArray addObject:question.quesionSelectArray];
        }else
        {
            [optionArray addObject:@[]];
        }

        if (question.isMustSelect)
        {
            [isMustSelectArray addObject:@"1"];
        }else
        {
            [isMustSelectArray addObject:@"0"];
        }
    }
    //    NSArray *resultArray =[[NSMutableArray alloc] init];
    SZQuestionItem *item = [[SZQuestionItem alloc] initWithTitleArray:titleArray andOptionArray:optionArray andResultArray:self.surveyResultArray andQuestonTypes:typeArry isMustSelectArray:isMustSelectArray];
    VHQuestionCheckBox *questionBox=[[VHQuestionCheckBox alloc] initWithItem:item];
    questionBox.survey = survey;
    [self presentViewController:questionBox animated:YES completion:^{
        
    }];
}


- (void)outputDeviceChanged:(NSNotification*)notification
{
    NSInteger routeChangeReason = [[[notification userInfo]objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            VHLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            VHLog(@"Headphone/Line plugged in");
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            VHLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            VHLog(@"Headphone/Line was pulled. Stopping player....");
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            // called at start - also when other audio wants to play
            VHLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
            break;
        default:
            break;
    }
}


- (void)didBecomeActive
{
    if (announcementContentDic != nil)
    {
        NSString *content = [announcementContentDic objectForKey:@"announceContent"];
        NSString *time = [announcementContentDic objectForKey:@"announceTime"];
        if(announcementView != nil) {
            [announcementView setContent:[content stringByAppendingString:time]];
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma waring 版本低于4.0.0 问卷Web URL拼接方式
- (NSURL *)surveyURLWithRoomId:(NSString *)roomId model:(VHallSurveyModel *)model
{
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];//时间戳
    NSString *string = [NSString stringWithFormat:@"https://cnstatic01.e.vhall.com/questionnaire/%@.html?",model.surveyId];
    NSString *domain = [NSString stringWithFormat:@"https://e.vhall.com&webinar_id=%@&r=%@",roomId,timeStamp];
    NSString *string1 = [NSString stringWithFormat:@"%@survey_id=%@&user_id=%@&domain=%@",string,model.surveyId,model.joinId,domain];
    return [NSURL URLWithString:string1];
}

#pragma mark - 懒加载

#pragma mark - 屏幕旋转相关
-(BOOL)shouldAutorotate
{
    if (_isVr) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_isVr) {
        return NO;
    }
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UIInterfaceOrientation orientation = toInterfaceOrientation;
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) { //横屏
        _fullscreenBtn.selected = YES;
        if(_surveyController) { //横屏隐藏问卷
            _surveyController.view.hidden = YES;
        }
        NSLog(@"将要旋转为横屏");
    }else { //竖屏
        _fullscreenBtn.selected = NO;
        if(_surveyController) { //横屏显示问卷
            _surveyController.view.hidden = NO;
        }
        NSLog(@"将要旋转为竖屏");
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
