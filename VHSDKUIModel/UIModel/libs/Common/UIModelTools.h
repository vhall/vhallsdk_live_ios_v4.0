//
//  UIModelTools.h
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIModelTools : NSObject

+ (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay;


+ (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay offsetY:(CGFloat)offsetY;

//判断字符串是否为空
+ (BOOL)isEmptyStr:(NSString *)str;

+ (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay;

// 字典转json字符串方法
+ (NSString *)jsonStringWithObject:(id)dict;


//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
