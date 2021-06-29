//
//  VHLiveBaseVC.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBaseVC.h"
#import "VHPrivacyManager.h"
#import "VHAlertView.h"
@interface VHLiveBaseVC ()

/** 黑色返回按钮（导航栏隐藏时可添加） */
@property (nonatomic, strong) UIButton *blackBackBtn;
/** 返回事件回调 */
@property (nonatomic, copy) void(^backBlock)(void);
/** 相机权限 */
@property (nonatomic, assign) BOOL videoAccess;
/** 麦克风权限 */
@property (nonatomic, assign) BOOL audioAccess;
/** 列表空视图 */
@property (nonatomic, strong) UIView *emptyView;

@end

@implementation VHLiveBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MakeColorRGB(0xF7F7F7);
}

//获取摄像头与麦克风权限
- (void)getMediaAccess:(void(^_Nullable)(BOOL videoAccess,BOOL audioAcess))completionBlock {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        //相机权限
        [VHPrivacyManager openCaptureDeviceServiceWithBlock:^(BOOL isOpen) {
            NSLog(@"相机权限：%d",isOpen);
            self.videoAccess = isOpen;
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_group_enter(group);
        //麦克风权限
        [VHPrivacyManager openRecordServiceWithBlock:^(BOOL isOpen) {
            NSLog(@"麦克风权限：%d",isOpen);
            self.audioAccess = isOpen;
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionBlock ? completionBlock(self.videoAccess,self.audioAccess) : nil;
    });
}

//弹出媒体权限提示
- (void)shwoMediaAuthorityAlertWithMessage:(NSString *)string {
    [VHAlertView showAlertWithTitle:string content:nil cancelText:nil cancelBlock:nil confirmText:@"去设置" confirmBlock:^{
        // 去设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

//是否可以旋转
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAllButUpsideDown;
    return UIInterfaceOrientationMaskPortrait;
}
//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


//是否开启侧滑返回（集成QMUIKit需要加这个代码）
- (BOOL)forceEnableInteractivePopGestureRecognizer {
    return YES;
}

//是否隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return NO;
}
// 状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

//强制旋转屏幕方向
- (void)forceRotateUIInterfaceOrientation:(UIInterfaceOrientation)orientation {
    NSLog(@"强制转屏开始");
    _forceRotating = YES;

    NSNumber *orientationUnknown = [NSNumber numberWithInt:0];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    _forceRotating = NO;
    NSLog(@"强制转屏结束");
}

//返回
- (void)backBtnClick {
    if(self.backBlock) {
        self.backBlock();
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showLoading {
    MBProgressHUD *hud = [ProgressHud showLoading:@"" inView:self.view];
    hud.userInteractionEnabled = NO;
}

- (void)hiddenLoading {
    [ProgressHud hideLoadingInView:self.view];
}

- (void)addBackBtnActionClick:(void(^_Nullable)(void))backBlock {
    self.backBlock = backBlock;
    [self.view addSubview:self.blackBackBtn];
    [self.blackBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(45, 45)));
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(VH_KStatusBarHeight);
    }];
}

- (void)setShowEmptyView:(BOOL)showEmptyView {
    _showEmptyView = showEmptyView;
    if(showEmptyView) {
        [self.view bringSubviewToFront:self.emptyView];
    }
    self.emptyView.hidden = !showEmptyView;
}

- (UIButton *)blackBackBtn
{
    if (!_blackBackBtn)
    {
        _blackBackBtn = [[UIButton alloc] init];
        [_blackBackBtn setImage:BundleUIImage(@"icon_return_black") forState:UIControlStateNormal];
        [_blackBackBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        _blackBackBtn.backgroundColor = [UIColor blueColor];
    }
    return _blackBackBtn;
}

- (UIView *)emptyView
{
    if (!_emptyView)
    {
        _emptyView = [[UIView alloc] init];
        _emptyView.hidden = YES;
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.width.equalTo(self.view);
            make.height.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

- (UIImageView *)emptyIcon
{
    if (!_emptyIcon)
    {
        _emptyIcon = [[UIImageView alloc] init];
        [self.emptyView addSubview:_emptyIcon];
        [self.emptyIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(self.emptyView);
            make.size.equalTo(@(CGSizeMake(96, 70)));
        }];
    }
    return _emptyIcon;
}

- (UILabel *)emptyLab
{
    if (!_emptyLab)
    {
        _emptyLab = [[UILabel alloc] init];
        _emptyLab.textColor = MakeColorRGB(0x999999);
        _emptyLab.font = FONT_FZZZ(16);
        _emptyLab.numberOfLines = 2;
        _emptyLab.textAlignment = NSTextAlignmentCenter;
        [self.emptyView addSubview:_emptyLab];
        [_emptyLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emptyIcon.mas_bottom).offset(12);
            make.centerX.bottom.equalTo(self.emptyView);
            make.left.equalTo(self.emptyView).offset(10);
            make.right.equalTo(self.emptyView).offset(-10);
        }];
    }
    return _emptyLab;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
