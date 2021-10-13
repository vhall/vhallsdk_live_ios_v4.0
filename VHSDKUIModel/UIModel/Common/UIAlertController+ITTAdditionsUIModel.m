//
//  UIAlertController+ITTAdditions.m
//
//  Created by lwl on 3/15/12.
//  Copyright (c) 2012 vhall. All rights reserved.
//

#import "UIAlertController+ITTAdditionsUIModel.h"

@implementation UIAlertController (ITTAdditionsUIModel)

+ (void)showAlertControllerTitle:(NSString *)title
                             msg:(NSString *)msg
                       leftTitle:(NSString *)leftTitle
                      rightTitle:(NSString *)rightTitle
                    leftCallBack:(void(^)(void))leftCallBack
                   rightCallBack:(void(^)(void))rightCallBack {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    
    
    UIAlertAction *leftAction = [UIAlertAction actionWithTitle:leftTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (leftCallBack) {
            leftCallBack();
        }
    }];
    
    UIAlertAction *rightAction = [UIAlertAction actionWithTitle:rightTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        if (rightCallBack) {
            rightCallBack();
        }
    }];
    
    [alertController addAction:leftAction];
    [alertController addAction:rightAction];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertControllerTitle:(NSString *)title
                             msg:(NSString *)msg
                       btnTitle:(NSString *)btnTitle
                    callBack:(void(^)(void))callBack {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *leftAction = [UIAlertAction actionWithTitle:btnTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (callBack) {
            callBack();
        }
    }];
    [alertController addAction:leftAction];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}


+ (void)showAlertControllerActionSheetWithTitle:(NSString *)title
                                      actionArr:(nonnull NSArray <NSString *>*)actionArr
                                       callBack:(void(^)(NSString *selectedActionStr))callBack {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    for (NSString *actionStr in actionArr) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            if (callBack) {
                callBack(actionStr);
            }
        }];
        [alertVC addAction:alertAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alertVC addAction:cancelAction];
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];
}

/// 关闭alertVC
+ (void)dissmissAlertVC {
    UIViewController *presentedAlertVC = [self getCurrentVC].presentedViewController;
    if (!presentedAlertVC) return;
    if ([presentedAlertVC isKindOfClass:[UIAlertController class]]) {
        [presentedAlertVC dismissViewControllerAnimated:NO completion:nil];
    }
}


/*
 获取当前屏幕显示的控制器
 */
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
//    UIViewController *rootViewController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return [self getVisibleViewControllerFrom:result];
}

+ (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *)vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *)vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}


@end
