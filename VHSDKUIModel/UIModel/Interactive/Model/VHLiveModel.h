//
//  VHLiveModel.h
//  UIModel
//
//  Created by leiheng on 2021/4/16.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveModel : NSObject

/** 活动id */
@property (nonatomic, copy) NSString *webinar_id;
/** 活动标题 */
@property (nonatomic, copy) NSString *webinar_title;
/** 活动开始时间 */
@property (nonatomic, copy) NSString *webinar_start_time;
/** 活动封面 */
@property (nonatomic, copy) NSString *webinar_img;
/** 直播类型 2音频 3视频 4互动 */
@property (nonatomic, assign) VHLiveType webinar_layout;
/** 作者昵称 */
@property (nonatomic, copy) NSString *webinar_user_nick;
/** 活动作者头像 */
@property (nonatomic, copy) NSString *webinar_user_icon;

//------------------自定义参数----------------
/** 是否隐藏顶部view */
@property (nonatomic, assign) BOOL hiddenTopView;
/** 直播总时长 */
@property (nonatomic, copy) NSString *liveDuration;
/** 最高并发数（取uv） */
@property (nonatomic, assign) NSInteger concurrentNum;
/** 累计观看数（取pv） */
@property (nonatomic, assign) NSInteger pageView;
/** 聊天条数 */
@property (nonatomic, assign) NSInteger chatNum;

/** 设置直播状态（直播开始/结束调用）活动状态 type 1直播 3结束 */
- (void)setLiveState:(NSString *)type webinarId:(NSString *)webinarId success:(void(^_Nullable)(void))success fail:(void(^_Nullable)(NSError *error))fail;

@end

NS_ASSUME_NONNULL_END
