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
    
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:confirmText style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        confirmBlock ? confirmBlock() : nil;
    }];
    action1.buttonAttributes = @{NSForegroundColorAttributeName:MakeColorRGB(0xFC5659),NSFontAttributeName:FONT_FZZZ(16)};
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:cancelText style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        cancelBlock ? cancelBlock() : nil;
    }];
    action2.buttonAttributes = @{NSForegroundColorAttributeName:MakeColorRGB(0x222222),NSFontAttributeName:FONT_FZZZ(16)};
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:title message:content preferredStyle:QMUIAlertControllerStyleAlert];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    alertController.alertTitleAttributes = @{NSForegroundColorAttributeName:MakeColorRGB(0x222222),NSFontAttributeName:FONT_Medium(16),NSParagraphStyleAttributeName:paragraphStyle};
    alertController.alertMessageAttributes = @{NSForegroundColorAttributeName:MakeColorRGB(0x222222),NSFontAttributeName:FONT_FZZZ(14)};
    alertController.alertButtonHeight = 45;
    alertController.alertHeaderInsets = UIEdgeInsetsMake(25, 20, 25, 20);
    alertController.alertTitleMessageSpacing = 15;
    [alertController addAction:action1];
    if([cancelText isKindOfClass:[NSString class]] && cancelText.length > 0) {
        [alertController addAction:action2];
    }
    [alertController showWithAnimated:YES];
}

@end
