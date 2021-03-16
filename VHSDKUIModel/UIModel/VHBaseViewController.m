//
//  BaseViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "VHBaseViewController.h"
#import "MBProgressHUD.h"
@interface VHBaseViewController ()

@end

@implementation VHBaseViewController

#pragma mark - Public Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}


#pragma mark - Lifecycle Method
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_interfaceOrientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return _interfaceOrientation;
}


//强制旋转屏幕方向
- (void)forceRotateUIInterfaceOrientation:(UIInterfaceOrientation)orientation {
    VHLog(@"强制转屏开始");
    _forceRotating = YES;
    //方式一：
    NSNumber *orientationUnknown = [NSNumber numberWithInt:0];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    _forceRotating = NO;
    
    //    //方式二：
    ////    UIInterfaceOrientation unknow = UIInterfaceOrientationUnknown;
    //    UIInterfaceOrientation val = orientation;
    //    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    ////        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(unknow)];
    //        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(val)];
    //        [UIViewController attemptRotationToDeviceOrientation];
    //    }
    //    SEL selector = NSSelectorFromString(@"setOrientation:");
    //    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    //    [invocation setSelector:selector];
    ////    [invocation setTarget:[UIDevice currentDevice]];
    ////    [invocation setArgument:&unknow atIndex:2];
    //    [invocation invoke];
    //    [invocation setArgument:&val atIndex:2];
    //    [invocation invoke];
    VHLog(@"强制转屏结束");
}


- (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.numberOfLines = 0;
    hud.label.text = msg;
    hud.margin = 10.f;
    //hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:delay];
}


- (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    [self showMsgInWindow:msg afterDelay:delay offsetY:0];
}

- (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay offsetY:(CGFloat)offsetY {
    UIView *window = [UIApplication sharedApplication].delegate.window;
    if(!window)
        window = self.view;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    hud.label.numberOfLines = 0;
    hud.margin = 10.f;
    hud.offset = CGPointMake(0, offsetY);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:delay];
}

- (void) showRendererMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    hud.label.numberOfLines = 0;
    hud.margin = 30.f;
    //            hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:delay];
}

@end
