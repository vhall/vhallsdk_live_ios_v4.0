//
//  VHallMsgModels.h
//  VHallSDK
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  聊天消息
 */
typedef NS_ENUM(NSInteger,ChatMsgType) {
    ChatMsgTypeText     = 0, // 文本
    ChatMsgTypeImage    = 1, // 图片
    ChatMsgTypeLink     = 2, // 链接
    ChatMsgTypeVideo    = 3, // 视频
    ChatMsgTypeVoice    = 4, // 音频
};


@interface VHallMsgModels : NSObject
@property (nonatomic, copy) NSString * join_id;
@property (nonatomic, copy) NSString * account_id;      //用户ID
@property (nonatomic, copy) NSString * user_name;       //参会时的昵称
@property (nonatomic, copy) NSString * avatar;          //头像url，如果没有则为空字符串
@property (nonatomic, copy) NSString * room;            //房间号，即活动id
@property (nonatomic, copy) NSString * time;            //发送时间，根据服务器时间确定
@property (nonatomic, copy) NSString * role;            //用户类型 host:主持人 guest：嘉宾 assistant：助手 user：观众
@property (nonatomic,assign)NSInteger role_name;        //用户类型 1:主持人 2：观众  3：助手 4：嘉宾
@property (nonatomic, strong) id context;               //附加消息
@property (nonatomic,assign)NSInteger pv;               //频道在线连接数
@property (nonatomic,assign)NSInteger uv;               //频道在线用户数
@property (nonatomic,assign)NSInteger bu;               //频道业务单元
@property (nonatomic, copy) NSString * client;          //消息来源
@property (nonatomic, copy) NSString * msg_id;     ///<消息id
@end

//上下线消息
@interface VHallOnlineStateModel : VHallMsgModels
@property (nonatomic, copy) NSString * event;             ///<online：上线消息  offline：下线消息
@property (nonatomic, copy) NSString * concurrent_user;  ///<房间内当前用户数uv
@property (nonatomic, copy) NSString * attend_count;     ///<参会人数pv
@property (nonatomic, copy) NSString * tracksNum;        ///<PV
@property (nonatomic, assign) BOOL     is_gag;           ///<是否禁言
@property (nonatomic, assign) NSInteger device_status;  ///<设备状态
@property (nonatomic, assign) NSInteger device_type;    ///<设备类型
@end


//聊天消息
@interface VHallChatModel : VHallMsgModels
@property (nonatomic, copy) NSString * text;            ///<聊天消息
@property (nonatomic, assign) ChatMsgType type;         ///<聊天消息类型
@property (nonatomic, copy) NSArray  * imageUrls;       ///<图片消息url列表
@property (nonatomic, strong) VHallChatModel *replyMsg; ///<回复消息
@property (nonatomic, copy)   NSArray  * atList;        ///<@人列表
@end


//自定义消息
@interface VHallCustomMsgModel : VHallMsgModels
@property (nonatomic, copy) NSString * jsonstr;          ///<自定义消息，如果没有则为空字符串
@end

//历史评论
@interface VHCommentModel : VHallMsgModels
@property (nonatomic, copy) NSString * text;            ///<评论内容
@property(nonatomic,copy)   NSString *commentId;        ///<评论ID
@property (nonatomic, strong) VHallChatModel *replyMsg; ///<回复消息
@property (nonatomic, copy) NSArray  * imageUrls;       ///<图片消息url列表
@property (nonatomic, copy)   NSArray  * atList;        ///<@人列表
@end

//提问消息
@interface VHallQuestionModel : NSObject
@property (nonatomic, copy) NSString * type;             ///<类型 question：提问 answer：回答
@property (nonatomic, copy) NSString * question_id;     ///<问题ID
@property (nonatomic, copy) NSString * content;         ///<提问/回答内容
@property (nonatomic, copy) NSString * join_id;         ///<参会id
@property (nonatomic, copy) NSString * created_at;      ///<提问/回答时间 (mm:ss)
@property (nonatomic, copy) NSString * nick_name;       ///<昵称
@property (nonatomic, copy) NSString * avatar;          ///<头像

@property (nonatomic, copy) NSString * created_time; ///<提问/回答时间 (yyyy-MM-dd HH:mm:ss)，新版v3控制台创建的活动才有此值
@end

//回答消息
@interface VHallAnswerModel : VHallQuestionModel
@property (nonatomic, copy) NSString * answer_id;       ///<回答ID
@property (nonatomic, copy) NSString * role_name;       ///<回答人角色 host：主持人 guest：嘉宾 assistant：助手 user：观众
@property (nonatomic, assign)BOOL      is_open;         ///<是否公开回答
@end

//问答消息
@interface VHallQAModel : VHallMsgModels
@property (nonatomic, strong) VHallQuestionModel * questionModel;   ///<问题
@property (nonatomic, strong) NSMutableArray<VHallAnswerModel *> * answerModels; ///<答案
@end


//抽奖消息
@interface VHallLotteryModel : NSObject
@property (nonatomic, copy) NSString * lottery_id;      ///<抽奖ID
@property (nonatomic, copy) NSString * survey_id;       ///<活动ID

//-----------新版抽奖新增----------------
@property (nonatomic, assign) BOOL is_new;  ///<是否为新版抽奖（即使用新版v3版控制台创建的活动） 1：是 0：否
@end

//开始抽奖消息
@interface VHallStartLotteryModel : VHallLotteryModel
@property (nonatomic, copy) NSString * num; ///<抽奖人数

//-----------以下属性为新版抽奖新增----------------
@property (nonatomic, copy) NSString * title; ///<抽奖标题
@property (nonatomic, copy) NSString * remark; ///<抽奖说明
@property (nonatomic, copy) NSString * icon; ///<抽奖动图
@property (nonatomic, assign) NSInteger type;  ///<抽奖类型 (0：普通抽奖 1：口令抽奖)
@property (nonatomic, copy) NSString * command;  ///<抽奖口令(如果是口令抽奖)
@end

//中奖名单
@interface VHallLotteryResultModel : NSObject
@property (nonatomic, copy) NSString * nick_name;       ///<中奖人昵称

//-----------以下属性为新版抽奖新增----------------
@property (nonatomic, copy) NSString * avatar;         ///<中奖人头像
@property (nonatomic, copy) NSString * userId;         ///<中奖人id
@end


//奖品信息
@interface VHallAwardPrizeInfoModel : NSObject
@property (nonatomic, copy) NSString *awardName;  ///<奖品名称
@property (nonatomic, copy) NSString *awardIcon;  ///<奖品图片
@property (nonatomic, copy) NSString *award_desc;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *link_url;
@end

//结束抽奖消息
@interface VHallEndLotteryModel : VHallLotteryModel
@property (nonatomic, assign) BOOL isWin;               ///<自己是否中奖
@property (nonatomic, copy) NSString * account;        ///<自己的登录账号（自己中奖才有值）
@property (nonatomic, copy) NSMutableArray<VHallLotteryResultModel *> *resultModels; ///<中奖名单 (旧版抽奖会返回此值，新版抽奖结束消息将不会返回此值，请使用VHallLottery调用接口获取中奖名单)

//-----------以下属性为新版抽奖新增----------------
@property (nonatomic, strong) VHallAwardPrizeInfoModel *prizeInfo;   ///<奖品信息
@property (nonatomic, assign) BOOL publish_winner;   ///<是否显示中奖名单
@end



//调查问卷消息
@interface VHallSurveyModel : NSObject
@property(nonatomic,copy) NSString * releaseTime; ///<发起时间
@property(nonatomic,copy) NSString * surveyId; ///<问卷ID
@property(nonatomic,copy) NSString * joinId;
@property (nonatomic, copy) NSURL *surveyURL; ///<问卷URL地址（v4.0.4新增）
@end


