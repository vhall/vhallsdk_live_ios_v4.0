//
//  VHLiveBroadcastBaseVC.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//
#define CountDownSecond 3 //开播倒计时

#import "VHLiveBroadcastBaseVC.h"
#import "VHLiveWeakTimer.h"
#import "VHLiveMemberAndLimitView.h"
#import "VHLiveBroadcastInfoDetailView.h"
#import "VHLiveDocContentView.h"
#import "VHAlertView.h"
#import "VHLiveStateView.h"
#import "VHLiveModel.h"
#import "OMTimer.h"
#import "VHLiveMsgModel.h"
#import <VHInteractive/VHRoom.h>
#import "VHDocBrushPopView.h"
#import "VHEndPublisherVC.h"
@interface VHLiveBroadcastBaseVC ()<VHLiveBroadcastInfoDetailViewDelegate,VHLiveDocContentViewDelegate,VHLiveStateViewDelegate,VHallChatDelegate,VHDocumentDelegate,VHEndPublisherVCDelegate,VHDocBrushPopViewDelegate>

/** 开播倒计时 */
@property (nonatomic, strong ,nullable) NSTimer *countDownTimer;

/** 开播倒计时 */
@property (nonatomic, assign) NSInteger countDownSecond;
/** 结束直播界面 */
@property (nonatomic, strong) VHEndPublisherVC *endPulishVC;

@end

@implementation VHLiveBroadcastBaseVC

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.params = params;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //关闭自动锁屏
    if(self.screenLandscape) { //如果横屏，强制横屏
         [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; //开启自动锁屏
    if(self.screenLandscape) {
         [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countDownSecond = CountDownSecond;
    self.view.backgroundColor = MakeColorRGB(0x222222);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusBarOrientationChange:)
    name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //进入前后台相关监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    //弹出登录界面通知(直播过程中账号被顶，需销毁推流)
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destoryPublisherByAccountLogin) name:KNSNotificationName_PresentLogin object:nil];
    [self addDetailView];
    //获取媒体权限
    [self getMediaAccess:^(BOOL videoAccess, BOOL audioAcess) {
        if(videoAccess && audioAcess) {
            [self configUI];
        }else {
            [self shwoMediaAuthorityAlertWithMessage:@"直播需要允许访问您的摄像头和麦克风权限"];
        }
    }];
}

//添加详情View
- (void)addDetailView
{
    [self.view addSubview:self.infoDetailView];
    [self.infoDetailView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    //显示顶部工具view
    self.infoDetailView.topToolView.hidden = NO;
    //显示底部工具非文档场景下的按钮
    [self.infoDetailView.bottomToolView showDocScenceBtns:NO];
}

//开播倒计时结束，显示相关功能view
- (void)showStartLiveRelevantView {
    //显示聊天view
    [self.infoDetailView hiddenMessageView:NO];
    //显示底部工具条
    self.infoDetailView.bottomToolView.hidden = NO;
    //显示主播头像
    [self.infoDetailView hiddenHostInfoView:NO];
    //设置主播头像地址
  //  self.infoDetailView.topToolView.headIconStr = self.liveModel.webinar_user_icon;
}

- (void)configUI {
    
}

//开播倒计时
- (void)countDownAction {
    if(_countDownSecond <= -1) {
        [self startLiveCountDownOver];
        return;
    }
    NSString *text = _countDownSecond == 0 ? @"Go" : [NSString stringWithFormat:@"%zd",_countDownSecond];
    self.infoDetailView.countDownLab.hidden = NO;
    self.infoDetailView.countDownLab.text = [NSString stringWithFormat:@"%@",text];
    _countDownSecond--;
}

//开播倒计时结束
- (void)startLiveCountDownOver {
    self.infoDetailView.countDownLab.hidden = YES;
    _countDownSecond = CountDownSecond;
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    //直播计时开始
    [self startLiveTimeRun];
    //开播倒计时结束，显示相关功能view
    [self showStartLiveRelevantView];
}

//开始直播总时长计时
- (void)startLiveTimeRun {
    [self.liveTimer restart];
}

- (void)restartPushForNetError {}

//更新成员列表与受限列表
- (void)updateUserList {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  //防止服务端更新不及时，延迟刷新
        [self->_userListView updateListData];
    });
}

#pragma mark - VHChatObjectDelegate
//收到上下线消息
- (void)reciveOnlineMsg:(NSArray <VHallOnlineStateModel *> *)msgs {
    if (msgs.count > 0) {
        VHallOnlineStateModel *model = [msgs objectAtIndex:0];
        self.infoDetailView.topToolView.watchNumer = [model.concurrent_user integerValue];
    }
}

//收到聊天消息
- (void)reciveChatMsg:(NSArray <VHallChatModel *> *)msgs {
    if (msgs.count > 0) {
        VHallChatModel *model = [msgs objectAtIndex:0];
        VHLiveMsgModel *msgModel = [[VHLiveMsgModel alloc] init];
        msgModel.msg_id = model.msg_id;
        msgModel.nickName = model.user_name;
        msgModel.context = model.text;
        msgModel.type = model.type;
        msgModel.role = model.role_name;
        msgModel.imageUrls = model.imageUrls;
        [self.infoDetailView.chatView receiveMessage:msgModel];
    }
}

#pragma mark - VHEndPublisherVCDelegate退出返回
//直播结束页返回
- (void)endPublisherBackAction:(VHEndPublisherVC *)endVC {
    [self popRootViewController];
}

#pragma mark - VHLiveBroadcastInfoDetailViewDelegate
///退出直播
- (void)liveDetaiViewClickCloseBtn:(VHLiveBroadcastInfoDetailView *)detailView {
    
}

///发送聊天内容
- (void)liveDetaiView:(VHLiveBroadcastInfoDetailView *)detailView sendText:(NSString *)sendText {
    if([self.chatService isSpeakBlocked])
    {
        VH_ShowToast(@"您已被禁言");
        return;
    }
    if([self.chatService isAllSpeakBlocked])
    {
        VH_ShowToast(@"主播开启了全体禁言");
        return;
    }
    [self.chatService sendMsg:sendText success:^{
        VUI_Log(@"发送消息：%@",sendText);
    } failed:^(NSDictionary *failedData) {
        VH_ShowToast(failedData[@"content"]);
    }];
}

//子类实现
///前后设置头切换
- (void)liveDetaiViewClickCameraSwitchBtn:(VHLiveBroadcastInfoDetailView *)detailView {}

///美颜开关
- (void)liveDetaiViewClickBeautyBtn:(VHLiveBroadcastInfoDetailView *)detailView openBeauty:(BOOL)open{}

///麦克风开关
- (void)liveDetaiViewClickMicrophoneBtn:(VHLiveBroadcastInfoDetailView *)detailView voiceBtn:(UIButton *)voiceBtn {}

///摄像头开关
- (void)liveDetaiViewClickCameraOpenBtn:(VHLiveBroadcastInfoDetailView *)detailView videoBtn:(UIButton *)videoBtn {}

///打开成员列表
- (void)liveDetailViewOpenMemberListView:(VHLiveBroadcastInfoDetailView *)detailView {}

///打开文档展示容器
- (void)liveDetailViewOpenDocumentView:(VHLiveBroadcastInfoDetailView *)detailView {}

///显示/隐藏文档无关内容
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView hiddenDocUnRelationView:(BOOL)hidden {
    [detailView hiddenDocUnRelationView:hidden];
}

#pragma mark - 文档相关
//当前是否在演示文档 (未演示不能能进行画笔操作)
- (BOOL)liveDetailViewCanBrush {
    return [self.docContentView haveShowDocView];
}

- (void)liveDetaiViewShowDocId:(NSString *)docId {
    if(!self.roomInfo.documentManager.switchOn) {
        //开启文档显示
        self.roomInfo.documentManager.switchOn = YES;
    }
    //先销毁之前文档
    for (NSString *cid in self.roomInfo.documentManager.documentViewsByIDs.allKeys) {
        if(![cid isEqualToString:docId]) {
            [self.roomInfo.documentManager destroyWithCID:cid];
        }
    }
    [self.roomInfo.documentManager createDocumentWithFrame:self.docContentView.contentView.bounds size:CGSizeMake(1280, 720) documentID:docId backgroundColor:[UIColor clearColor]];
    
    VUI_Log(@"当前文档数：%zd",self.roomInfo.documentManager.documentViewsByIDs.allValues.count);
}

#pragma mark - VHDocBrushPopViewDelegate 画笔选择
//颜色选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushColor:(UIColor *)color {
    [self.roomInfo.documentManager.selectedView setColor:color];
}

//画笔粗细选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushSize:(NSInteger)size {
    [self.roomInfo.documentManager.selectedView setSize:size];
}

//形状选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushShape:(VHDrawType)type {
    self.roomInfo.documentManager.selectedView.drawType = type;
    //绘制类型设置后，需要重新设置颜色和粗细
    [self.roomInfo.documentManager.selectedView setColor:popView.currentSelectColor];
    [self.roomInfo.documentManager.selectedView setSize:popView.currentSelectSize];
}

//功能选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushFunction:(VHBrushFunctionType)type {
    if(type == VHBrushFunctionTrash) { //垃圾桶，清空操作
        [VHAlertView showAlertWithTitle:@"确定要清空文档标记吗？" content:nil cancelText:@"取消" cancelBlock:nil confirmText:@"确定" confirmBlock:^{
             [self.roomInfo.documentManager.selectedView clear];
        }];
    }else if(type == VHBrushFunctionRubber) { //橡皮檫
        self.roomInfo.documentManager.selectedView.drawAction = VHDrawAction_Delete;
    }else {
        self.roomInfo.documentManager.selectedView.drawAction = VHDrawAction_Add;
    }
}

//是否开始进行涂鸦
- (void)brushPopView:(VHDocBrushPopView *)popView startBrushState:(BOOL)state {
    if(state) {
        VUI_Log(@"开启涂鸦，当前选的的文档：%@",self.roomInfo.documentManager.selectedView);
    }
    self.roomInfo.documentManager.selectedView.editGraffitEnable = state;
    //开启涂鸦后，需要重新设置绘制类型
    [self brushPopView:popView selectBrushShape:popView.currentSelectShape];
}

#pragma mark - VHDocumentDelegate
/**
 *  错误回调
 *  @param document 文档实例
 *  @param error    错误
 */
- (void)document:(VHDocument *)document error:(NSError *)error {
    VUI_Log(@"文档出错：%@",error);
}

/**
 *  直播文档同步
 *  @param document 文档实例
 *  @param channelID   文档channelID
 *  @return float   延迟执行时间单位秒 即直播延迟时间 re     alityBufferTime/1000.0
 */
- (float)document:(VHDocument *)document delayChannelID:(NSString*)channelID {
    return 0;
}

/**
 *  翻页消息
 *  @param document 文档实例
 *  @param documentView   文档id 为空时没有 文档
 */
- (void)document:(VHDocument *)document changePage:(VHDocumentView*)documentView {
    VUI_Log(@"文档翻页：%@",documentView);
}

/**
 * 是否显示文档
 */
- (void)document:(VHDocument *)document switchStatus:(BOOL)switchStatus {
    VUI_Log(@"文档显示：%d 是否可编辑：%d 选中的文档：%@",switchStatus,document.editEnable,document.selectedView);
    //app目前只有主播端和嘉宾端，只要收到文档显示/隐藏回调就显示文档，不管文档状态是显示还是隐藏，因为文档隐藏只对观众生效
    [self.docContentView setDocViewHidden:NO];
}

/**
 *  选择 documentView
 */
- (void)document:(VHDocument *)document selectDocumentView:(VHDocumentView*)documentView {
    VUI_Log(@"选择文档：%@---cid:%@",documentView,documentView.cid);
    //保证选择的文档始终在顶层（web端文档、白板切换时会回调此方法）
    [self.docContentView bringSubviewToFrontWithDocId:document.selectedView.cid];
}

/**
 *  添加 documentView
 */
- (void)document:(VHDocument *)document addDocumentView:(VHDocumentView *)documentView {
    VUI_Log(@"添加文档：%@---cid:%@---该文档是否为选中文档：%d",documentView,documentView.cid,[documentView isEqual:document.selectedView]);
    [self.docContentView addDocumentView:documentView];
    //保证选择的文档始终在顶层（防止其他端演示新文档时，没有销毁老文档，会出现多个文档叠加；或者出现回调先选择文档后添加文档，导致选择文档无法显示）
    [self.docContentView bringSubviewToFrontWithDocId:document.selectedView.cid];
}

/**
 *  删除 documentView
 */
- (void)document:(VHDocument *)document removeDocumentView:(VHDocumentView *)documentView {
    VUI_Log(@"删除文档：%@",documentView);
    [self.docContentView removeDocumentView:documentView];
}

#pragma mark - VHLiveDocContentViewDelegate
//是否能互动翻页
- (BOOL)canSwipe {
    if([self.infoDetailView brushPopViewIsShow]) {
        return NO;
    }else {
        return YES;
    }
}

//文档容器关闭完成
- (void)docContentViewDisMissComplete:(VHLiveDocContentView *)docContentView {
    [self.infoDetailView showDocUI:NO];
    //如果当前正在画笔操作，结束画笔
    if([self.infoDetailView brushPopViewIsShow]) {
        [self.infoDetailView.bottomToolView cancelSelectBrush];
    }
}

//文档左滑/右滑翻页
- (void)docContentView:(VHLiveDocContentView *)docContentView swipeDirection:(UISwipeGestureRecognizerDirection)direction {
    if(direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.roomInfo.documentManager.selectedView nextPage];
    }else if(direction == UISwipeGestureRecognizerDirectionRight){
        [self.roomInfo.documentManager.selectedView prevPage];
    }
}

#pragma mark - VHLiveStateViewDelegate
///直播状态页按钮事件
- (void)liveStateView:(VHLiveStateView *)liveStateView actionType:(VHLiveState)type {
    if(type == VHLiveState_Prepare) { //开始直播
        self.countDownTimer = [VHLiveWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
        //隐藏开播按钮
        [self.liveStateView setLiveState:VHLiveState_Success btnTitle:@""];
    }else if(type == VHLiveState_Forbid) { //被封禁，返回
        [self popRootViewController];
    }else if(type == VHLiveState_NetError) {
        [self.liveStateView setLiveState:VHLiveState_Success btnTitle:@""];
        [self restartPushForNetError];
    }
}


//显示直播结束view
- (void)showLiveEndView {
    [_liveTimer stop]; //停止直播计时
    if(self.screenLandscape) { //如果横屏，强制转竖屏
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
        self.screenLandscape = NO;
    }
    //记录当前直播时长
    [self.view addSubview:self.endPulishVC.view];
}

- (void)popRootViewController {
    [_liveTimer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 前后台处理
//前台（子类重写）
- (void)appWillEnterForeground {
    //获取媒体权限
    [self getMediaAccess:^(BOOL videoAccess, BOOL audioAcess) {
        if(!videoAccess || !audioAcess) {
            [self shwoMediaAuthorityAlertWithMessage:@"直播需要允许访问您的摄像头和麦克风权限"];
        }
    }];
}

//后台（子类重写）
- (void)appDidEnterBackground {}

////强杀（子类重写）
- (void)appWillTerminate {}

#pragma mark - 屏幕旋转
//是否可以旋转
- (BOOL)shouldAutorotate {
    if(self.forceRotating) {
        return YES;
    }
    return NO;
}

// 支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(self.forceRotating) { //强制转屏时支持横屏和竖屏
        return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
    }
    if(self.screenLandscape) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.screenLandscape) {
        return UIInterfaceOrientationLandscapeRight;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

//界面方向改变的通知
- (void)handleStatusBarOrientationChange: (NSNotification *)notification{
    if(VH_KScreenIsLandscape) {
        VUI_Log(@"横屏");
    }else {
        VUI_Log(@"竖屏");
    }
}

// 状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//禁止侧滑返回
- (BOOL)forceEnableInteractivePopGestureRecognizer {
    return NO;
}

#pragma mark - lazy load
- (OMTimer *)liveTimer
{
    if (!_liveTimer)
    {
        _liveTimer = [[OMTimer alloc] init];
        _liveTimer.timerInterval = 60*60*24*365;
        _liveTimer.precision = 100;
        _liveTimer.isAscend = YES;
        @weakify(self)
        _liveTimer.progressBlock = ^(OMTime *progress) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.infoDetailView.topToolView.liveTimeStr = [NSString stringWithFormat:@"%@:%@:%@", progress.hour, progress.minute, progress.second];
            });
        };
    }
    return _liveTimer;
}

- (VHLiveBroadcastInfoDetailView *)infoDetailView
{
    if (!_infoDetailView) {
        _infoDetailView = [[VHLiveBroadcastInfoDetailView alloc] initWithSpeaker:self.isSpeaker guest:self.isGuest landScapeShow:self.screenLandscape];
        _infoDetailView.delegate = self;
        //开播之前不显示消息、主播头像、底部工具视图 ，只显示右上角视频、语音、美颜等工具按钮
        [_infoDetailView hiddenMessageView:YES];
        [_infoDetailView hiddenHostInfoView:YES];
        _infoDetailView.bottomToolView.hidden = YES;
    }
    return _infoDetailView;
}

- (VHLiveStateView *)liveStateView {
    if (!_liveStateView) {
        _liveStateView = [[VHLiveStateView alloc] init];
        _liveStateView.delegate = self;
        [self.infoDetailView addSubview:_liveStateView];
        [self.liveStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.infoDetailView);
        }];
    }
    return _liveStateView;
}

- (VHEndPublisherVC *)endPulishVC
{
    if (!_endPulishVC)
    {
        _endPulishVC = [[VHEndPublisherVC alloc] init];
        VHLiveModel *liveModel = [[VHLiveModel alloc] init];
        liveModel.liveDuration = self.infoDetailView.topToolView.liveTimeStr;
        liveModel.webinar_user_nick = self.roomInfo.selfNickname;
        liveModel.webinar_user_icon = self.roomInfo.selfAvatar;
        _endPulishVC.liveModel = liveModel;
        _endPulishVC.delegate = self;
    }
    return _endPulishVC;
}

- (VHLiveDocContentView *)docContentView
{
    if (!_docContentView)
    {
        _docContentView = [[VHLiveDocContentView alloc] init];
        _docContentView.delegate = self;
        _docContentView.emptyLab.text = self.isSpeaker ? @"还没有文档哦，点击右下角添加~" : @"还没有文档哦";
        [self.infoDetailView insertSubview:_docContentView atIndex:0];
        [_docContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.infoDetailView);
        }];
        _docContentView.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
    }
    return _docContentView;
}

@end
