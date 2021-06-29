//
//  VHLiveMemberModel.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VHLocalRenderView;

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveMemberModel : NSObject

/** 用户id */
@property (nonatomic, copy) NSString *account_id;
/** 参会id */
@property (nonatomic, copy) NSString *join_id;
/** 头像 */
@property (nonatomic, copy) NSString *avatar;
/** 昵称 */
@property (nonatomic, copy) NSString *nickname;
/** 角色  1主持人 2观众 3助理 4嘉宾*/
@property (nonatomic, assign) VHLiveRole role_name;
/** 是否上麦中 1上麦中*/
@property (nonatomic, assign) NSInteger is_speak;
/** 是否被禁言 */
@property (nonatomic, assign) BOOL is_banned;
/** 是否被踢出 */
@property (nonatomic, assign) BOOL is_kicked;
/** 设备类型 */
@property (nonatomic, assign) NSInteger device_type;
/** 设备状态 1:可以上麦 其他:不可以上麦 */
@property (nonatomic, assign) NSInteger device_status;
/** 是否不支持连麦 (设备异常) */
@property (nonatomic, assign) BOOL deviceError;


//------------------自定义属性-------------------
/** 是否关闭摄像头 */
@property (nonatomic, assign) BOOL closeCamera;
/** 是否关闭麦克风 */
@property (nonatomic, assign) BOOL closeMicrophone;
/** 互动画面 */
@property (nonatomic, strong) VHLocalRenderView *videoView;
/** 是否为主讲人（是否有文档权限）*/
@property (nonatomic, assign) BOOL haveDocPermission;
/** 没有成员管理权限，不显示更多按钮 */
@property (nonatomic, assign) BOOL hiddenMoreBtn;


+ (instancetype)modelWithVHRenderView:(VHLocalRenderView *)view;


//获取受限列表
+ (void)getLimitUsersListWithWebinarId:(NSString *)webinarId page:(NSInteger)page success:(void(^)(NSMutableArray <VHLiveMemberModel *> *array , BOOL isLastPage))successBlock failure:(void(^)(NSError *_Nonnull error))failureBlock;

@end

NS_ASSUME_NONNULL_END
