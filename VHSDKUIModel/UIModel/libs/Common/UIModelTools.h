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

@end

NS_ASSUME_NONNULL_END
