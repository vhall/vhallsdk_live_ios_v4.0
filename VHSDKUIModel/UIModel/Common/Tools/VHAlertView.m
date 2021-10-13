//
//  VHAlertView.m
//  VhallModuleUI_demo
//
//  Created by xiongchao on 2019/12/4.
//  Copyright © 2019 vhall. All rights reserved.
//

#import "VHAlertView.h"

@interface VHAlertView ()

@end

@implementation VHAlertView

+ (void)showAlertWithTitle:(NSString *)title content:(NSString *)content cancelText:(NSString *)cancelText cancelBlock:(void(^)(void))cancelBlock confirmText:(NSString *)confirmText confirmBlock:(void(^)(void))confirmBlock {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];

    __weak __typeof(UIAlertController *)weakAlertVC = alertVC;

    //取消
    if([cancelText isKindOfClass:[NSString class]] && cancelText.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelBlock ? cancelBlock() : nil;
            });
            [weakAlertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancelAction];
    }

    //确定
    UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            confirmBlock ? confirmBlock() : nil;
        });
        [weakAlertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:comfirmAction];


    [[UIModelTools getCurrentActivityViewController] presentViewController:alertVC animated:YES completion:nil];
}


@end
