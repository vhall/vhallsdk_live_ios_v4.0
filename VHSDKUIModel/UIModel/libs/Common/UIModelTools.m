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


+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}
@end
