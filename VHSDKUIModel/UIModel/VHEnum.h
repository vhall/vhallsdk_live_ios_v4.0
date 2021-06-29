
//
//  VHEnum.h
//  VhallLive
//
//  Created by xiongchao on 2020/6/9.
//  Copyright © 2020 vhall. All rights reserved.
//
//枚举类

#ifndef VHEnum_h
#define VHEnum_h

//直播状态
typedef enum : NSUInteger {
    VHLiveState_Prepare = 0, //准备开播，显示开始直播按钮
    VHLiveState_Stop,        //已停止推流
    VHLiveState_Success,     //点击开始直播按钮后，或直播成功，view隐藏
    VHLiveState_Forbid,      //直播被封禁
    VHLiveState_NetError     //网络错误
} VHLiveState;


//直播观看条件
typedef enum : NSUInteger {
    VHLiveWatchType_None = 0,        //免费
    VHLiveWatchType_Password,        //密码
    VHLiveWatchType_WhiteList,       //白名单
    VHLiveWatchType_Money,           //付费
    VHLiveWatchType_Fcode,           //邀请码
    VHLiveWatchType_ReportForm,      //报名表单
    VHLiveWatchType_MoneyFcode,      //付费/邀请码
} VHLiveWatchType;

//直播活动状态
typedef enum : NSUInteger {
    VHWebinarState_Living = 1,   //直播中
    VHWebinarState_Ready = 2,        //预约中
    VHWebinarState_Vod = 3,          //点播
    VHWebinarState_Record = 4,         //回放
    VHWebinarState_Over = 5,         //结束
} VHLiveWebinarState;

//角色  1主持人 2观众 3助理 4嘉宾
typedef enum : NSUInteger {
    VHLiveRole_Host = 1,
    VHLiveRole_Audience = 2,
    VHLiveRole_Assistant = 3,
    VHLiveRole_Guest = 4,
} VHLiveRole;

//直播类型
typedef enum : NSUInteger {
    VHLiveType_Audio = 2, //音频直播
    VHLiveType_Video, // 视频直播
    VHLiveType_Interact, //互动直播
} VHLiveType;

//文档类型
typedef enum : NSUInteger {
    VHLiveDocImg = 0, //图片
    VHLiveDocPPT,     //PPT
    VHLiveDocPDF,     //PDF
    VHLiveDocWord,    //Word
    VHLiveDocExcel,   //Excel
} VHLiveDocType;


//登录方式
typedef enum : NSUInteger {
    VHLiveLoginAccount = 0, //账号密码登录
    VHLiveLoginAuthCode, //手机号验证码登录
} VHLiveLoginType;

#endif /* VHEnum_h */
