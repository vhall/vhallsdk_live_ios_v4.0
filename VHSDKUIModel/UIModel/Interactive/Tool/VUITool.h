//
//  VUITool.h
//  VhallModuleUI_demo
//
//  Created by vhall on 2019/11/19.
//  Copyright © 2019 vhall. All rights reserved.
//
//工具类
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface VUITool : NSObject

+ (NSString *)safeString:(NSString *)string;

+ (NSString *)timeFormat:(NSInteger)duration;

+ (float)cpu_usage;

//头像颜色生成规则
+ (UIColor *)hearderColorWithUserId:(NSString *)userId;

/// 获取多行Label的高度
/// @param text 文字内容
/// @param width Label宽
/// @param font Label字体
+ (CGFloat)labelHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  获取当前所在控制器
 */
+ (UIViewController *)viewControllerWithView:(UIView *)view;
/**
 * 提示窗样式
 */
+ (void)baseAlertWithViewController:(UIViewController *)vc title:(NSString *)title message:(NSString *)message letfStr:(NSString *)leftStr rightStr:(NSString *)rightStr left:(void(^)(void))left right:(void (^)(void))right;

/**
 * 判断字符串为空
 */
+ (BOOL)isBlankString:(NSString *)aStr;
/**
 * 判断字典为空
 */
+ (BOOL)checkDictIsValided:(NSDictionary *)dict;
/**
 * 判断数组为空
 */
+ (BOOL)checkArrayIsValided:(NSArray *)arr;
/**
 *  知客弹窗
 */
+ (void)zkAlertController:(UIViewController *)vc title:(NSString *)title message:(NSString *)message letfStr:(NSString *)leftStr rightStr:(NSString *)rightStr left:(void(^)(void))left right:(void (^)(void))right;

//对控件frame坐标取整（解决文字模糊问题）
+ (void)solveUIWidgetFuzzy:(UIView *)view;


//UITextField/UItextView输入计数
+(void)caculateInputBox:(id)inputBox desplayCountLab:(UILabel *)countLab maxTextLength:(NSInteger)maxTextLength;


//限制只能输入数字和英文
+ (BOOL)inputShouldLetterOrNum:(NSString *)string;

//限制输入价格（小数点前5位，后2位）
+ (BOOL)priceFormat:(NSString *)price;

//MD5
+ (NSString*)MD5:(NSString *)str;

///获取当前活动的控制器
+ (UIViewController *)getCurrentActivityViewController;

//是否包含emoji表情
+ (BOOL)hasEmoji:(NSString*)string;

//图片确保添加http/https前缀
+ (NSString *)httpPrefixImgUrlStr:(NSString *)imgUrlStr;

//年月日转换年月
+ (NSString *)formatTime:(NSString *)timeStr;

//当前时间 yyyy-MM-dd HH:mm:ss
+ (NSString *)currentTimeStr;


+ (NSString *)base64:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
