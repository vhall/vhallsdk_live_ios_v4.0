//
//  UIModelTools.m
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "UIModelTools.h"
#import "MBProgressHUD.h"

@implementation UIModelTools
+ (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    [self showMsgInWindow:msg afterDelay:delay offsetY:0];
}


+ (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay offsetY:(CGFloat)offsetY {
    UIView *window = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    hud.margin = 10.f;
    hud.offset = CGPointMake(0, offsetY);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:delay];
}
@end
