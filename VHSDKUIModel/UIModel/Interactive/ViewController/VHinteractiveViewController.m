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
//分辨率提示
@property (nonatomic, strong) UILabel *resolutionLab;
/** 互动工具view */
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIScrollView *scrollView;

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
    self.resolutionLab.frame = CGRectMake(VHScreenWidth - 200-10, VH_KStatusBarHeight, 200, 20);
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
    [self.view insertSubview:self.resolutionLab aboveSubview:self.cameraView];
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
    NSString *string = [NSString stringWithFormat:@"%@ 已下麦",attendView.userId];
    VH_ShowToast(string);    
    [self removeView:attendView];
}

/*
    自己下麦
 */
- (void)leaveInteractiveRoomByHost:(VHRoom *)room
{
    [ProgressHud showToast:@"您已被主播下麦" offsetY:100];
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

        //离开互动房间
        [self closeButtonClick:nil];
    }
    //...其他消息
    //Code...
}

/*
 * 自己被踢出房间回调
 */
- (void)room:(VHRoom *)room iskickout:(BOOL)iskickout
{
    [self kickOut];
    VH_ShowToast(@"您已被踢出互动");
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
    VH_ShowToast(forbidChat?@"您已被禁言":@"您已被取消禁言");
    //被禁言后，退出
    [self closeButtonClick:nil];
}
/**
 * 收到全体禁言/取消全体禁言
 */
- (void)room:(VHRoom *)room allForbidChat:(BOOL)allForbidChat
{
    VH_ShowToast(allForbidChat?@"已开启全体禁言":@"已取消全体禁言");
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
- (void)updateUI {
    
    for (int i = 0 ; i < self.views.count ; i++ ) {
        UIView *view = self.views[i];
        view.frame = CGRectMake(0, 0 + i*(80+1), self.scrollView.width, 80);
        [self.scrollView addSubview:view];
        if(i == self.views.count - 1) {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width, CGRectGetMaxY(view.frame));
        }
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
        
        VHFrameResolutionValue resolution = VHFrameResolution480x360;
        //根据当前活动支持的连麦人数来设置分辨率
        if (self.inav_num > 0 && self.inav_num <= 5) {
            resolution = VHFrameResolution480x360;
            self.resolutionLab.text = @"推流分辨率：480x360";
        } else if (self.inav_num > 5 && self.inav_num < 10) {
            resolution = VHFrameResolution320x240;
            self.resolutionLab.text = @"推流分辨率：320x240";
        }else{
            resolution = VHFrameResolution240x160;
            self.resolutionLab.text = @"推流分辨率：240x160";
        }
        NSDictionary* options = @{VHFrameResolutionTypeKey:@(resolution),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo)};
        
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

- (UILabel *)resolutionLab {
    if(!_resolutionLab) {
        _resolutionLab = [[UILabel alloc] init];
        _resolutionLab.textColor = [UIColor whiteColor];
        _resolutionLab.font = [UIFont systemFontOfSize:10];
        _resolutionLab.textAlignment = NSTextAlignmentRight;
    }
    return _resolutionLab;
}


- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.frame = CGRectMake(8, VH_KStatusBarHeight, 140, VHScreenHeight - VH_KStatusBarHeight - VH_KBottomSafeMargin - 10);
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
@end
