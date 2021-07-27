//
//  VHinteractiveViewController.m
//  UIModel
//
//  Created by vhall on 2018/7/30.
//  Copyright © 2018年 www.vhall.com. All rights reserved.
//

#import "VHinteractiveViewController.h"
#import <VHInteractive/VHRoom.h>
#import <VHLiveSDK/VHallApi.h>
#import "UIAlertController+ITTAdditionsUIModel.h"
#import "Masonry.h"

#define iconSize 34

@interface VHinteractiveViewController ()<VHRoomDelegate>

@property (nonatomic, strong) VHRoom *interactiveRoom;//互动房间
@property (nonatomic, strong) VHLocalRenderView *cameraView;//本地摄像头

@property (nonatomic, strong) NSMutableArray *views;
/** 摄像头切换按钮 */
@property (nonatomic, strong) UIButton *swapBtn;
/** 摄像头开关按钮 */
@property (nonatomic, strong) UIButton *cameraBtn;
/** 麦克风按钮 */
@property (nonatomic, strong) UIButton *micBtn;
/** 下麦按钮 */
@property (nonatomic, strong) UIButton *closeBtn;

/** 互动工具view */
@property (nonatomic, strong) UIView *toolView;

@end

@implementation VHinteractiveViewController

- (instancetype)init {
    if (self = [super init]) {
        
        _views = [NSMutableArray array];
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cameraView.frame = self.view.bounds;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
    
    NSString *roomId = [NSString stringWithFormat:@"%@",self.joinRoomPrams[@"id"]];
    if (!roomId) {
        [UIAlertController showAlertControllerTitle:@"温馨提示" msg:@"互动房间id不能为空" btnTitle:@"确定" callBack:^{
            
        }];
    } else {
        //进入互动房间
        [self.interactiveRoom enterRoomWithParams:self.joinRoomPrams];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //程序进入前后台监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)appBecomeActive {
    //推流
    [_interactiveRoom publishWithCameraView:_cameraView];
}
- (void)appEnterBackground {
    //停止推流
    [_interactiveRoom unpublish];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",self.description);
    
    _interactiveRoom = nil;
    _cameraView = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubViews
{
    [self setUpCameraView];
    
    [self setUpTopButtons];
}

- (void)setUpTopButtons {
    
    _toolView = [[UIView alloc] init];
    [self.view addSubview:_toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(iconSize);
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(self);
    }];
    
    //切换摄像头按钮
    UIButton *swapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [swapBtn setBackgroundImage:BundleUIImage(@"icon_video_camera_switching") forState:UIControlStateNormal];
    [swapBtn setBackgroundImage:BundleUIImage(@"icon_video_camera_switching") forState:UIControlStateSelected];
    [swapBtn addTarget:self action:@selector(swapStatusChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:swapBtn];
    _swapBtn = swapBtn;
    [swapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.toolView);
        make.width.centerX.equalTo(self.toolView);
        make.height.equalTo(swapBtn.mas_width);
    }];

    //开关摄像头按钮
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraBtn setBackgroundImage:BundleUIImage(@"icon_video_open_camera") forState:UIControlStateNormal];
    [_cameraBtn setBackgroundImage:BundleUIImage(@"icon_video_close_camera") forState:UIControlStateSelected];
    [_cameraBtn addTarget:self action:@selector(videoStatusChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:_cameraBtn];
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.swapBtn.mas_bottom).offset(12);
        make.width.centerX.equalTo(self.toolView);
        make.height.equalTo(_cameraBtn.mas_width);
    }];

    //麦克风按钮
    _micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_micBtn setBackgroundImage:BundleUIImage(@"icon_video_open_microphone") forState:UIControlStateNormal];
    [_micBtn setBackgroundImage:BundleUIImage(@"icon_video_close_microphone") forState:UIControlStateSelected];
    [_micBtn addTarget:self action:@selector(micBtnStatusChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:_micBtn];
    [_micBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cameraBtn.mas_bottom).offset(12);
        make.width.centerX.equalTo(self.toolView);
        make.height.equalTo(_micBtn.mas_width);
    }];

    //下麦按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(_micBtn.left, _micBtn.bottom+12, iconSize, iconSize);
    [closeBtn setBackgroundImage:BundleUIImage(@"icon_video_lowerwheat") forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:closeBtn];
    _closeBtn = closeBtn;
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.micBtn.mas_bottom).offset(12);
        make.width.centerX.bottom.equalTo(self.toolView);
        make.height.equalTo(closeBtn.mas_width);
    }];
}
- (void)setUpCameraView {
    //创建本地摄像头视图
    _cameraView = nil;
    [_cameraView removeFromSuperview];
    self.cameraView.frame = self.view.bounds;
    [self.view insertSubview:self.cameraView atIndex:0];
}


#pragma mark - VHRoomDelegate
//进入互动房间回调
- (void)room:(VHRoom *)room enterRoomWithError:(NSError *)error {
    if (error) {
        __weak typeof(self) wf = self;
        [UIAlertController showAlertControllerTitle:@"温馨提示" msg:[NSString stringWithFormat:@"错误:%@",error.description] btnTitle:@"确定" callBack:^{
            [wf closeButtonClick:nil];
        }];
        VHLog(@"错误:%@",error.description);
    }
}
// 房间连接成功
- (void)room:(VHRoom *)room didConnect:(NSDictionary *)roomMetadata
{
    //上麦推流
    [room publishWithCameraView:self.cameraView];
    VHLog(@"房间连接成功，开始推流");
}
// 房间错误回调
- (void)room:(VHRoom *)room didError:(VHRoomErrorStatus)status reason:(NSString *)reason
{
    __weak typeof(self) wf = self;
    [UIAlertController showAlertControllerTitle:@"温馨提示" msg:[NSString stringWithFormat:@"互动房间连接出错：%@",reason] btnTitle:@"确定" callBack:^{
        [wf closeButtonClick:nil];
    }];
    VHLog(@"房间连接错误%@",reason);
}
// 房间状态变化
- (void)room:(VHRoom *)room didChangeStatus:(VHRoomStatus)status
{
    
}
//推流成功
- (void)room:(VHRoom *)room didPublish:(VHRenderView *)cameraView
{
    VHLog(@"推流成功");
}
//停止推流成功
- (void)room:(VHRoom *)room didUnpublish:(VHRenderView *)cameraView
{
    VHLog(@"停止推流");
    [self closeButtonClick:nil];
}

// 有新的成员加入互动
- (void)room:(VHRoom *)room didAddAttendView:(VHRenderView *)attendView
{
    attendView.scalingMode = VHRenderViewScalingModeAspectFill;
    [self addView:attendView];
}
//有成员离开互动
- (void)room:(VHRoom *)room didRemovedAttendView:(VHRenderView *)attendView
{
    [self showMsg:[NSString stringWithFormat:@"%@ 已下麦",attendView.userId] afterDelay:0];
    
    [self removeView:attendView];
}

/*
    自己下麦
 */
- (void)leaveInteractiveRoomByHost:(VHRoom *)room
{
    [UIModelTools showMsgInWindow:@"您已被主播下麦" afterDelay:3 offsetY:100];
    //退出
    [self closeButtonClick:nil];
}

/*
    自己的麦克风状态改变
 */
- (void)room:(VHRoom *)room microphoneClosed:(BOOL)isClose
{
    NSLog(@"麦克风");
    _micBtn.selected = isClose;
}

/*
    自己的摄像头状态改变
 */
- (void)room:(VHRoom *)room screenClosed:(BOOL)isClose
{
    NSLog(@"摄像头");
    _cameraBtn.selected = isClose;
}


//互动房间互动消息处理
- (void)room:(VHRoom *)room interactiveMsgWithEventName:(NSString *)eventName attribute:(id)attributes
{
    //麦克风/摄像头操作
    if ([attributes[@"type"] isEqualToString:@"*switchDevice"]) {
        /*
         device = 1;            // 1 麦克风 2 摄像头
         "join_uid" = 1167475;  //被操作用户参会id
         status = 0;            //0 关闭 1 打开
         type = "*switchDevice";
         */
        if ([attributes[@"device"] intValue] == 1)
        {
            if ([attributes[@"status"] intValue] == 0)
            {
                [self.cameraView muteAudio];
                _micBtn.selected = YES;
            }
            else
            {
                [self.cameraView unmuteAudio];
                _micBtn.selected = NO;
            }
        }
        else if ([attributes[@"device"] intValue] == 2)
        {
            if ([attributes[@"status"] intValue] == 0)
            {
                [self.cameraView muteVideo];
                _cameraBtn.selected = YES;
            }
            else
            {
                [self.cameraView unmuteVideo];
                _cameraBtn.selected = NO;
            }
        }
    }
    //下麦
    else if ([attributes[@"type"] isEqualToString:@"*notSpeak"]) {
        /*
         "join_uid" = 1167475;  //操作人参会id
         "nick_name" = 900530;  //被操作者昵称
         "role_name" = user;    //
         type = "*notSpeak";    //
         */
        
        //离开互动房间
        [self closeButtonClick:nil];
    }
    //...其他消息
    //Code...
}

/*
 * iskickout 被踢出房间
 */
- (void)room:(VHRoom *)room iskickout:(BOOL)iskickout
{
    [self kickOut];
    [self showMsgInWindow:@"已被踢出互动" afterDelay:1];
}

//直播结束回调
- (void)room:(VHRoom *)room liveOver:(BOOL)liveOver
{
    [self closeButtonClick:nil];
}
/**
 * 收到自己被禁言/取消禁言
 */
- (void)room:(VHRoom *)room forbidChat:(BOOL)forbidChat
{
    
    [self showMsg:forbidChat?@"您已被禁言":@"您已被取消禁言" afterDelay:1];
    //被禁言后，退出
    [self closeButtonClick:nil];
}
/**
 * 收到全体禁言/取消全体禁言
 */
- (void)room:(VHRoom *)room allForbidChat:(BOOL)allForbidChat
{
    [self showMsg:allForbidChat?@"已开启全体禁言":@"已取消全体禁言" afterDelay:1];
}

#pragma mark - button click
//退出
- (void)closeButtonClick:(UIButton *)sender {
    [self stopInteractive];
    //返回上级页面
    if(self.delegate && [self.delegate respondsToSelector:@selector(interactiveViewClose:byKickOut:)]) {
        [self.delegate interactiveViewClose:self byKickOut:NO];
    }else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

//停止互动，移除相关视图
- (void)stopInteractive {
    //停止推流
    [_interactiveRoom unpublish];
    //移除互动视频
    [self removeAllViews];
    //停止流状态监听
    [_cameraView stopStats];
    //离开互动房间
    [_interactiveRoom leaveRoom];
    _interactiveRoom = nil;
}

//摄像头切换
- (void)swapStatusChanged:(UIButton *)sender {
    _cameraView.hidden = YES;
    AVCaptureDevicePosition position = [_cameraView switchCamera];
    _cameraView.transform = CGAffineTransformMakeScale((position == AVCaptureDevicePositionFront)?-1:1,1);//镜像
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _cameraView.hidden = NO;
    });
}

//麦克风按钮事件
- (void)micBtnStatusChanged:(UIButton *)sender {
    //麦克风按钮图标变更
    sender.selected = !sender.selected;
    //麦克风操作
    (sender.selected) ? [_cameraView muteAudio] : [_cameraView unmuteAudio];
}
//摄像头按钮事件
- (void)videoStatusChanged:(UIButton *)sender {
    //麦克风按钮图标变更
    sender.selected = !sender.selected;
    //摄像头操作
    (sender.selected) ? [_cameraView muteVideo] : [_cameraView unmuteVideo];
}


//被踢出
- (void)kickOut {
    [self stopInteractive];
    //踢出返回
    if(self.delegate && [self.delegate respondsToSelector:@selector(interactiveViewClose:byKickOut:)]) {
        [self.delegate interactiveViewClose:self byKickOut:YES];
    }else {
        UIViewController *vc = self;
        Class homeVcClass = NSClassFromString(@"VHHomeViewController");
        while (![vc isKindOfClass:homeVcClass]) {
            vc = vc.presentingViewController;
        }
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


#pragma mark - 互动观众
- (void)addView:(UIView*)view
{
    NSUInteger idx = [self.views indexOfObject:view];
    if(idx != NSNotFound) return;
    
    [self.views addObject:view];
    [self updateUI];
}
- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];
    [self.views removeObject:view];
    [self updateUI];
}
- (void)removeAllViews
{
    for (UIView *v in self.views) {
        [v removeFromSuperview];
    }
    [self.views removeAllObjects];
}
- (void)updateUI
{
    int i = 0;
    for (UIView *view in self.views) {
        view.frame = CGRectMake(8, 28+i*(80+1), 140, 80);
        [self.view addSubview:view];
        i++;
    }
}

- (VHRoom *)interactiveRoom {
    if (!_interactiveRoom) {
        _interactiveRoom = [[VHRoom alloc] init];
        _interactiveRoom.delegate = self;
    }
    return _interactiveRoom;
}
- (VHLocalRenderView *)cameraView {
    if (!_cameraView) {
        
        //设置中设置的推流分辨率
        NSDictionary* options = @{VHFrameResolutionTypeKey:@(VHFrameResolution640x480),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};
        switch (_pushResolution) {
            case 0:options = @{VHFrameResolutionTypeKey:@(VHFrameResolution192x144),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};break;
            case 1:options = @{VHFrameResolutionTypeKey:@(VHFrameResolution320x240),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};break;
            case 2:options = @{VHFrameResolutionTypeKey:@(VHFrameResolution480x360),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};break;
            case 3:options = @{VHFrameResolutionTypeKey:@(VHFrameResolution640x480),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};break;
            default:
                break;
        }
        
        _cameraView = [[VHLocalRenderView alloc] initCameraViewWithFrame:CGRectZero options:options];
        _cameraView.scalingMode = VHRenderViewScalingModeAspectFill;
        //设置摄像头旋转方向，注意：如需要转屏请自行监听屏转，设置摄像头orientation。
        [_cameraView setDeviceOrientation:UIDeviceOrientationPortrait];
        _cameraView.transform = CGAffineTransformMakeScale(-1,1);//镜像
        _cameraView.beautifyEnable = _inavBeautifyFilterEnable;

        //设置自己的视频流用户信息，使其他端可从视频流中获取该信息
        NSDictionary *attributes = @{
            @"nickName":[VHallApi currentUserNickName], //昵称
            @"role":@(2), // 1主持人 2观众 3助理 4嘉宾
            @"avatar":[VHallApi currentUserHeadUrl]}; //头像
        [_cameraView setAttributes:[UIModelTools jsonStringWithObject:attributes]];
    }
    return _cameraView;
}

@end
