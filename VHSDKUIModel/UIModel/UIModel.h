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
#import "VHHalfWatchLiveVC_Normal.h"
#import "WatchPlayBackViewController.h"
#import "PubLishLiveVC_Normal.h"
#import "UIModelTools.h"
#import "ProgressHud.h"

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
#define VUI_Log(format, ...) printf("类: <%s:(行号:%d)> 方法: %s\n%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

#define VH_SH                   ((VHScreenWidth<VHScreenHeight)?VHScreenHeight:VHScreenWidth)
#define VH_SW                   ((VHScreenWidth<VHScreenHeight)?VHScreenWidth:VHScreenHeight)

#define VHScreenHeight          ([UIScreen mainScreen].bounds.size.height)
#define VHScreenWidth           ([UIScreen mainScreen].bounds.size.width)
#define VHScreenScale           ([[UIScreen mainScreen] scale])

#define VH_Device_OS_ver        [[UIDevice currentDevice] systemVersion]
#define IOSVersion              [[UIDevice currentDevice].systemVersion floatValue]
#define kViewFramePath          @"frame"

#define iPhoneX \
({BOOL isPhoneX = NO;\
if ([[[UIDevice currentDevice] systemVersion] floatValue]>=11.0) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define VH_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define VH_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
////iPhone5/5c/5s/se
#define VH_IS_IPHONE_5        (VH_IS_IPHONE && (MIN(VHScreenWidth, VHScreenHeight) == 320.f) && (MAX(VHScreenWidth, VHScreenHeight)) == 568.f ? YES : NO)
//是否iPhoneX系列屏幕（刘海屏）
#define VH_KiPhoneXSeries (iPhoneX)
// iPhoneX/11系列 底部操作条高度
#define VH_BottomSafeMargin    (VH_KiPhoneXSeries ? 34.f : 0.f)

//颜色
#define MakeColor(r,g,b,a)      ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])
#define MakeColorRGB(hex)       ([UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:1.0])
#define MakeColorRGBA(hex,a)    ([UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:a])

/// 字体方正正中
#define FONT_FZZZ(fontSize) [UIFont fontWithName:@"PingFang-SC-Regular" size:(fontSize)]

/// 字体方正加粗
#define FONT_Medium(fontSize) [UIFont fontWithName:@"PingFang-SC-Medium" size:(fontSize)]

//最大昵称数
#define VH_MaxNickNameCount 6

#define WS(self) __weak __typeof (self)weakSelf = self;
//#define strongify(self) __strong __typeof (self)strongSelf = self;

#define VH_ShowToast(string)  [ProgressHud showToast:string]
//是否为空字符串
#define VH_EmptyStr(string)  ([UIModelTools safeString:string].length <= 0)
//emoji表情字典
#define VHEmojiDic [NSDictionary dictionaryWithContentsOfFile:[UIModelBundle pathForResource:@"faceExpression" ofType:@"plist"]]




#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


#endif /* UIModel_PrefixHeader_h */
