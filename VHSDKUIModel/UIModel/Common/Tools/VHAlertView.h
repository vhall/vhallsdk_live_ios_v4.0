//
//  VHAlertView.h
//  VhallModuleUI_demo
//
//  Created by xiongchao on 2019/12/4.
//  Copyright © 2019 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHAlertView : UIView

/// 自定义标题、内容、取消、确定按钮
/// @param title 标题
/// @param content 内容
/// @param cancelText 取消文字
/// @param cancelBlock 取消回调
/// @param confirmText 确认文字
/// @param confirmBlock 确认回调
+ (void)showAlertWithTitle:(NSString *)title content:(NSString *)content cancelText:(NSString *)cancelText cancelBlock:(void(^)(void))cancelBlock confirmText:(NSString *)confirmText confirmBlock:(void(^)(void))confirmBlock;
@end

