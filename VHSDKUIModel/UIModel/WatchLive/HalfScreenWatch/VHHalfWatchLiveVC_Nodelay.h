//
//  WatchRTMPViewController.h
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//
//半屏看直播
#import "VHBaseViewController.h"

@interface VHHalfWatchLiveVC_Nodelay : VHBaseViewController
@property(nonatomic,copy)NSString * roomId; //房间id
@property(nonatomic,copy)NSString * kValue; //观看密码

@property (nonatomic, assign) BOOL interactBeautifyEnable; //互动美颜开关

@end
