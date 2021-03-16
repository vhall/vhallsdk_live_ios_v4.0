//
//  BaseViewController.h
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHBaseViewController : UIViewController

/** 是否正在强制旋转屏幕 */
@property (nonatomic, assign) BOOL forceRotating;

@property(nonatomic,assign)UIInterfaceOrientation interfaceOrientation;

//强制旋转屏幕方向
- (void)forceRotateUIInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay;
- (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay;
- (void)showMsgInWindow:(NSString*)msg afterDelay:(NSTimeInterval)delay offsetY:(CGFloat)offsetY;
-(void) showRendererMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay;

@end
