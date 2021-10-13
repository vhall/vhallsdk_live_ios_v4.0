//
//  UIAlertController+ITTAdditions.h
//
//  Created by lwl on 3/15/12.
//  Copyright (c) 2012 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ITTAdditionsUIModel)

+ (void)showAlertControllerTitle:(NSString *)title
                             msg:(NSString *)msg
                       leftTitle:(NSString *)leftTitle
                      rightTitle:(NSString *)rightTitle
                    leftCallBack:(void(^)(void))leftCallBack
                   rightCallBack:(void(^)(void))rightCallBack;



+ (void)showAlertControllerTitle:(NSString *)title
                             msg:(NSString *)msg
                        btnTitle:(NSString *)btnTitle
                        callBack:(void(^)(void))callBack;

// actionSheet
+ (void)showAlertControllerActionSheetWithTitle:(NSString *)title
                                      actionArr:(nonnull NSArray <NSString *>*)actionArr
                                       callBack:(void(^)(NSString *selectedActionStr))callBack;




+ (void)dissmissAlertVC;

@end
