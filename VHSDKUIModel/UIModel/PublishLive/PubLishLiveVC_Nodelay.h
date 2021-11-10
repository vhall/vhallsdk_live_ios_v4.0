//
//  DemoViewController.h
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//
//发无延迟直播
#import "VHBaseViewController.h"
#import <VHInteractive/VHRenderView.h>

@interface PubLishLiveVC_Nodelay : VHBaseViewController
@property(nonatomic,copy)   NSString        *roomId; //房间id
@property(nonatomic,copy)   NSString        *nick_name; //昵称
@property(nonatomic,assign) BOOL            beautifyFilterEnable; //美颜开关
@property(nonatomic,assign) VHInteractiveStreamType       streamType;  //推流类型
@property(nonatomic,assign) VHRenderViewScalingMode       scaleMode;  //画面填充模式
@end
