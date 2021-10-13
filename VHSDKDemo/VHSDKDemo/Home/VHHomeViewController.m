//
//  HomeViewController.m
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "VHHomeViewController.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import <VHLiveSDK/VHallApi.h>

#import "LaunchLiveViewController.h"
#import "WatchLiveViewController.h"
#import "VHPortraitWatchLiveViewController.h"
#import "WatchPlayBackViewController.h"

#import "VHStystemSetting.h"
#import "VHSettingViewController.h"
#import "VHWebWatchLiveViewController.h"
#import "VHNavigationController.h"
#import "VHInteractLiveVC_New.h"
#import "UIModel.h"

@interface VHHomeViewController ()<VHallApiDelegate>
@property (weak, nonatomic) IBOutlet UILabel        *deviceCategory;
@property (weak, nonatomic) IBOutlet UIButton       *loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView    *headImage;//头像
@property (weak, nonatomic) IBOutlet UILabel        *nickName;//昵称
@property (weak, nonatomic) IBOutlet UILabel        *activityIdLabel;//发起活动id
@property (weak, nonatomic) IBOutlet UILabel        *watchActivityIdLabel;//观看id

@property (weak, nonatomic) IBOutlet UIButton *btn0;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@end

@implementation VHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateUI];
    
    [VHallApi registerDelegate:self];
    
    NSArray *arr =@[_btn0,_btn1,_btn2,_btn3];
    for (UIButton*btn in arr) {
        CGSize image = btn.imageView.frame.size;
        CGSize title = btn.titleLabel.frame.size;
        
        btn.titleEdgeInsets =UIEdgeInsetsMake(50, -0.5*image.width, 0, 0.5*image.width);
        btn.imageEdgeInsets =UIEdgeInsetsMake(-38, 0.5*title.width, 0, -0.5*title.width);
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

-(void)updateUI
{
    _nickName.text              = [VHallApi currentUserNickName];
    _loginBtn.selected          = [VHallApi isLoggedIn];
    _deviceCategory.text        = [UIDevice currentDevice].name;
    _activityIdLabel.text       = [@"发起ID:" stringByAppendingString:DEMO_Setting.activityID];//发起活动id
    _watchActivityIdLabel.text  = [@"观看ID:" stringByAppendingString:DEMO_Setting.watchActivityID];//观看id
    
    
    [_headImage sd_setImageWithURL:[NSURL URLWithString:[VHallApi currentUserHeadUrl]] placeholderImage:[UIImage imageNamed:@"defaultHead"]];
}

#pragma mark - 发直播
- (void)startLive:(UIInterfaceOrientation)orientation
{
    if (DEMO_Setting.activityID.length<=0) {
        VH_ShowToast(@"请在设置中输入发直播活动ID");
        return;
    }
    if (DEMO_Setting.liveToken == nil||DEMO_Setting.liveToken<=0) {
        VH_ShowToast(@"请在设置中输入token");
        return;
    }
    if (DEMO_Setting.videoBitRate<=0 || DEMO_Setting.audioBitRate<=0) {
        VH_ShowToast(@"码率不能为负数");
        return;
    }
    if (DEMO_Setting.videoCaptureFPS< 1 || DEMO_Setting.videoCaptureFPS>30) {
        VH_ShowToast(@"帧率设置错误[1-30]");
        return;
    }
    
    LaunchLiveViewController * rtmpLivedemoVC = [[LaunchLiveViewController alloc] init];
    rtmpLivedemoVC.videoResolution  = [DEMO_Setting.videoResolution intValue];
    rtmpLivedemoVC.roomId           = DEMO_Setting.activityID;
    rtmpLivedemoVC.token            = DEMO_Setting.liveToken;
    rtmpLivedemoVC.videoBitRate     = DEMO_Setting.videoBitRate;
    rtmpLivedemoVC.audioBitRate     = DEMO_Setting.audioBitRate;
    rtmpLivedemoVC.videoCaptureFPS  = DEMO_Setting.videoCaptureFPS;
    rtmpLivedemoVC.interfaceOrientation = orientation;
    rtmpLivedemoVC.isOpenNoiseSuppresion = DEMO_Setting.isOpenNoiseSuppresion;
    rtmpLivedemoVC.beautifyFilterEnable  = DEMO_Setting.beautifyFilterEnable;
    rtmpLivedemoVC.nick_name = DEMO_Setting.live_nick_name;
    rtmpLivedemoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:rtmpLivedemoVC animated:YES completion:nil];
}

#pragma mark - 进入互动直播
- (void)enterInteractLiveRoomWithIsHost:(BOOL)isHost {
    if (isHost && DEMO_Setting.activityID.length<=0) {
        VH_ShowToast(@"请在设置中输入发直播活动ID");
        return;
    }
    if (!isHost && DEMO_Setting.watchActivityID.length<=0) {
        VH_ShowToast(@"请在设置中输入看直播活动ID");
        return;
    }
    if (!isHost && (DEMO_Setting.codeWord == nil||DEMO_Setting.codeWord<=0)) {
        VH_ShowToast(@"请在设置中输入口令");
        return;
    }

    NSString *webinarId = isHost ? DEMO_Setting.activityID : DEMO_Setting.watchActivityID;
    [VHWebinarBaseInfo getWebinarBaseInfoWithWebinarId:webinarId success:^(VHWebinarBaseInfo * _Nonnull baseInfo) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
        if(isHost) { //主持人
            params[@"id"] = DEMO_Setting.activityID;
            params[@"nickname"] = self.nickName.text;
            params[@"avatar"] = [VHallApi currentUserHeadUrl];
        }else { //嘉宾
            params[@"id"] = DEMO_Setting.watchActivityID;
            params[@"nickname"] = self.nickName.text;
            params[@"password"] = DEMO_Setting.codeWord;
            params[@"avatar"] = DEMO_Setting.inva_avatar;
        }
        VHInteractLiveVC_New *vc = [[VHInteractLiveVC_New alloc] initWithParams:params isHost:isHost screenLandscape:baseInfo.webinar_show_type];
        vc.inav_num = baseInfo.inav_num;
        VHNavigationController *nav = [[VHNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    } fail:^(NSError * _Nonnull error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

#pragma mark - UI事件
//横屏直播/竖屏直播/观看直播/观看回放
- (IBAction)btnClick:(UIButton*)sender
{
    _btn0.selected = _btn1.selected = _btn2.selected = _btn3.selected =NO;
    sender.selected = YES;
   
    switch (sender.tag) {
        case 0://发起直播
        {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *landscapeLive = [UIAlertAction actionWithTitle:@"竖屏直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startLive:UIInterfaceOrientationPortrait];
            }];
            UIAlertAction *portraitLive = [UIAlertAction actionWithTitle:@"横屏直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startLive:UIInterfaceOrientationLandscapeRight];//设备左转，摄像头在左边
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:landscapeLive];
            [alertController addAction:portraitLive];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case 1://进入互动直播
        {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *hostJoin = [UIAlertAction actionWithTitle:@"主播进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self enterInteractLiveRoomWithIsHost:YES];
            }];
            UIAlertAction *guestJoin = [UIAlertAction actionWithTitle:@"嘉宾进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self enterInteractLiveRoomWithIsHost:NO];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:hostJoin];
            [alertController addAction:guestJoin];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case 2://观看直播
        {
            if (DEMO_Setting.watchActivityID.length<=0) {
                VH_ShowToast(@"请在设置中输入活动ID");
                return;
            }
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *landscapeWatch = [UIAlertAction actionWithTitle:@"半屏观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                WatchLiveViewController * watchVC  = [[WatchLiveViewController alloc]init];
                watchVC.roomId      = DEMO_Setting.watchActivityID;
                watchVC.kValue      = DEMO_Setting.kValue;
                watchVC.bufferTimes = DEMO_Setting.bufferTimes;
                watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
                watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:watchVC animated:YES completion:nil];
            }];
            
            UIAlertAction *portraitWatch = [UIAlertAction actionWithTitle:@"全屏观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                VHPortraitWatchLiveViewController * watchVC = [[VHPortraitWatchLiveViewController alloc]init];
                watchVC.roomId      = DEMO_Setting.watchActivityID;
                watchVC.kValue      = DEMO_Setting.kValue;
                watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
                watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:watchVC animated:YES completion:nil];
            }];

            UIAlertAction *webWatch = [UIAlertAction actionWithTitle:@"web嵌入观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                VHWebWatchLiveViewController *watchVC = [[VHWebWatchLiveViewController alloc] init];
                watchVC.roomId = DEMO_Setting.watchActivityID;
                watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:watchVC animated:YES completion:nil];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:landscapeWatch];
            [alertController addAction:portraitWatch];
            [alertController addAction:webWatch];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];

        }
            break;
        case 3://观看回放
        {
            if (DEMO_Setting.watchActivityID.length<=0) {
                VH_ShowToast(@"请在设置中输入活动ID");
                return;
            }
            WatchPlayBackViewController * watchVC  =[[WatchPlayBackViewController alloc]init];
            watchVC.roomId = DEMO_Setting.watchActivityID;
            watchVC.kValue = DEMO_Setting.kValue;
            watchVC.timeOut = DEMO_Setting.timeOut*1000;
            watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:watchVC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

//参数设置
- (IBAction)systemSettingClick:(id)sender
{
    VHSettingViewController *settingVc=[[VHSettingViewController alloc] init];
    settingVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingVc animated:YES completion:nil];
}

//登录/退出
- (IBAction)loginOrloginOutClick:(id)sender
{
    if(self.loginBtn.selected) { //退出登录
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [MBProgressHUD showHUDAddedTo:window animated:YES];
        [VHallApi logout:^{
            [MBProgressHUD hideHUDForView:window animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
            [MBProgressHUD showHUDAddedTo:window animated:YES];
            VH_ShowToast(error.localizedDescription);
        }];
    }
}

//头像
- (IBAction)headBtnClicked:(id)sender
{
    if (![VHallApi isLoggedIn])
        return;
    
    Class class= objc_getClass("VHListViewController");
    if(class)
    {
        UIViewController* vc = ((UIViewController*)[[class alloc] init]);
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - VHallApiDelegate
- (void)vHallApiTokenDidError:(NSError *)error {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
