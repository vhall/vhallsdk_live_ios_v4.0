//
//  WatchRTMPViewController.h
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "VHBaseViewController.h"

@interface WatchLiveViewController : VHBaseViewController
@property(nonatomic,copy)NSString * roomId; //房间id
@property(nonatomic,copy)NSString * kValue; //观看密码
@property(nonatomic,assign)NSInteger bufferTimes; //观看的缓冲时间 默认 6秒 单位为秒 必须>0 值越小延时越小,卡顿增加

@property (nonatomic, assign) BOOL interactBeautifyEnable; //互动美颜开关
@property (nonatomic, assign) int interactResolution; //互动推流分辨
@end
