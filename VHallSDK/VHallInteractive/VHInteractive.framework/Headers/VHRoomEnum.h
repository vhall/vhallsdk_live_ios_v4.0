//
//  VHRoomEnum.h
//  VHallInteractive
//
//  Created by xiongchao on 2021/4/19.
//  Copyright © 2021 vhall. All rights reserved.
//

#ifndef VHRoomEnum_h
#define VHRoomEnum_h

//互动房间状态
typedef NS_ENUM(NSInteger, VHRoomStatus) {
    VHRoomStatusReady, //准备中
    VHRoomStatusConnected, //连接成功
    VHRoomStatusDisconnected, //断开连接
    VHRoomStatusError //发送错误
};

//房间错误状态
typedef NS_ENUM(NSInteger, VHRoomErrorStatus) {
    VHRoomErrorUnknown,
    VHRoomErrorClient,// A generic error that comes from an VHClient
    VHRoomErrorClientFailedSDP,
    VHRoomErrorSignaling// A generic error that comes from VHSignalingChannel
};

//互动房间消息类型
typedef NS_ENUM(NSInteger, VHRoomMessageType) {
    VHRoomMessageType_vrtc_connect_open = 0,         //开启举手 （开启其他人申请上麦入口）
    VHRoomMessageType_vrtc_connect_close = 1,        //关闭举手 （关闭其他人申请上麦入口）
    VHRoomMessageType_vrtc_connect_apply = 2,        //某个用户申请上麦
    VHRoomMessageType_vrtc_connect_apply_cancel = 3, //某个用户取消上麦申请
    VHRoomMessageType_vrtc_connect_invite = 4,       //某个用户被主持人邀请上麦
    VHRoomMessageType_vrtc_connect_agree = 5,        //某个用户发起的上麦申请被主持人同意
    VHRoomMessageType_vrtc_connect_refused = 6,      //某个用户发起的上麦申请被主持人拒绝
    VHRoomMessageType_vrtc_mute = 7,                 //某个用户的麦克风静音
    VHRoomMessageType_vrtc_mute_all = 8,             //全体用户静音
    VHRoomMessageType_vrtc_mute_cancel = 9,          //某个用户的麦克风取消静音
    VHRoomMessageType_vrtc_mute_all_cancel = 10,     //取消全体用户静音
    VHRoomMessageType_vrtc_frames_forbid = 11,       //某个用户的摄像头关闭
    VHRoomMessageType_vrtc_frames_display = 12,      //某个用户的摄像头开启
    VHRoomMessageType_vrtc_big_screen_set = 13,      //某个用户的互动流画面被设置为旁路直播大画面
    VHRoomMessageType_vrtc_speaker_switch = 14,      //某个用户被设置为主讲人
    VHRoomMessageType_room_kickout = 15,             //某个用户被踢出
    VHRoomMessageType_live_start = 16,               //开始直播
    VHRoomMessageType_live_over = 17,                //结束直播
    VHRoomMessageType_room_announcement = 18,        //发布公告
    VHRoomMessageType_vrtc_disconnect_success = 19,  //某个用户下麦
    VHRoomMessageType_vrtc_connect_success = 20,     //某个用户上麦
    VHRoomMessageType_vrtc_connect_invite_refused = 21,    //某个用户拒绝来自主持人的上麦邀请
    VHRoomMessageType_room_kickout_cancel = 22,      //某个用户被取消踢出
    VHRoomMessageType_room_banChat = 23,               //某个用户被禁言
    VHRoomMessageType_room_banChat_cancel = 24,        //某个用户被取消禁言
    VHRoomMessageType_room_allBanChat = 25,            //全体禁言
    VHRoomMessageType_room_allBanChat_cancel = 26,     //取消全体禁言
};



#endif /* VHRoomEnum_h */
