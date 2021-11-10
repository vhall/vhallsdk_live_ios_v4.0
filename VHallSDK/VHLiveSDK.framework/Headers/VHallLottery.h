//
//  VHallLottery.h
//  VHallSDK
//
//  Created by Ming on 16/10/13.
//  Copyright © 2016年 vhall. All rights reserved.
//
// 抽奖
// !!!!:注意实例方法使用时机，看直播/回放————>在收到"播放连接成功回调"或"视频信息预加载成功回调"以后使用。

#import <Foundation/Foundation.h>
#import "VHallMsgModels.h"
#import "VHallBasePlugin.h"

//领奖页提交中奖用户信息填写选项的配置
@interface VHallLotterySubmitConfig : NSObject
@property (nonatomic, copy) NSString *field;           ///<该输入项标题
@property (nonatomic, copy) NSString *placeholder;     ///<该输入项placeholder
@property (nonatomic, assign) NSInteger is_required;     ///<是否必填 1:必填 0:非必填
@property (nonatomic, assign) NSInteger is_system;     ///<是否是系统选项，即非自定义项 1:是 0:否
@property (nonatomic, assign) NSInteger rank;      ///<输入项显示位置，控制台添加的自定义项显示顺序，越大越靠后显示
@property (nonatomic, copy) NSString *field_key;     ///<提交中奖信息传参字典对应的key
@end

@protocol VHallLotteryDelegate <NSObject>
@optional
//抽奖开始
- (void)startLottery:(VHallStartLotteryModel *)msg;
//抽奖结束
- (void)endLottery:(VHallEndLotteryModel *)msg;

@end

@interface VHallLottery : VHallBasePlugin

@property (nonatomic, weak) id <VHallLotteryDelegate> delegate;

/// 提交个人中奖信息
/// @param info 个人信息 @{@"name":姓名,@"phone":手机号,...}
/// @param success 成功回调Block
/// @param reslutFailedCallback 失败回调Block 字典结构：{code：错误码，content：错误信息}
- (void)submitLotteryInfo:(NSDictionary *)info success:(void(^)(void))success failed:(void (^)(NSDictionary *failedData))reslutFailedCallback;

/// 获取填写中奖信息输入项配置，通过各项中的field_key作为key，以及对应输入内容作为value，一起组成字典，用于提交中奖信息接口传参 （v6.0新增，仅支持v3控制台新建的直播抽奖使用）
/// @param success 成功回调Block
/// @param reslutFailedCallback 失败回调Block 字典结构：{code：错误码，content：错误信息}
- (void)getSubmitConfigSuccess:(void(^)(NSArray <VHallLotterySubmitConfig *> *submitList))success failed:(void (^)(NSDictionary *failedData))reslutFailedCallback;


/// 口令抽奖-立即参与 （v6.0新增，仅支持v3控制台新建的直播抽奖使用）
/// @param success 成功回调Block
/// @param reslutFailedCallback 失败回调Block 字典结构：{code：错误码，content：错误信息}
- (void)lotteryParticipationSuccess:(void(^)(void))success failed:(void (^)(NSDictionary *failedData))reslutFailedCallback;


/// 获取中奖名单 （v6.0新增，仅支持v3控制台新建的直播抽奖使用）
/// @param success 成功回调blck
/// @param reslutFailedCallback 失败回调Block 字典结构：{code：错误码，content：错误信息}
- (void)getLotteryWinListSuccess:(void(^)(NSArray <VHallLotteryResultModel *> *submitList))success failed:(void (^)(NSDictionary *failedData))reslutFailedCallback;


@end

