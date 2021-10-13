//
//  UIModelTools.m
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "UIModelTools.h"
#import "MBProgressHUD.h"
#import <mach/mach.h>
#import <CommonCrypto/CommonDigest.h>


@implementation UIModelTools

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



+ (NSString *)safeString:(NSString *)string {
    if ([string isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",string];
    }
    if (!string || ![string isKindOfClass:[NSString class]] || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@"null"] || [string isEqualToString:@"<null>"]) {
        return @"";
    }
    return string;
}

+ (NSString *)timeFormat:(NSInteger)duration
{
    NSInteger minute = 0, hour = 0, secend = duration;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)minute, (long)secend];
    //    int secend = ceil(duration);
    //    return [NSString stringWithFormat:@"%02d:%02d:%02d",secend/3600,(secend%3600)/60,secend%60];
}

+ (float)cpu_usage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    //    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    //    uint32_t stat_thread = 0; // Mach threads
    
    //    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    //    if (thread_count > 0)
    //        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (UIColor *)hearderColorWithUserId:(NSString *)userId {
    NSArray *colors = @[MakeColorRGB(0x1E89E4),
                        MakeColorRGB(0xEF5353),
                        MakeColorRGB(0xFF9845),
                        MakeColorRGB(0x53EF64),
                        MakeColorRGB(0xFF45F1)];
    return colors[[userId intValue]%5];
}


/// 获取多行Label的高度
/// @param text 文字内容
/// @param width Label宽
/// @param font Label字体
+ (CGFloat)labelHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font {
    CGSize tempSize = CGSizeMake(width,CGFLOAT_MAX);
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font ,NSFontAttributeName,nil];
    
    CGSize size = [text boundingRectWithSize:tempSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return ceil(size.height);
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIViewController *)viewControllerWithView:(UIView *)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (void)baseAlertWithViewController:(UIViewController *)vc title:(NSString *)title message:(NSString *)message letfStr:(NSString *)leftStr rightStr:(NSString *)rightStr left:(void(^)(void))left right:(void (^)(void))right
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
     
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController * pop = [alertController popoverPresentationController];
        pop.sourceView = vc.view;//悬挂的视图
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;//箭头方向
        pop.sourceRect = vc.view.bounds;//悬挂的地方
    }

    //左侧颜色的
     if (leftStr.length != 0) {
         UIAlertAction * leftAction = [UIAlertAction actionWithTitle:leftStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             left();
         }];
         [alertController addAction:leftAction];
         [leftAction setValue:MakeColorRGB(0x8246AF) forKey:@"_titleTextColor"];
     }
     
     //右侧无颜色的
    if (rightStr.length != 0) {
        UIAlertAction * rightAction = [UIAlertAction actionWithTitle:rightStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            right();
        }];
        [alertController addAction:rightAction];
        [rightAction setValue:MakeColorRGB(0x444444) forKey:@"_titleTextColor"];
    }
     
    //标题
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:MakeColorRGB(0x444444) range:NSMakeRange(0, alertControllerStr.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:FONT_Medium(15) range:NSMakeRange(0, alertControllerStr.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
     
    //详情
    NSMutableAttributedString * alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:MakeColorRGB(0x444444) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:FONT_FZZZ(13) range:NSMakeRange(0, alertControllerMessageStr.length)];
     NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;//对齐方式
    [alertControllerMessageStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [message length])];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    [vc presentViewController:alertController animated:YES completion:nil];
}

//有值 返回yes
+ (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return NO;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if (!aStr.length) {
        return NO;
    }
    if (([aStr isEqualToString:@"<null>"])) {
        return NO;
    }
    if (([aStr isEqualToString:@"(null)"])) {
        return NO;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return NO;
    }
    return YES;
}
+ (BOOL)checkDictIsValided:(NSDictionary *)dict{
    
    if ([dict isKindOfClass:[NSNull class]] || dict.allValues.count == 0 || dict.allKeys.count == 0 ) {
        return NO;
    }else{
        return YES;
    }
}
+ (BOOL)checkArrayIsValided:(NSArray *)arr{
    
    if ([arr isKindOfClass:[NSNull class]] || arr.count == 0 || arr == nil) {
        return NO;
    }else{
        return YES;
    }
}


+ (void)solveUIWidgetFuzzy:(UIView *)view
{
    CGRect frame = view.frame;
    int x = floor(frame.origin.x);
    int y = floor(frame.origin.y);
    int w = floor(frame.size.width)+1;
    int h = floor(frame.size.height)+1;
    
    view.frame = CGRectMake(x, y, w, h);
}


//UITextField/UItextView输入计数 countLab：字数lab
+(void)caculateInputBox:(id)inputBox desplayCountLab:(UILabel *)countLab maxTextLength:(NSInteger)maxTextLength
{
    if([inputBox isKindOfClass:[UITextField class]])
    {
        UITextField *box = inputBox;
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; // 键盘输入模式
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [box markedTextRange];
            //获取高亮部分
            UITextPosition *position = [box positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (box.text.length > maxTextLength) {
                    box.text = [box.text substringToIndex:maxTextLength];
                }
                else
                {
                    
                }
                //显示字数
                countLab.text = [NSString stringWithFormat:@"%zd/%zd",box.text.length,maxTextLength];
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (box.text.length > maxTextLength) {
                box.text = [box.text substringToIndex:maxTextLength];
                countLab.text = [NSString stringWithFormat:@"%zd/%zd",maxTextLength,maxTextLength];
            }
            //显示字数
            countLab.text = [NSString stringWithFormat:@"%zd/%zd",box.text.length,maxTextLength];
        }

    }
    else if ([inputBox isKindOfClass:[UITextView class]])
    {
        UITextView *box = inputBox;
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; // 键盘输入模式
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [box markedTextRange];
            //获取高亮部分
            UITextPosition *position = [box positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (box.text.length > maxTextLength) {
                    box.text = [box.text substringToIndex:maxTextLength];
                }
                else
                {
                    
                }
                //显示字数
                countLab.text = [NSString stringWithFormat:@"%zd/%zd",box.text.length,maxTextLength];
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (box.text.length > maxTextLength) {
                box.text = [box.text substringToIndex:maxTextLength];
                countLab.text = [NSString stringWithFormat:@"%zd/%zd",maxTextLength,maxTextLength];
            }
            //显示字数
            countLab.text = [NSString stringWithFormat:@"%zd/%zd",box.text.length,maxTextLength];
        }

    }
}

//限制只能输入数字和英文
+ (BOOL)inputShouldLetterOrNum:(NSString *)string {
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:string];
}


//限制输入价格（小数点前5位，后2位）
+ (BOOL)priceFormat:(NSString *)price {
    if (price.length > 0) {
        NSString *stringRegex = @"(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,4}(([.]\\d{0,2})?)))?";
        NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
        if ([pricePredicate evaluateWithObject:price] == NO) {// 不满足该正则，就不让用户输入，执行return NO。
            return NO;
        }
    }
    return YES;
}

+ (NSString*)MD5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int) strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

///获取当前活动的控制器
+ (UIViewController *)getCurrentActivityViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    NSLog(@"window level: %.0f", window.windowLevel);
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    //从根控制器开始查找
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activityVC = nil;
    
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            activityVC = [(UITabBarController *)rootVC selectedViewController];
        } else if (rootVC.presentedViewController) {
            activityVC = rootVC.presentedViewController;
        }else {
            activityVC = rootVC;
            break;
        }
        
        rootVC = activityVC;
    }
    
    return activityVC;
}

+ (BOOL)hasEmoji:(NSString*)string {
    if(!string || [@"➋➌➍➎➏➐➑➒" containsString:string]) { //可以九宫格输入中文
        return NO;
    }
    
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
//                 NSLog(@"hs++++++++%04x",hs);
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f9ff)
                {
                    isEomji = YES;
                }
//                                 NSLog(@"uc++++++++%04x",uc);
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3|| ls ==0xfe0f || ls == 0xd83c) {
                isEomji = YES;
            }
//                         NSLog(@"ls++++++++%04x",ls);
        } else {
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
        }
    }];
    
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    
    return isEomji || isMatch;
}


//图片确保添加http/https前缀
+ (NSString *)httpPrefixImgUrlStr:(NSString *)imgUrlStr  {
    if (!imgUrlStr || [imgUrlStr isEqualToString:@""]) {
        return @"";
    }
    if([imgUrlStr hasPrefix:@"//"]) {
        imgUrlStr = [NSString stringWithFormat:@"%@%@",@"https:",imgUrlStr];
    }else if(![imgUrlStr hasPrefix:@"http"]){
        imgUrlStr = [NSString stringWithFormat:@"http://t-alistatic01.e.vhall.com/upload/%@",imgUrlStr];
    }
    //图片裁切
    if(![imgUrlStr containsString:@"?x-oss-process=image/resize"] && ![imgUrlStr.pathExtension isEqual:@"gif"]) {
        //图片尺寸
        NSString *cutString = @"?x-oss-process=image/resize,w_1000,h_1000";
        imgUrlStr = [NSString stringWithFormat:@"%@%@",imgUrlStr,cutString];
    }
    return imgUrlStr;
}

//年月日转换年月
+ (NSString *)formatTime:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:timeStr];
    if(date) {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *string = [formatter stringFromDate:date];
        return string;
    }else {
        return timeStr;
    }
}



//当前时间 yyyy-MM-dd HH:mm:ss
+ (NSString *)currentTimeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}


+ (NSString *) base64:(NSString *)str
{
    NSData* originData = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
