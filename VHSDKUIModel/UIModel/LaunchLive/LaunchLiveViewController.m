//
//  DemoViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "LaunchLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"
#import <VHLiveSDK/VHallApi.h>
#import "UIAlertController+ITTAdditionsUIModel.h"

#import "VHLiveChatView.h"
#import "VHKeyboardToolView.h"

@interface LaunchLiveViewController ()<VHallLivePublishDelegate, VHallChatDelegate,VHKeyboardToolViewDelegate>
{
    BOOL  _isAudioStart;
    BOOL  _torchType;
    BOOL  _onlyVideo;
    BOOL  _isFontVideo;
    MBProgressHUD * _hud;
    UIButton * _lastFilterSelectBtn;

    VHallChat         *_chat;       //聊天
    dispatch_source_t _timer;
    long              _liveTime;
    BOOL  _publishSuccess;  //标记当前开播状态
}


@property (strong, nonatomic)VHallLivePublish *engine;
@property (weak, nonatomic) IBOutlet UIView *perView;
@property (weak, nonatomic) IBOutlet UIImageView *logView;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoStartAndStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioStartAndStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn; //闪光灯
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

@property (nonatomic, strong) VHLiveChatView *chatView;
@property (nonatomic, strong) NSMutableArray *chatDataArray;
@property (nonatomic,strong) VHKeyboardToolView * messageToolView;  //输入工具view
@property (weak, nonatomic) IBOutlet UIView *noiseView;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backbtntopConstraint;
@property (nonatomic, strong) NSMutableDictionary *publishParam;     ///<发直播参数
@end

@implementation LaunchLiveViewController

#pragma mark - Lifecycle
- (id)init
{
    self = LoadVCNibName;
    if (self) {
        [self initDatas];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    //初始化CameraEngine
    [self initCameraEngine];
    
    //获取音频权限
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
       [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
       }];
    } else if (permissionStatus == AVAudioSessionRecordPermissionDenied) {

    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_chat) {
        _chat = nil;
    }
    
    if (_engine) {
        _engine = nil;
    }
    
    //允许iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    VHLog(@"%@ dealloc",[[self class]description]);
}

-(void)LaunchLiveDidEnterBackground
{
    if(_publishSuccess) {
        [_engine disconnect];
    }
    [_engine stopVideoCapture];
}

-(void)LaunchLiveWillEnterForeground
{
    [_engine startVideoCapture];
    if(_publishSuccess) {
        [_engine reconnect];
    }
}

//返回
- (IBAction)closeBtnClick:(id)sender
{
    if (_engine.isPublishing)
    {
         [_engine stopLive];//停止活动
    }
    [_engine destoryObject];
    _engine = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }else
    {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}


#pragma mark - Lifecycle(Private)

- (void)registerLiveNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveDidEnterBackground)name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)initDatas
{
    _isAudioStart = NO;
    _torchType = NO;
    _onlyVideo = NO;
    _isFontVideo = NO;
    _videoResolution = VHHVideoResolution;
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];
    _hud = [[MBProgressHUD alloc]initWithView:self.perView];
    [self.perView addSubview:_hud];
    [_hud hideAnimated:YES];
    [self.perView addSubview:_closeBtn];
    
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
    
    _audioStartAndStopBtn.hidden = YES;
    
    _filterBtn.hidden = !self.beautifyFilterEnable;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    __weak __typeof(self) weakself = self;
    if(!_chatView) {
        _chatView = [[VHLiveChatView alloc] initWithFrame:CGRectMake(10, 0,_chatContainerView.width-10,_chatContainerView.height - 50) msgTotal:^NSInteger{
            return  weakself.chatDataArray.count;
        } msgSource:^VHActMsg *(NSInteger index) {
            return  weakself.chatDataArray[index];
        }action:nil];
    } else {
        _chatView.frame = CGRectMake(10, 0,_chatContainerView.width-10,_chatContainerView.height - 50);
    }

    [_chatContainerView addSubview:_chatView];
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        _backbtntopConstraint.constant = iPhoneX? 40 :20;
    }
    
    self.engine.displayView.frame = self.view.frame;
}

#pragma mark - 初始化推流器
- (void)initCameraEngine
{
    AVCaptureVideoOrientation captureVideoOrientation;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        captureVideoOrientation = AVCaptureVideoOrientationPortrait;
    }else {
        captureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;//设备左转，摄像头在左边
    }
    
    VHPublishConfig* config = [VHPublishConfig configWithType:VHPublishConfigTypeDefault];
    config.orientation = captureVideoOrientation;
//    config.pushType = VHStreamTypeOnlyAudio; //音频直播
    config.pushType = VHStreamTypeVideoAndAudio; //默认视频直播
    config.publishConnectTimes = 2;
    config.videoBitRate = self.videoBitRate<=0?700:self.videoBitRate;
    config.videoCaptureFPS = self.videoCaptureFPS<=0?15:self.videoCaptureFPS;
    config.isOpenNoiseSuppresion = self.isOpenNoiseSuppresion;
    config.videoResolution = self.videoResolution<=0?2:self.videoResolution;
    config.audioBitRate = self.audioBitRate<=0?64:self.audioBitRate;
    config.captureDevicePosition = AVCaptureDevicePositionBack;
    if(self.beautifyFilterEnable)
    {
        config.beautifyFilterEnable = YES;
        config.captureDevicePosition = AVCaptureDevicePositionFront;
        _isFontVideo = YES;
    }
    self.engine = [[VHallLivePublish alloc] initWithConfig:config];

    _torchBtn.hidden = YES;
    self.engine.delegate = self;

    self.engine.displayView.frame   = _perView.bounds;
    [self.perView insertSubview:_engine.displayView atIndex:0];
    
//    //开始视频采集、并显示预览界面
    [self.engine startVideoCapture];

    
    _noiseView.hidden = !_isOpenNoiseSuppresion;

    // chat 模块
    _chat = [[VHallChat alloc] initWithLivePublish:self.engine];
    _chat.delegate = self;
    
    if (self.beautifyFilterEnable) {
        [self filterSettingBtnClick:_defaultFilterSelectBtn];
    }
}

#pragma mark - 发起/停止直播
- (IBAction)startVideoPlayer:(UIButton *)sender
{
#if (TARGET_IPHONE_SIMULATOR)
    VH_ShowToast(@"无法在模拟器上发起直播！");
    return;
#endif
    
    if(sender.selected == NO) {  //开始直播
        [_hud showAnimated:YES];
        
        if(_publishSuccess) { //如果当前已经成功开播，且没有主动停止直播，但由于网络断开等问题导致被动停止，再次开播时，重连流即可
            [_engine reconnect];
        }else { //发起直播
            [_engine startLive:self.publishParam];
            _engine.displayView.frame   = _perView.bounds;
            [self.perView insertSubview:_engine.displayView atIndex:0];
            
            [_chatDataArray removeAllObjects];
            [_chatView update];
            _torchBtn.hidden = NO;
        }
    }else { //停止直播
        [UIAlertController showAlertControllerTitle:@"提示" msg:@"您是否要结束直播？" leftTitle:@"取消" rightTitle:@"结束" leftCallBack:^{
            return;
        } rightCallBack:^{
            [_engine stopLive];//停止直播
            [_engine destoryObject];
            _engine = nil;
            _publishSuccess = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

//发起/停止纯音频直播
- (IBAction)startAudioPlayer
{
//    TODO:暂时不支持此功能，但保留。
//    if (!_isAudioStart)
//    {
//        _isVideoStart = YES;
//        [self startVideoPlayer];
//
//        _logView.hidden = NO;
//        _chatBtn.hidden = NO;
//        [_hud show:YES];

//        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
//        param[@"id"] =  _roomId;
//        param[@"access_token"] = _token;
//        param[@"is_single_audio"] = @"1";   // 0 ：视频， 1：音频
//        [_engine startLive:param];
//    }else{
//        _logView.hidden = YES;
//        _bitRateLabel.text = @"";
//        _chatBtn.hidden = YES;
//        [_hud hide:YES];
//        [_audioStartAndStopBtn setTitle:@"音频直播" forState:UIControlStateNormal];
//        [_engine disconnect];//停止向服务器推流
//    }
//    _isAudioStart = !_isAudioStart;
}

#pragma mark - 基础操作
- (IBAction)swapBtnClick:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    btn.enabled=NO;
    _isFontVideo = !_isFontVideo;

    BOOL success=  [_engine swapCameras:_isFontVideo ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
    
    if(success)
    {
        _torchBtn.hidden = _isFontVideo;
        //禁止快速切换摄像头
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btn.enabled=YES;
        });
    }
    
    if (!self.engine.isPublishing) {
        _torchBtn.hidden = YES;
    }
}

- (IBAction)torchBtnClick:(UIButton*)sender
{
    _torchType = !_torchType;
    sender.selected = _torchType;
    [_engine setDeviceTorchModel:_torchType ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
}

- (IBAction)onlyVideoBtnClick:(UIButton*)sender
{
    _onlyVideo = !_onlyVideo;
    sender.selected = _onlyVideo;
    _engine.isMute = _onlyVideo;
}

- (BOOL)emCheckMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    return ret;
}

#pragma mark - 直播代理
//活动信息回调
- (void)publish:(VHallLivePublish *)publishObject webinarInfo:(VHWebinarInfo *)webinarInfo {
    VHLog(@"接收到活动信息");
}

-(void)firstCaptureImage:(UIImage *)image {
    VHLog(@"第一张图片");
}

-(void)publishStatus:(VHLiveStatus)liveStatus withInfo:(NSDictionary *)info {
    NSString *content = info[@"content"];
    
    switch (liveStatus)
    {
        case VHLiveStatusUploadSpeed:
        {
            _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
        }
            break;
        case VHLiveStatusPushConnectSucceed:
        {
            [_hud hideAnimated:YES];
            [self chatShow:YES];
            _publishSuccess = YES;
            _videoStartAndStopBtn.selected = YES;
            //设置画面填充模式
            [_engine setContentMode:VHRTMPMovieScalingModeAspectFill];
        }
            break;
        case VHLiveStatusSendError:
        {
            content = @"流发送失败";
            [self publishWithErrorMsg:content];
        }
            break;
        case VHLiveStatusPushConnectError:
        {
            NSString *str =[NSString stringWithFormat:@"连接失败:%@",content];
            [self publishWithErrorMsg:str];
        }
            break;
        case VHLiveStatusParamError:
        {
            content = @"参数错误";
            [self publishWithErrorMsg:content];
        }
            break;
        case VHLiveStatusGetUrlError:
        {
            [self publishWithErrorMsg:content];
        }
            break;
        case VHLiveStatusUploadNetworkOK:
        {
            _bitRateLabel.textColor = [UIColor greenColor];
            VHLog(@"kLiveStatusNetworkStatus:%@",content);
        }
            break;
        case VHLiveStatusUploadNetworkException:
        {
            _bitRateLabel.textColor = [UIColor redColor];
            VHLog(@"kLiveStatusNetworkStatus:%@",content);
        }
            break;
        case  VHLiveStatusAudioRecoderError : //音频采集失败
        {
            [self publishWithErrorMsg:content];
            
        }
            break;
        default:
            break;
    }
}

//推流失败提示
- (void)publishWithErrorMsg:(NSString *)msg {
    [_hud hideAnimated:YES];
    
    _bitRateLabel.text = @"";
    _videoStartAndStopBtn.selected = NO;
    [self chatShow:NO];
    [UIAlertController showAlertControllerTitle:msg msg:@"" btnTitle:@"确定" callBack:nil];
}


#pragma mark - 美颜设置
- (IBAction)filterBtnClick:(UIButton *)sender
{
//    [_chatMsgInput resignFirstResponder];
    _filterBtn.selected = !_filterBtn.selected;
    if(_filterBtn.selected)
    {
        _hideKeyBtn.hidden = NO;
        _filterView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _filterView.alpha = 1.0f;
        }];
    }
    else
    {
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
        case 1:[self.engine setBeautify:10.0f Brightness:1.0f  Saturation:1.0f Sharpness:0.0f];break;
        case 2:[self.engine setBeautify:8.0f  Brightness:1.05f Saturation:1.0f Sharpness:0.0f];break;
        case 3:[self.engine setBeautify:6.0f  Brightness:1.10f Saturation:1.0f Sharpness:0.0f];break;
        case 4:[self.engine setBeautify:4.0f  Brightness:1.15f Saturation:1.0f Sharpness:0.0f];break;
        case 5:[self.engine setBeautify:2.0f  Brightness:1.2f  Saturation:1.0f Sharpness:0.0f];break;
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
    }
    else
    {
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
        _bitRateLabel.text = @"0 kb/s";
        _bitRateLabel.textColor = [UIColor greenColor];
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
            msg.time= m.time;
            
            NSString *contextText = [NSString stringWithFormat:@"%@\n%@",m.text ? m.text : @"",m.imageUrls.count>0 ? [m.imageUrls componentsJoinedByString : @";"] : @""];
            
            msg.text = [NSString stringWithFormat:@"%@\n%@",m.time, contextText];
            
            [_chatDataArray addObject:msg];
        }
        [_chatView update];
    }
}

-(void)showTimeInfo{
    if(_timer)
    {
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

- (IBAction)noiseSliderValueVhange:(UISlider *)sender {
    _noiseLabel.text = [NSString stringWithFormat:@"音频增益：%f",sender.value];
    [_engine setVolumeAmplificateSize:sender.value];
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



- (VHKeyboardToolView *)messageToolView
{
    if (!_messageToolView)
    {
        _messageToolView = [[VHKeyboardToolView alloc] init];
        _messageToolView.delegate = self;
        [self.view addSubview:_messageToolView];
    }
    return _messageToolView;
}

- (NSMutableDictionary *)publishParam
{
    if (!_publishParam)
    {
        _publishParam = [[NSMutableDictionary alloc]init];
        _publishParam[@"id"] = _roomId;
        _publishParam[@"access_token"] = _token;
        _publishParam[@"nickname"] = _nick_name;
    }
    return _publishParam;
}

@end
