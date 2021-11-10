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

- (instancetype)init {
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
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)dealloc {
    
}

-(BOOL)shouldAutorotate {
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        return UIInterfaceOrientationMaskLandscapeLeft;
    }else {
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


@end
