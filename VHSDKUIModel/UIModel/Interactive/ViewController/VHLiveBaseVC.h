//
//  VHLiveBaseVC.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VHLiveBaseVC : UIViewController

/** 相机权限 */
@property (nonatomic, assign ,readonly) BOOL videoAccess;
/** 麦克风权限 */
@property (nonatomic, assign , readonly) BOOL audioAccess;
/** 是否正在强制旋转屏幕 */
@property (nonatomic, assign) BOOL forceRotating;
/** 空视图icon */
@property (nonatomic, strong) UIImageView *emptyIcon;
/** 空视图title */
@property (nonatomic, strong) UILabel *emptyLab;
/** 是否显示空视图 */
@property (nonatomic, assign) BOOL showEmptyView;

//强制旋转屏幕方向
- (void)forceRotateUIInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)showLoading;

- (void)hiddenLoading;

//导航栏隐藏时，调用该方法可添加一个返回按钮，点击事件默认返回上一个界面，如果需要自定义返回事件，则传block，否则传nil
- (void)addBackBtnActionClick:(void(^ _Nullable)(void))backBlock;

//获取摄像头与麦克风权限
- (void)getMediaAccess:(void(^_Nullable)(BOOL videoAccess,BOOL audioAcess))completionBlock;

//弹出媒体权限提示
- (void)shwoMediaAuthorityAlertWithMessage:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
