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

#import "PubLishLiveVC_Normal.h"
#import "PubLishLiveVC_Nodelay.h"
#import "VHHalfWatchLiveVC_Normal.h"
#import "VHHalfWatchLiveVC_Nodelay.h"
#import "VHPortraitWatchLiveVC_Normal.h"
#import "VHPortraitWatchLiveVC_Nodelay.h"
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
//发起常规直播
- (void)publishNormalLive:(UIInterfaceOrientation)orientation
{
    if (DEMO_Setting.activityID.length <= 0) {
        VH_ShowToast(@"请在设置中输入发直播活动ID");
        return;
    }
    
    [VHWebinarBaseInfo getWebinarBaseInfoWithWebinarId:DEMO_Setting.activityID success:^(VHWebinarBaseInfo * _Nonnull baseInfo) {
        if(baseInfo.no_delay_webinar == 1) { //无延迟
            VH_ShowToast(@"当前直播类型为无延迟直播");
            return;
        }
        
        PubLishLiveVC_Normal * liveVC = [[PubLishLiveVC_Normal alloc] init];
        liveVC.videoResolution  = [DEMO_Setting.videoResolution intValue];
        liveVC.roomId           = DEMO_Setting.activityID;
        liveVC.token            = DEMO_Setting.liveToken;
        liveVC.videoBitRate     = DEMO_Setting.videoBitRate;
        liveVC.audioBitRate     = DEMO_Setting.audioBitRate;
        liveVC.videoCaptureFPS  = DEMO_Setting.videoCaptureFPS;
        liveVC.interfaceOrientation = orientation;
        liveVC.isOpenNoiseSuppresion = DEMO_Setting.isOpenNoiseSuppresion;
        liveVC.beautifyFilterEnable  = DEMO_Setting.beautifyFilterEnable;
        liveVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVC animated:YES completion:nil];
    } fail:^(NSError * _Nonnull error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//发起无延迟直播
- (void)publishNodelayLive:(UIInterfaceOrientation)orientation {
    if (DEMO_Setting.activityID.length <= 0) {
        VH_ShowToast(@"请在设置中输入发直播活动ID");
        return;
    }
    
    [VHWebinarBaseInfo getWebinarBaseInfoWithWebinarId:DEMO_Setting.activityID success:^(VHWebinarBaseInfo * _Nonnull baseInfo) {
        if(baseInfo.no_delay_webinar == 0) { //非无延迟
            VH_ShowToast(@"当前直播类型为常规直播");
            return;
        }
        PubLishLiveVC_Nodelay * liveVC = [[PubLishLiveVC_Nodelay alloc] init];
        liveVC.roomId           = DEMO_Setting.activityID;
        liveVC.nick_name = DEMO_Setting.live_nick_name;
        liveVC.interfaceOrientation = orientation;
        if(baseInfo.webinar_type == 1) { //音频直播
            liveVC.streamType = VHInteractiveStreamTypeOnlyAudio;
        }else if(baseInfo.webinar_type == 2){ //视频直播
            liveVC.streamType = VHInteractiveStreamTypeAudioAndVideo;
        }
        liveVC.beautifyFilterEnable  = YES;
        liveVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVC animated:YES completion:nil];
    } fail:^(NSError * _Nonnull error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

#pragma mark - 互动直播
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
        if(baseInfo.webinar_type != 3) {
            VH_ShowToast(@"只支持互动直播");
            return;
        }
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

#pragma mark - 看直播
//半屏观看
- (void)halfScreenWatchLive {
    VHHalfWatchLiveVC_Normal * watchVC  = [[VHHalfWatchLiveVC_Normal alloc]init];
    watchVC.roomId      = DEMO_Setting.watchActivityID;
    watchVC.kValue      = DEMO_Setting.kValue;
    watchVC.bufferTimes = DEMO_Setting.bufferTimes;
    watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
    watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:watchVC animated:YES completion:nil];
}

//全屏观看
- (void)portraitWatchLive {
    VHPortraitWatchLiveVC_Normal * watchVC = [[VHPortraitWatchLiveVC_Normal alloc]init];
    watchVC.roomId      = DEMO_Setting.watchActivityID;
    watchVC.kValue      = DEMO_Setting.kValue;
    watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
    watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:watchVC animated:YES completion:nil];
}

//无延迟观看
- (void)nodelayWatchLive:(BOOL)isHalf {
    NSString *webinarId = DEMO_Setting.watchActivityID;
    [VHWebinarBaseInfo getWebinarBaseInfoWithWebinarId:webinarId success:^(VHWebinarBaseInfo * _Nonnull baseInfo) {
        if(baseInfo.no_delay_webinar == 0 && baseInfo.webinar_type == 3) { //常规互动直播
            //如果为常规互动直播，观众需要上麦（申请上麦被同意或被邀请上麦）后再进入互动房间，否则没有上麦直接进入非无延迟互动直播间，会占用房间用户名额，可能会导致其他嘉宾进房间失败>
            VH_ShowToast(@"观众没有上麦不建议直接进入常规互动房间");
            return;
        }
        if(isHalf) { //半屏
            VHHalfWatchLiveVC_Nodelay *watchVC  = [[VHHalfWatchLiveVC_Nodelay alloc]init];
            watchVC.roomId      = webinarId;
            watchVC.kValue      = DEMO_Setting.kValue;
            watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
            watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:watchVC animated:YES completion:nil];
        }else { //全屏
            VHPortraitWatchLiveVC_Nodelay * watchVC = [[VHPortraitWatchLiveVC_Nodelay alloc]init];
            watchVC.roomId      = DEMO_Setting.watchActivityID;
            watchVC.kValue      = DEMO_Setting.kValue;
            watchVC.interactBeautifyEnable = DEMO_Setting.inavBeautifyFilterEnable;
            watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:watchVC animated:YES completion:nil];
        }
    } fail:^(NSError * _Nonnull error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//网页观看
- (void)webViewWatchLive {
    VHWebWatchLiveViewController *watchVC = [[VHWebWatchLiveViewController alloc] init];
    watchVC.roomId = DEMO_Setting.watchActivityID;
    watchVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:watchVC animated:YES completion:nil];
}

#pragma mark - 看回放
//看回放
- (void)watchPlayBack {
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
            UIAlertAction *portraitLive_normal = [UIAlertAction actionWithTitle:@"竖屏直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self publishNormalLive:UIInterfaceOrientationPortrait];
            }];
            UIAlertAction *landscapeLive_normal = [UIAlertAction actionWithTitle:@"横屏直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self publishNormalLive:UIInterfaceOrientationLandscapeRight];
            }];
            UIAlertAction *portraitLive_nodelay = [UIAlertAction actionWithTitle:@"竖屏无延迟直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self publishNodelayLive:UIInterfaceOrientationPortrait];
            }];
            UIAlertAction *landscapeLive_nodelay = [UIAlertAction actionWithTitle:@"横屏无延迟直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self publishNodelayLive:UIInterfaceOrientationLandscapeRight];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:portraitLive_normal];
            [alertController addAction:landscapeLive_normal];
            [alertController addAction:portraitLive_nodelay];
            [alertController addAction:landscapeLive_nodelay];
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
            
            UIAlertAction *halfScreenWatch = [UIAlertAction actionWithTitle:@"半屏观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self halfScreenWatchLive];
            }];
            
            UIAlertAction *portraitWatch = [UIAlertAction actionWithTitle:@"全屏观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self portraitWatchLive];
            }];
            
            UIAlertAction *halfScreen_NodelayWatch = [UIAlertAction actionWithTitle:@"半屏无延迟观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self nodelayWatchLive:YES];
            }];
            
            UIAlertAction *portrait_NodelayWatch = [UIAlertAction actionWithTitle:@"全屏无延迟观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self nodelayWatchLive:NO];
            }];

            UIAlertAction *webWatch = [UIAlertAction actionWithTitle:@"web嵌入观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self webViewWatchLive];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:halfScreenWatch];
            [alertController addAction:portraitWatch];
            [alertController addAction:halfScreen_NodelayWatch];
            [alertController addAction:portrait_NodelayWatch];
            [alertController addAction:webWatch];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case 3://观看回放
        {
            [self watchPlayBack];
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
        [ProgressHud showLoading];
        [VHallApi logout:^{
            [ProgressHud hideLoading];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
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
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
