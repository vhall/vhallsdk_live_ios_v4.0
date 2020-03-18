//
//  VHMessage.h
//  VHBasePlatform
//
//  Created by vhall on 2017/11/30.
//  Copyright © 2017年 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSG_Type                    @"type"                //消息通用类型区分
#define MSG_Nick_name               @"nick_name"           //消息中昵称
#define MSG_Avatar                  @"avatar"              //消息中头像


#define MSG_Service_Type_IM         @"service_im"           //聊天服务
#define MSG_Service_Type_Document   @"service_document"     //文档服务
#define MSG_Service_Type_Room       @"service_room"         //房间服务
#define MSG_Service_Type_Online     @"service_online"       //在线服务
#define MSG_Service_Type_Customt    @"service_custom"       //自定义消息

//service_room
#define MSG_Room_Live_Start         @"live_start"           //开始推流消息体
#define MSG_Room_Live_Over          @"live_over"           //结束推流消息体
#define MSG_Room_Live_Converted     @"live_converted"       //流清晰度转换完成通知消息体

//service_online
#define MSG_Online_Join             @"Join"                 //用户进入频道消息
#define MSG_Online_Leave            @"Leave"                //用户离开频道消息

//service_im
#define MSG_IM_Type_Text            @"text"                //文本消息
#define MSG_IM_Type_Image           @"image"               //图片消息
#define MSG_IM_Type_Link            @"link"                //URL链接
#define MSG_IM_Type_Video           @"video"               //视频消息
#define MSG_IM_Type_Voice           @"voice"               //语音消息
#define MSG_IM_Type_Disable         @"disable"             //禁言某个用户
#define MSG_IM_Type_Disable_All     @"disable_all"         //全员禁言
#define MSG_IM_Type_Permit          @"permit"              //取消禁言某个用户
#define MSG_IM_Type_Permit_All      @"permit_all"          //取消全员禁言
#define MSG_IM_Text_Content         @"text_content"         //文本内容          文本消息 MSG_IM_Type_Text
#define MSG_IM_Image_Url            @"image_url"            //图片URL地址       图片消息 MSG_IM_Type_Image
#define MSG_IM_Image_Urls           @"image_urls"           //多个图片URL地址    批量发送图片消息 MSG_IM_Type_Image
#define MSG_IM_Link_Url             @"link_url"             //链接URL地址       URL链接 MSG_IM_Type_Link
#define MSG_IM_Video_Url            @"video_url"            //视频文件地址       视频消息 MSG_IM_Type_Video
#define MSG_IM_Voice_Url            @"voice_url"            //语音音频文件地址    语音消息 MSG_IM_Type_Voice
#define MSG_IM_Target_Id            @"target_id"            //被禁言或者被取消禁言的目标用户ID    禁言某个用户、取消禁言某个用户



@interface VHMessage : NSObject

- (instancetype)initWithDic:(NSDictionary*)dic;

@property (nonatomic,copy)  NSString *msg_id;               //消息ID
@property (nonatomic,copy)  NSString *channel;              //频道ID
@property (nonatomic,copy)  NSString *event;                //收消息事件__old
@property (nonatomic,copy)  NSString *date_time;            //消息发送的日期时间，例：2017-11-29 11:22:33
@property (nonatomic,copy)  NSString *third_party_user_id;  //第三方用户唯一标识__old
@property (nonatomic,assign)NSInteger connection_online_num;//频道在线连接数__old
@property (nonatomic,assign)NSInteger user_online_num;      //频道在线人数__old
@property (nonatomic,copy)  NSString *client;               //消息发送平台
@property (nonatomic,strong)id        data;                 //消息体
@property (nonatomic,strong)NSString *dataJson;             //消息体原始dataJson
@property (nonatomic,copy)  NSString *avatar;               //第三方用户头像地址，例：https://qlogo1.store.qq.com/qzone/237739452/237739452/100
@property (nonatomic,copy)  NSString *nick_name;            //第三方用户昵

//新消息新增结构
@property (nonatomic,copy)  NSString *service_type;         //收消息事件__new    对应老的 event
@property (nonatomic,copy)  NSString *sender_id;            //消息发送者ID__new  对应老的 third_party_user_id
@property (nonatomic,strong)id        context;              //自定义消息体__new
@property (nonatomic,assign)NSInteger pv;                   //频道在线连接数__new 对应老的 connection_online_num
@property (nonatomic,assign)NSInteger uv;                   //频道在线用户数__new 对应老的 user_online_num
@property (nonatomic,assign)NSInteger bu;                   //频道业务单元__new
@end
