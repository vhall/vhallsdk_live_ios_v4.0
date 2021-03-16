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


//判断字符串是否为空
+ (BOOL)isEmptyStr:(NSString *)str {
    if ([str isKindOfClass:[NSNumber class]]) {
        str = [NSString stringWithFormat:@"%@",str];
    }
    if (!str || [str isKindOfClass:[NSNull class]] || ![str isKindOfClass:[NSString class]] || [str isEqualToString:@"null"] || [str isEqualToString:@"<null>"]){
        str = @"";
    }
    if(str.length > 0) {
        return NO;
    }else {
        return YES;
    }
}

+ (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.numberOfLines = 0;
    hud.label.text = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:delay];
}

// 字典转json字符串方法
+ (NSString *)jsonStringWithObject:(id)dict
{
    if(!dict) return @"";
    if([dict isKindOfClass:[NSString class]])return dict;
    
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (error) {
        VHLog(@"%@",error);
        return @"";
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return (jsonString.length>0)?jsonString:@"";
}

@end
