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


//旁路混流布局模板 (主持人发起互动直播，所生成的旁路直播混流布局)
typedef NS_ENUM(NSInteger, VHBroadcastLayout) {
    VHBroadcastLayout_PATTERN_GRID_1     = 0,     //均分模式，最多1个画面，一人铺满
    VHBroadcastLayout_PATTERN_GRID_2_H   = 1,     //均分模式，最多2个画面，左右两格
    VHBroadcastLayout_PATTERN_GRID_3_E   = 2,     //均分模式，最多3个画面，正品字
    VHBroadcastLayout_PATTERN_GRID_3_D   = 3,     //均分模式，最多3个画面，倒品字
    VHBroadcastLayout_PATTERN_GRID_4_M   = 4,     //均分模式，最多4个画面，2行x2列
    VHBroadcastLayout_PATTERN_GRID_5_D   = 5,     //均分模式，最多5个画面，2行，上2下3
    VHBroadcastLayout_PATTERN_GRID_6_E   = 6,     //均分模式，最多6个画面，2行x3列
    VHBroadcastLayout_PATTERN_GRID_9_E   = 7,     //均分模式，最多9个画面，3行x3列
    VHBroadcastLayout_PATTERN_FLOAT_2_1DR    = 8,     //主次悬浮，最多2个画面，主画面铺满，小画面悬浮右下角 (小窗宽=画布宽度/5，比例为4:3)
    VHBroadcastLayout_PATTERN_FLOAT_2_1DL    = 9,     //主次悬浮，最多2个画面，主画面铺满，小画面悬浮左下角 (小窗宽=画布宽度/5，比例为4:3)
    VHBroadcastLayout_PATTERN_FLOAT_3_2DL    = 10,    //主次悬浮，最多3个画面，主画面铺满，2小画面悬浮右上角 (小窗宽=画布宽度/6，比例为4:3)
    VHBroadcastLayout_PATTERN_FLOAT_6_5D     = 11,    //主次悬浮，最多6个画面，主画面铺满，小画面一行5个悬浮于下面 (小窗宽=画布宽度/5，比例为4:3)
    VHBroadcastLayout_PATTERN_FLOAT_6_5T     = 12,    //主次悬浮，最多6个画面，主画面铺满，小画面一行5个悬浮于上面 (小窗宽=画布宽度/5，比例为4:3)
    VHBroadcastLayout_PATTERN_TILED_5_1T4D   = 13,    //主次平铺，最多5个画面，一行4个小画面位于底部
    VHBroadcastLayout_PATTERN_TILED_5_1D4T   = 14,    //主次平铺，最多5个画面，一行4个小画面位于顶部
    VHBroadcastLayout_PATTERN_TILED_5_1L4R   = 15,    //主次平铺，最多5个画面，一列4个小画面位于右边
    VHBroadcastLayout_PATTERN_TILED_5_1R4L   = 16,    //主次平铺，最多5个画面，一列4个小画面位于左边
    VHBroadcastLayout_PATTERN_TILED_6_1T5D   = 17,    //主次平铺，最多6个画面，一行5个小画面位于底部
    VHBroadcastLayout_PATTERN_TILED_6_1D5T   = 18,    //主次平铺，最多6个画面，一行5个小画面位于顶部
    VHBroadcastLayout_PATTERN_TILED_9_1L8R   = 19,    //主次平铺，最多9个画面，左边为主画面，右边为（2列x4行=8个小画面）
    VHBroadcastLayout_PATTERN_TILED_9_1R8L   = 20,    //主次平铺，最多9个画面，右边为主画面，左边为（2列x4行=8个小画面）
    VHBroadcastLayout_PATTERN_TILED_13_1L12R = 21,    //主次平铺，最多13个画面，左边为主画面，右边为（3列x4行=12个小画面）
    VHBroadcastLayout_PATTERN_TILED_17_1TL16GRID     = 22,    //主次平铺，最多17个画面，主画面在左上角，其余16个均铺于其他剩余区域
    VHBroadcastLayout_PATTERN_TILED_9_1D8T           = 23,    //主次平铺，最多9个画面，主画面在下，（2行x4列=8个小画面）在上
    VHBroadcastLayout_PATTERN_TILED_13_1TL12GRID     = 24,    //主次平铺，最多13个画面，主画面在左上角，其余12个均铺于其他剩余区域
    VHBroadcastLayout_PATTERN_TILED_17_1TL16GRID_E   = 25,    //主次平铺，最多17个画面，主画面在左上角，其余16个均铺于其他剩余区域
    VHBroadcastLayout_PATTERN_CUSTOM                 = 27,    //自定义，当使用坐标布局接口时，请使用此
    VHBroadcastLayout_EX_PATTERN_GRID_12_E           = 28,    //均分模式，最多12个画面，3行x4列
    VHBroadcastLayout_EX_PATTERN_GRID_16_E           = 29,    //均分模式，最多16个画面，4行x4列
    VHBroadcastLayout_EX_PATTERN_FLOAT_2_1TR         = 30,    //主次悬浮，最多2个画面，主画面铺满，小屏悬浮右上角 (小窗宽=画布宽度/5，比例为4:3)支持竖版布局
    VHBroadcastLayout_EX_PATTERN_FLOAT_2_1TL         = 31,    //主次悬浮，最多2个画面，主画面铺满，小屏悬浮左上角 (小窗宽=画布宽度/5，比例为4:3)支持竖版布局
    
    VHBroadcastLayout_ADAPTIVE_GRID_MODE        = 101,    //均分模式，自动布局
    VHBroadcastLayout_ADAPTIVE_TILED_MODE       = 102,    //主次平铺模式，自动布局
    VHBroadcastLayout_ADAPTIVE_FLOAT_MODE       = 103,    //主次悬浮模式，自动布局
}; //注：主次悬浮，小画面会覆盖在大画面上，可能遮挡一部分主画面



//旁路混流视频质量参数 (主持人发起互动直播，所生成的旁路直播混流视频质量参数)
typedef NS_ENUM(NSUInteger, VHBroadcastProfileMode) {
    VHBroadcastProfileMode_480P_0 = 0,  // 宽高比：4:3 分辨率：640x480 帧率：25  码率：700
    VHBroadcastProfileMode_480P_1 = 1,  // 宽高比：16:9 分辨率：848x480 帧率：25  码率：750
    VHBroadcastProfileMode_540P_0 = 2,  // 宽高比：4:3 分辨率：720x540 帧率：25  码率：950
    VHBroadcastProfileMode_540P_1 = 3,  // 宽高比：16:9 分辨率：960x540 帧率：25  码率：1150
    VHBroadcastProfileMode_720P_0 = 4,  // 宽高比：4:3 分辨率：960x720 帧率：25  码率：1400
    VHBroadcastProfileMode_720P_1 = 5,  // 宽高比：16:9 分辨率：1280x720 帧率：25  码率：1600
    VHBroadcastProfileMode_960P_0 = 6,  // 宽高比：4:3 分辨率：1280x960 帧率：25  码率：1600
    VHBroadcastProfileMode_960P_1 = 7,  // 宽高比：16:9 分辨率：1712x960 帧率：25  码率：1900
    VHBroadcastProfileMode_1080P_0 = 8,  // 宽高比：4:3 分辨率：1440x1080 帧率：25  码率：1800
    VHBroadcastProfileMode_1080P_1 = 9,  // 宽高比：16:9 分辨率：1920x1080 帧率：25  码率：2200

    /*以下新增竖版旁路 （注意当使用竖版分辨率时，旁路混流布局模板仅支持以下几种：
     VHBroadcastLayout_PATTERN_FLOAT_2_1DR 8
     VHBroadcastLayout_PATTERN_FLOAT_2_1DL 9
     VHBroadcastLayout_EX_PATTERN_FLOAT_2_1TR 30
     VHBroadcastLayout_EX_PATTERN_FLOAT_2_1TL 31
     ）*/
    VHBroadcastProfileMode_480P_1_VERTICAL = 10,  // 宽高比：9:16 分辨率：480x848 帧率：25  码率：750
    VHBroadcastProfileMode_540P_1_VERTICAL = 11,  // 宽高比：9:16 分辨率：540x960 帧率：25  码率：1150
    VHBroadcastProfileMode_720P_1_VERTICAL = 12,  // 宽高比：9:16 分辨率：720x1280 帧率：25  码率：1600
    VHBroadcastProfileMode_1080P_1_VERTICAL = 13,  // 宽高比：9:16 分辨率：1080x1920 帧率：25  码率：2200
};



#endif /* VHRoomEnum_h */
