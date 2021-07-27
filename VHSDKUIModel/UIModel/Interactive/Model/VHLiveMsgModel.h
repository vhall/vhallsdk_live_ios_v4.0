//
//  VHLiveMsgModel.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VHLiveSDK/VHallApi.h>

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveMsgModel : NSObject

/** 消息ID */
@property (nonatomic,copy)  NSString *msg_id;
/** 角色 用户类型:1主持人 2观众 3助理 4嘉宾 */
@property (nonatomic, assign) VHLiveRole role;
/** 聊天内容 */
@property (nonatomic, copy) NSString *context;
/** 用户名 */
@property (nonatomic, copy) NSString *nickName;

/** 是否为进入直播间消息 , 默认NO */
@property (nonatomic, assign) BOOL isOnlineMsg;
/** 当前观看人数（取消息里的uv） */
@property (nonatomic, assign) NSInteger watchNum;
/** 最高并发数（取uv） */
@property (nonatomic, assign) NSInteger concurrentNum;
/** 累计观看数（取pv） */
@property (nonatomic, assign) NSInteger pageView;

@property (nonatomic, copy) NSArray  * imageUrls;       ///<图片消息url列表
@property (nonatomic, assign) ChatMsgType type;         ///<聊天消息类型
@end

NS_ASSUME_NONNULL_END
