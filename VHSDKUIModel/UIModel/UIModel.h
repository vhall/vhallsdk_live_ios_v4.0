//
//  UIModel_PrefixHeader.h
//  VHSDKDemo
//
//  Created by vhall on 2020/3/22.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#ifndef UIModel_PrefixHeader_h
#define UIModel_PrefixHeader_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIView+ITTAdditionsUIModel.h"

#import "WatchLiveViewController.h"
#import "WatchPlayBackViewController.h"
#import "LaunchLiveViewController.h"
#import "VHinteractiveViewController.h"
#import "UIModelTools.h"


#ifdef  UIModel_Lib //独立打 UIModel 静态库 需要在工程设置 Preprocessor Macros选项中添加 UIModel_Lib=1
    #define UIModelBundlePath       [[NSBundle mainBundle] pathForResource:@"UIModel" ofType:@"bundle"]
    #define UIModelBundle           [NSBundle bundleWithPath:UIModelBundlePath]
    #define BundleUIImage(a)        [UIImage imageNamed:[NSString stringWithFormat:@"UIModel.bundle/%@",a]]
    #define BundleName              @"UIModel.bundle"
    #define CustomEmojiPlistName    @"UIModel.bundle/faceExpression.plist"
#else
    #define UIModelBundlePath       [[NSBundle mainBundle] resourcePath]
    #define UIModelBundle           [NSBundle bundleWithPath:UIModelBundlePath]
    #define BundleUIImage(a)        [UIImage imageNamed:(a)]
    #define BundleName              @""
    #define CustomEmojiPlistName    @"faceExpression.plist"
#endif

#define LoadVCNibName       [super initWithNibName:NSStringFromClass([self class]) bundle:UIModelBundle]//ViewController 加载
#define LoadViewNibName     [[UIModelBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject]//View 加载
#define CustomEmojiRegex    @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"



#define iPhoneX \
({BOOL isPhoneX = NO;\
if ([[[UIDevice currentDevice] systemVersion] floatValue]>=11.0) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

// 刘海屏系列 底部操作条高度
#define VH_KBottomSafeMargin    (iPhoneX ? 34.f : 0.f)
// 状态栏高度
#define VH_KStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//导航栏高度（不含状态栏）
#define VH_KSystemNavBarHeight 44.0
//TabBar标签栏高度 (不含底部安全区域)
#define VH_KSystemTabBarHeight 49.0
//导航栏 + 状态栏高度
#define VH_KNavBarHeight (VH_KSystemNavBarHeight + VH_KStatusBarHeight)
//TabBar标签栏高度 + 底部操作条高度
#define VH_KTabBarHeight (VH_KSystemTabBarHeight + VH_KBottomSafeMargin)


//是否为横屏显示
#define VH_KScreenIsLandscape UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
#define VHLog(...)              NSLog(__VA_ARGS__)
#define VH_SH                   ((VHScreenWidth<VHScreenHeight)?VHScreenHeight:VHScreenWidth)
#define VH_SW                   ((VHScreenWidth<VHScreenHeight)?VHScreenWidth:VHScreenHeight)
#define VHScreenHeight          ([UIScreen mainScreen].bounds.size.height)
#define VHScreenWidth           ([UIScreen mainScreen].bounds.size.width)
#define VH_Device_OS_ver        [[UIDevice currentDevice] systemVersion]
#define IOSVersion              [[UIDevice currentDevice].systemVersion floatValue]
#define kViewFramePath          @"frame"

//颜色
#define MakeColor(r,g,b,a)      ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])
#define MakeColorRGB(hex)       ([UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:1.0])
#define MakeColorRGBA(hex,a)    ([UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:a])
#define MessageTool_SendBtnColor MakeColor(153,153,153,1.0f)

#endif /* UIModel_PrefixHeader_h */
