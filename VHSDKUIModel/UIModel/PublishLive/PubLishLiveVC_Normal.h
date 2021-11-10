//
//  DemoViewController.h
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//
//发常规直播
#import "VHBaseViewController.h"

@interface PubLishLiveVC_Normal : VHBaseViewController
@property(nonatomic,copy)   NSString        *roomId; //房间id
@property(nonatomic,copy)   NSString        *token;
@property(nonatomic,copy)   NSString        *nick_name; //昵称
@property(nonatomic,assign) NSInteger       videoBitRate; //视频码率
@property(nonatomic,assign) NSInteger       audioBitRate;  //音频码率
@property(nonatomic,assign) NSInteger       videoCaptureFPS;   //推流帧率
@property(nonatomic,assign) BOOL            isOpenNoiseSuppresion; //噪声消除
@property(nonatomic,assign) BOOL            beautifyFilterEnable; //美颜开关
@property(nonatomic,assign) NSInteger            videoResolution; //推流分辨率 0：352*288 1：640*480 2：960*540 3：1280*720
@end
