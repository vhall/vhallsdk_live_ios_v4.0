//
//  VHinteractiveViewController.h
//  UIModel
//
//  Created by vhall on 2018/7/30.
//  Copyright © 2018年 www.vhall.com. All rights reserved.
//

#import "VHBaseViewController.h"
@class VHinteractiveViewController;

@protocol VHinteractiveViewControllerDelegate <NSObject>
@optional;
//代理对象来关闭互动控制器  kickOut:是否被踢出
- (void)interactiveViewClose:(VHinteractiveViewController *_Nonnull)controller byKickOut:(BOOL)kickOut;
@end

@interface VHinteractiveViewController : VHBaseViewController

/** 代理 */
@property (nonatomic, weak) id<VHinteractiveViewControllerDelegate> _Nullable delegate;

//加入互动房间参数（id：房间id pass：密码/k值，等）
@property (nonatomic, strong) NSDictionary * _Nonnull joinRoomPrams;

/** 互动工具view */
@property (nonatomic, strong , readonly) UIView * _Nullable toolView;

//192x144 = 0
//240x160 = 1
//320x240 = 2
//480x360 = 3
//570x432 = 4
//640x480 = 5
@property(nonatomic, assign)int pushResolution;  //互动分辨率

@property(nonatomic, assign)BOOL     inavBeautifyFilterEnable;//互动美颜开关

//下麦退出
- (void)closeButtonClick:(UIButton *_Nullable)sender;
@end
