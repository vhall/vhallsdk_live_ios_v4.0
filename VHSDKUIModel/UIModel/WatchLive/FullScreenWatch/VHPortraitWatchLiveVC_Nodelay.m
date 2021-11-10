//
//  VHPortraitWatchLiveVC_Nodelay.m
//  UIModel
//
//  Created by xiongchao on 2021/11/2.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHPortraitWatchLiveVC_Nodelay.h"
#import <VHLiveSDK/VHallApi.h>
#import "UIAlertController+ITTAdditionsUIModel.h"
#import "VHPortraitWatchLiveDecorateView.h"
#import "VHinteractiveViewController.h"
#import "VHInvitationAlert.h"
#import "VHWatchNodelayVideoView.h"
#import <VHInteractive/VHRoom.h>
#import "VHWatchNodelayDocumentView.h"


@interface VHPortraitWatchLiveVC_Nodelay () <VHPortraitWatchLiveDecorateViewDelegate,VHallChatDelegate,VHinteractiveViewControllerDelegate,VHInvitationAlertDelegate,VHRoomDelegate> {
    BOOL _haveLoadHistoryChat; //是否已加载历史聊天记录
    BOOL _docShow; //文档是否显示
}
/** 承载文档view的父视图 */
//@property (nonatomic, strong) VHWatchNodelayDocumentView *docContentView;
/** 视频view上层子控件的父视图 */
@property (nonatomic, strong) VHPortraitWatchLiveDecorateView *decorateView;
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

@property (nonatomic, strong) VHWatchNodelayVideoView *videoView;  //视频容器
/** 互动SDK (用于无延迟直播) */
@property (nonatomic, strong) VHRoom *inavRoom;
@property (nonatomic, strong) MASConstraint *videoViewHeight;     ///<视频容器高
@end

@implementation VHPortraitWatchLiveVC_Nodelay
- (void)dealloc
{
    NSLog(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //关闭设备自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self enterInvRoom];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //开启设备自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.inavRoom leaveRoom];
    [_videoView removeAllRenderView];
}


- (void)configUI {
    [self.view addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.view);
        self.videoViewHeight = make.height.equalTo(self.videoView.mas_width).multipliedBy(9/16.0);
    }];
    
    [self.view addSubview:self.decorateView];
    [self.decorateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.backBtn];
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

//进入互动房间
- (void)enterInvRoom {
    [self.inavRoom enterRoomWithParams:[self playParam]];
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


#pragma mark - UI事件
- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//互动出错
- (void)interactiveRoomError:(NSError *)error {
    if (!error) {
        return;
    }
    [ProgressHud hideLoading];
    VUI_Log(@"互动房间出错：%@",error);
    if(error.code == 284003){ //socket.io fail（一般是网络错误）
        VH_ShowToast(@"当前网络异常");
    }else {
        VH_ShowToast(error.domain);
    }
}


//弹出互动页面
- (void)presentInteractiveVC {
    [self.decorateView.upMicBtnView stopCountDown];
    //进入互动
    VHinteractiveViewController *controller = [[VHinteractiveViewController alloc] init];
    controller.joinRoomPrams = [self playParam];
    controller.inav_num = self.inavRoom.roomInfo.inav_num;
    controller.inavBeautifyFilterEnable = self.interactBeautifyEnable;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

//被踢出
- (void)kickOutAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您已被踢出房间" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

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
    if(index == 1){ //同意主持人的邀请
        [self.inavRoom agreeInviteSuccess:^{
            [self presentInteractiveVC];
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
        }];
        
    } else if(index == 0) { //拒绝主持人的邀请
        [self.inavRoom rejectInviteSuccess:^{
            VH_ShowToast(@"已拒绝");
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
        }];
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
    
    if ([UIModelTools safeString:messageText].length == 0) {
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
        [self.inavRoom applySuccess:^{
            VH_ShowToast(@"申请上麦成功");
            //开启上麦倒计时
            [weakSelf.decorateView.upMicBtnView countdDown:30];
        } fail:^(NSError *error) {
            NSString *msg = [NSString stringWithFormat:@"申请上麦失败：%@",error.description];
            VH_ShowToast(msg);
        }];
    } else {
        [self.inavRoom cancelApplySuccess:^{
            VH_ShowToast(@"已取消申请");
            //停止倒计时
            [weakSelf.decorateView.upMicBtnView stopCountDown];
        } fail:^(NSError *error) {
            NSString *msg = [NSString stringWithFormat:@"取消上麦失败：%@",error.description];
            VH_ShowToast(msg);
        }];
    }
}

#pragma mark - VHRoomDelegate
/// 进入房间回调
- (void)room:(VHRoom *)room enterRoomWithError:(NSError *)error {
    VUI_Log(@"加入房间回调");
    [self interactiveRoomError:error];
    if(error == nil) { //加入房间成功
        //加载历史聊天记录
        [self loadHistoryChatData];
//        //设置文档
//        [self.docContentView setDocument:self.inavRoom.roomInfo.documentManager defaultShow:self.inavRoom.roomInfo.documentOpenState];
        //是否显示上麦按钮
        if(self.inavRoom.roomInfo.handsUpOpenState) {
            self.decorateView.upMicBtnView.hidden = NO;
        }
        //设置视频画面主讲人id
        self.videoView.roomInfo = self.inavRoom.roomInfo;
        if(self.inavRoom.roomInfo.webinar_type != VHWebinarLiveType_Interactive) { //非互动直播，全屏布局
            [self.videoViewHeight uninstall];
            [self.videoView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.videoViewHeight = make.height.equalTo(self.view);
            }];
        }
    }
}

/// 房间连接成功回调
- (void)room:(VHRoom *)room didConnect:(NSDictionary *)roomMetadata {
    VUI_Log(@"房间连接成功");
}

/// 房间发生错误回调
- (void)room:(VHRoom *)room didError:(VHRoomErrorStatus)status reason:(NSString *)reason {
    
}

/// 房间状态改变回调
- (void)room:(VHRoom *)room didChangeStatus:(VHRoomStatus)status {
    
}

/// 视频流加入回调（流类型包括音视频、共享屏幕、插播等）
- (void)room:(VHRoom *)room didAddAttendView:(VHRenderView *)attendView {
    VUI_Log(@"\n某人上麦:%@，流类型：%d，流视频宽高：%@，流id：%@，是否有音频：%d，是否有视频：%d",attendView.userId,attendView.streamType,NSStringFromCGSize(attendView.videoSize),attendView.streamId,attendView.hasAudio,attendView.hasVideo);
    [self.videoView addRenderView:attendView];
}

/// 视频流离开回调（流类型包括音视频、共享屏幕、插播等）
- (void)room:(VHRoom *)room didRemovedAttendView:(VHRenderView *)attendView {
    [self.videoView removeRenderView:attendView];
}


/// 互动相关消息回调
- (void)room:(VHRoom *)room receiveRoomMessage:(VHRoomMessage *)message {
    if(message.targetForMe) { //针对自己的消息
        if (message.messageType == VHRoomMessageType_vrtc_connect_agree) { //主持人同意自己上麦
            [self presentInteractiveVC];
        }else if (message.messageType == VHRoomMessageType_vrtc_connect_refused) { //主持人拒绝自己上麦
            VH_ShowToast(@"主持人拒绝了您的上麦申请");
        }else if (message.messageType == VHRoomMessageType_vrtc_connect_invite) { //主持人邀请自己上麦
            _invitationAlertView = [[VHInvitationAlert alloc]initWithDelegate:self tag:1000 title:@"上麦邀请" content:@"主持人邀请您上麦，是否接受？"];
            [self.view addSubview:_invitationAlertView];
        }else if (message.messageType == VHRoomMessageType_room_kickout) { //被踢出
            [self kickOutAction];
        }
    }
    
    if(message.messageType == VHRoomMessageType_vrtc_connect_open) { //开启举手
        self.decorateView.upMicBtnView.hidden = NO;
    }else if(message.messageType == VHRoomMessageType_vrtc_connect_close) { //关闭举手
        self.decorateView.upMicBtnView.hidden = YES;
    }else if (message.messageType == VHRoomMessageType_live_over) { //结束直播
        [ProgressHud hideLoading];
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"直播已结束" btnTitle:@"确定" callBack:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else if (message.messageType == VHRoomMessageType_vrtc_speaker_switch) { //某个用户被设置为主讲人
        [self.videoView updateMainSpeakerView];
    }
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

    }
    return _playParam;
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

//- (VHWatchNodelayDocumentView *)docContentView
//{
//    if (!_docContentView)
//    {
//        _docContentView = [[VHWatchNodelayDocumentView alloc] init];
//        [self.view insertSubview:_docContentView aboveSubview:self.videoView];
//        [_docContentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self.view);
//            make.bottom.equalTo(self.videoView.mas_top).offset(-10);
//            make.height.equalTo(_docContentView.mas_width).multipliedBy(9/16.0);
//        }];
//    }
//    return _docContentView;
//}

- (VHinteractiveViewController *)interactiveVC
{
    if (!_interactiveVC)
    {
        VHinteractiveViewController *interactiveVC = [[VHinteractiveViewController alloc] init];
        interactiveVC.joinRoomPrams = self.playParam;
        interactiveVC.inavBeautifyFilterEnable = self.interactBeautifyEnable;
        interactiveVC.inav_num = self.inavRoom.roomInfo.inav_num;
        _interactiveVC = interactiveVC;
    }
    return _interactiveVC;
}

- (VHRoom *)inavRoom {
    if (!_inavRoom) {
        _inavRoom = [[VHRoom alloc] init];
        _inavRoom.delegate = self;
        
        //聊天对象初始化
        _vhallChat = [[VHallChat alloc] initWithObject:_inavRoom];
        _vhallChat.delegate = self;
    }
    return _inavRoom;
}

- (VHWatchNodelayVideoView *)videoView
{
    if (!_videoView)
    {
        _videoView = [[VHWatchNodelayVideoView alloc] init];
    }
    return _videoView;
}
@end
