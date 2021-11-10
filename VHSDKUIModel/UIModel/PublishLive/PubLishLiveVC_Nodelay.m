//
//  DemoViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "PubLishLiveVC_Nodelay.h"
#import <AVFoundation/AVFoundation.h>
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"
#import <VHLiveSDK/VHallApi.h>
#import "UIAlertController+ITTAdditionsUIModel.h"
#import <VHInteractive/VHRoom.h>
#import "VHLiveChatView.h"
#import "VHKeyboardToolView.h"

@interface PubLishLiveVC_Nodelay () <VHallChatDelegate,VHKeyboardToolViewDelegate,VHRoomDelegate>
{
    UIButton * _lastFilterSelectBtn;
    VHallChat         *_chat;       //聊天
    dispatch_source_t _timer;
    long              _liveTime;
}

@property (weak, nonatomic) IBOutlet UIView *perView;
@property (weak, nonatomic) IBOutlet UIButton *videoStartAndStopBtn; //开播按钮
@property (weak, nonatomic) IBOutlet UIView *chatContainerView;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;
@property (weak, nonatomic) IBOutlet UIButton *chatMsgSend;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *defaultFilterSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *hideKeyBtn;  //用来点击移除输入工具、美颜级别view或其他弹窗视图的全屏按钮
@property (weak, nonatomic) IBOutlet UIButton *cameraSwapBtn;

@property (nonatomic, strong) VHLiveChatView *chatView;
@property (nonatomic, strong) NSMutableArray *chatDataArray;
@property (nonatomic,strong) VHKeyboardToolView * messageToolView;  //输入工具view
@property (nonatomic, strong) NSMutableDictionary *publishParam;     ///<发直播参数

/** 本地视频view */
@property (nonatomic, strong) VHLocalRenderView *localRenderView;
/** 互动SDK (用于无延迟直播) */
@property (nonatomic, strong) VHRoom *inavRoom;
@property (weak, nonatomic) IBOutlet UILabel *onlyAudioTipLab; //音频直播提示

@end

@implementation PubLishLiveVC_Nodelay

#pragma mark - Lifecycle
- (id)init {
    self = LoadVCNibName;
    if (self) {
        [self initDatas];
    }
    return self;
}
 

//默认设置
- (void)initDatas {
    _beautifyFilterEnable = YES;
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
    _streamType = VHInteractiveStreamTypeAudioAndVideo;
    _scaleMode = VHRenderViewScalingModeAspectFill;
    
    //获取音频权限
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
        }];
    } else if (permissionStatus == AVAudioSessionRecordPermissionDenied) {
        
    } else {
        
    }
    
    _chat = [[VHallChat alloc] initWithObject:self.inavRoom];
    _chat.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews {
    [self registerLiveNotification];
    
    _chatMsgSend.layer.masksToBounds = YES;
    _chatMsgSend.layer.cornerRadius = 15;
    _chatMsgSend.layer.borderWidth  = 1;
    _chatMsgSend.layer.borderColor  = MakeColorRGBA(0xffffff, 0.5).CGColor;
    
    _msgTextField.layer.masksToBounds = YES;
    _msgTextField.layer.cornerRadius = 15;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_msgTextField.placeholder attributes:
         @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
           NSFontAttributeName:_msgTextField.font}
         ];
    _msgTextField.attributedPlaceholder = attrString;
    
    //添加推流画面
    [self.perView insertSubview:self.localRenderView atIndex:0];
    [self.localRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.perView);
    }];
    
    //添加聊天view
    [self.chatContainerView addSubview:self.chatView];
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.right.equalTo(@(-10));
        make.bottom.equalTo(self.chatContainerView).offset(-50);
        make.top.equalTo(self.chatContainerView);
    }];
    
    if(self.streamType == VHInteractiveStreamTypeOnlyAudio) { //音频直播
        self.onlyAudioTipLab.hidden = NO;
        self.cameraSwapBtn.hidden = YES;
        self.beautifyFilterEnable = NO;
    }
    _filterBtn.hidden = !self.beautifyFilterEnable;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


- (void)dealloc
{
    _chat = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    VHLog(@"%@ dealloc",[[self class] description]);
}

- (void)LaunchLiveDidEnterBackground {
//    if (self.videoStartAndStopBtn.selected == YES) {
//        [self.inavRoom unpublish];
//    }
}

- (void)LaunchLiveWillEnterForeground {
    if(self.videoStartAndStopBtn.selected == YES && ![self.inavRoom isPublishing]) {
        [self.inavRoom publishWithCameraView:self.localRenderView];
    }
}

//返回
- (IBAction)closeBtnClick:(id)sender {
    [self stopPublishAndLeaveRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Lifecycle(Private)

- (void)registerLiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveDidEnterBackground)name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
}


#pragma mark - 发起/停止直播
- (IBAction)startVideoPlayer:(UIButton *)sender
{
#if (TARGET_IPHONE_SIMULATOR)
    VH_ShowToast(@"无法在模拟器上发起直播！");
    return;
#endif
    
    if(sender.selected == NO) {  //开始直播
        [_chatDataArray removeAllObjects];
        [_chatView update];
        
        [ProgressHud showLoading];
        [self.inavRoom hostEnterRoomStartWithParams:self.publishParam success:^(VHRoomInfo *info) {
                    
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
        }];
        
    }else { //停止直播
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"您是否要结束直播？" leftTitle:@"取消" rightTitle:@"结束" leftCallBack:^{
         
        } rightCallBack:^{
            [self stopPublishAndLeaveRoom];
        }];
    }
}


#pragma mark - 基础操作
//摄像头翻转
- (IBAction)swapBtnClick:(UIButton *)btn {
    [self.localRenderView switchCamera];
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
}

//关闭/开启麦克风
- (IBAction)onlyVideoBtnClick:(UIButton *)sender {
    if(!sender.selected) {
        [self.localRenderView muteAudio];
    }else {
        [self.localRenderView unmuteAudio];
    }
    sender.selected = !sender.selected;
}


#pragma mark - 美颜设置
- (IBAction)filterBtnClick:(UIButton *)sender {
    _filterBtn.selected = !_filterBtn.selected;
    if(_filterBtn.selected) {
        _hideKeyBtn.hidden = NO;
        _filterView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _filterView.alpha = 1.0f;
        }];
    } else {
        _hideKeyBtn.hidden = YES;
        _filterView.alpha = 1.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _filterView.alpha = 0.0f;
        }];
    }
}

- (IBAction)filterSettingBtnClick:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    if (_lastFilterSelectBtn) {
        [_lastFilterSelectBtn setBackgroundColor:MakeColorRGBA(0x000000,0.5)];
        _lastFilterSelectBtn.selected = NO;
    }
    
    sender.selected = YES;
    [sender setBackgroundColor:MakeColorRGBA(0xfd3232,0.5)];
    _lastFilterSelectBtn = sender;
    
    switch (sender.tag) {
        case 1:[self.localRenderView setFilterBilateral:10.0f Brightness:1.0f  Saturation:1.0f Sharpness:0.0f];break;
        case 2:[self.localRenderView setFilterBilateral:8.0f Brightness:1.05f  Saturation:1.0f Sharpness:0.0f];break;
        case 3:[self.localRenderView setFilterBilateral:6.0f Brightness:1.10f  Saturation:1.0f Sharpness:0.0f];break;
        case 4:[self.localRenderView setFilterBilateral:4.0f Brightness:1.15f  Saturation:1.0f Sharpness:0.0f];break;
        case 5:[self.localRenderView setFilterBilateral:2.0f Brightness:1.2f  Saturation:1.0f Sharpness:0.0f];break;
        default:break;
    }
}

#pragma mark - Chat && QA
- (void)chatShow:(BOOL)isShow
{
    if(isShow)
    {
        _chatContainerView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _chatContainerView.alpha = 1.0f;
        }];
        _closeBtn.hidden = YES;
        _infoView.hidden = NO;
        [self showTimeInfo];
    } else {
        _chatContainerView.alpha = 1.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _chatContainerView.alpha = 0.0f;
        }];
        _closeBtn.hidden = NO;
        _infoView.hidden = YES;
        if(_timer)
        {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        _timeLabel.text    = @"00:00:00";
    }
}

//点击"我来说两句"
- (IBAction)sendMsgButtonClick:(UIButton *)sender {
    [self.messageToolView becomeFirstResponder];
}

#pragma mark Chat && QA(VHallChatDelegate)
- (void)reciveOnlineMsg:(NSArray <VHallOnlineStateModel *> *)msgs
{
    if (msgs.count > 0) {
        for (VHallOnlineStateModel *m in msgs) {
            VHActMsg * msg = [[VHActMsg alloc]initWithMsgType:ActMsgTypeMsg];
            msg.actId= m.room;
            msg.joinId= m.join_id;
            msg.formUserIcon= m.avatar;
            msg.formUserName= m.user_name;
            msg.formUserId= m.account_id;
            msg.time= m.time;

            NSString *event;
            NSString *role;
            if([m.event isEqualToString:@"online"]) {
                event = @"进入";
            }else if([m.event isEqualToString:@"offline"]){
                event = @"离开";
            }
            
            if([m.role isEqualToString:@"host"]) {
                role = @"主持人";
            }else if([m.role isEqualToString:@"guest"]) {
                role = @"嘉宾";
            }else if([m.role isEqualToString:@"assistant"]) {
                role = @"助手";
            }else if([m.role isEqualToString:@"user"]) {
                role = @"观众";
            }
            
            msg.text = [NSString stringWithFormat:@"%@\n[%@] %@房间:%@ 在线:%@ 参会:%@",m.time,role,event,msg.actId, m.concurrent_user, m.attend_count];
            [_chatDataArray addObject:msg];
        }
        [_chatView update];
    }
}



- (void)reciveChatMsg:(NSArray <VHallChatModel *> *)msgs
{
    if (msgs.count > 0) {
        for (VHallChatModel *m in msgs) {
            VHActMsg * msg = [[VHActMsg alloc]initWithMsgType:ActMsgTypeMsg];
            msg.actId= m.room;
            msg.joinId= m.join_id;
            msg.formUserIcon= m.avatar;
            msg.formUserName= m.user_name;
            msg.formUserId= m.account_id;
            msg.time = m.time;
            
            NSString *contextText = [NSString stringWithFormat:@"%@\n%@",m.text ? m.text : @"",m.imageUrls.count>0 ? [m.imageUrls componentsJoinedByString : @";"] : @""];
            
            msg.text = [NSString stringWithFormat:@"%@\n%@",m.time, contextText];
            
            [_chatDataArray addObject:msg];
        }
        [_chatView update];
    }
}

- (void)showTimeInfo {
    if(_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    _liveTime = 0;
    dispatch_queue_t queue = dispatch_queue_create("my queue", 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0);//间隔1秒
    dispatch_source_set_event_handler(_timer, ^(){
        _liveTime++;
        NSString *strInfo = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",_liveTime/3600,(_liveTime/60)%60,_liveTime%60];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_timeLabel)
            {
                _timeLabel.text = strInfo;
            }
        });
    });
    dispatch_resume(_timer);
}

- (IBAction)hideKey:(id)sender {
    //关闭键盘输入
    [_messageToolView resignFirstResponder];
    _hideKeyBtn.hidden = YES;
    //关闭美颜级别弹窗
    _filterBtn.selected = NO;
    [UIView animateWithDuration:0.3f animations:^{
        _filterView.alpha = 0.0f;
    }];
}

#pragma mark - VHKeyboardToolViewDelegate
/*! 发送按钮事件回调*/
- (void)keyboardToolView:(VHKeyboardToolView *)view sendText:(NSString *)text {
    if(text == nil || text.length <= 0) {
        VH_ShowToast(@"发送内容不能为空");
        return;
    }
    
    [self hideKey:nil];
    [_chat sendMsg:text success:^{
        
    } failed:^(NSDictionary *failedData) {
        NSString* string = [NSString stringWithFormat:@"(%@)%@", failedData[@"code"],failedData[@"content"]];
        VH_ShowToast(string);
    }];
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
    [self stopPublishAndLeaveRoom];
}

//停止推流并离开房间
- (void)stopPublishAndLeaveRoom {
    
    if([self.inavRoom isPublishing]) {
        [self.inavRoom unpublish]; //停止推流
    }
    [self.inavRoom leaveRoom]; //退出互动房间
    self.videoStartAndStopBtn.selected = NO;
    [self chatShow:NO];
}

#pragma mark - VHRoomDelegate
- (void)room:(VHRoom *)room enterRoomWithError:(NSError *)error {
    VUI_Log(@"加入房间回调");
    [self interactiveRoomError:error];
}

// 房间连接成功回调
- (void)room:(VHRoom *)room didConnect:(NSDictionary *)roomMetadata {
    VUI_Log(@"房间连接成功，开启推流");
    //开始推流
    [self.inavRoom publishWithCameraView:self.localRenderView];
}

//推流成功
- (void)room:(VHRoom *)room didPublish:(VHRenderView *)cameraView {
    VUI_Log(@"推流成功");
    [ProgressHud hideLoading];
    self.videoStartAndStopBtn.selected = YES;
    [self chatShow:YES];
}

// 停止推流成功
- (void)room:(VHRoom *)room didUnpublish:(VHRenderView *)cameraView {
    VUI_Log(@"停止推流成功");
}

//错误回调
- (void)room:(VHRoom *)room didError:(VHRoomErrorStatus)status reason:(NSString *)reason {
    VUI_Log(@"房间错误：%@---status：%zd",reason,status);
    if(status == 284003) { //socket.io fail 错误
        VH_ShowToast(@"网络错误");
        //退出
        [self stopPublishAndLeaveRoom];
    }else { //其他错误，如：上麦人数达到上限（status：513025）
        VH_ShowToast(reason);
    }
}

//房间状态变化
- (void)room:(VHRoom *)room didChangeStatus:(VHRoomStatus)status {
    VUI_Log(@"房间状态变化：%zd",status);
}

- (VHKeyboardToolView *)messageToolView {
    if (!_messageToolView)
    {
        _messageToolView = [[VHKeyboardToolView alloc] init];
        _messageToolView.delegate = self;
        [self.view addSubview:_messageToolView];
    }
    return _messageToolView;
}

#pragma mark - 懒加载
- (NSMutableDictionary *)publishParam {
    if (!_publishParam)
    {
        _publishParam = [[NSMutableDictionary alloc] init];
        _publishParam[@"id"] = _roomId;
        _publishParam[@"nickname"] = _nick_name;
    }
    return _publishParam;
}

- (VHLiveChatView *)chatView {
    if (!_chatView)
    {
        __weak __typeof(self)weakSelf = self;
        _chatView = [[VHLiveChatView alloc] initWithFrame:CGRectZero msgTotal:^NSInteger{
            return  weakSelf.chatDataArray.count;
        } msgSource:^VHActMsg *(NSInteger index) {
            return  weakSelf.chatDataArray[index];
        }action:nil];
    }
    return _chatView;
}

- (VHLocalRenderView *)localRenderView {
    if (!_localRenderView) {
        VHInteractiveStreamType streamType = self.streamType;
        NSDictionary *options = @{VHVideoWidthKey:@(1280),VHVideoHeightKey:@(720),VHVideoFpsKey:@(30),VHMaxVideoBitrateKey:@(300),VHStreamOptionStreamType:@(streamType)};
        _localRenderView = [[VHLocalRenderView alloc] initCameraViewWithFrame:CGRectZero options:options];
        _localRenderView.scalingMode = self.scaleMode;
        _localRenderView.beautifyEnable = self.beautifyFilterEnable;
        [_localRenderView setDeviceOrientation:self.interfaceOrientation == UIInterfaceOrientationPortrait ? UIDeviceOrientationPortrait : UIDeviceOrientationLandscapeLeft];
    }
    return _localRenderView;
}

- (VHRoom *)inavRoom {
    if (!_inavRoom) {
        _inavRoom = [[VHRoom alloc] init];
        _inavRoom.delegate = self;
    }
    return _inavRoom;
}

@end
