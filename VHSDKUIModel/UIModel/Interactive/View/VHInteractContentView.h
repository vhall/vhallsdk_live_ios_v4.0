//
//  VHInteractContentView.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VHInteractive/VHRoom.h>

@class VHLiveMemberModel;

NS_ASSUME_NONNULL_BEGIN

@interface VHInteractContentView : UIView

/** 数据源 */
@property (nonatomic, strong , readonly) NSMutableArray <VHLiveMemberModel *> *dadaSource;

- (instancetype)initWithLandscapeShow:(BOOL)landScapeShow;

//重新刷新collectionView数据
- (void)reloadAllData;

//**上麦添加视频画面
- (void)addAttendWithUser:(VHLiveMemberModel *)model;

//**下麦移除视频画面
- (void)removeAttendView:(VHLocalRenderView *)renderView;

//主讲人视频
- (VHLocalRenderView *)docPermissionVideoView;

//共享屏幕或插播视频
- (VHLocalRenderView *)screenOrFileVideo;


//某个视频摄像头开关改变
- (void)renderView:(VHRenderView *)renderView closeCamera:(BOOL)state;
//某个视频麦克风开关改变
- (void)renderView:(VHRenderView *)renderView closeMicrophone:(BOOL)state;

//某个用户摄像头开关改变
- (void)targerId:(NSString *)targerId closeCamera:(BOOL)state;
//某个用户麦克风开关改变
- (void)targerId:(NSString *)targerId closeMicrophone:(BOOL)state;

//某个用户是否在麦上
- (BOOL)haveRenderViewWithTargerId:(NSString *)targerId;

//获取连麦用户列表
- (NSMutableArray<VHLiveMemberModel *> *)getMicUserList;

@end

NS_ASSUME_NONNULL_END
