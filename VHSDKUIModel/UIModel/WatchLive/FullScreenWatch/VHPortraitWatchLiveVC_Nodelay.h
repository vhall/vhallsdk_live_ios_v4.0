//
//  VHPortraitWatchLiveVC_Nodelay.h
//  UIModel
//
//  Created by xiongchao on 2021/11/2.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VHPortraitWatchLiveVC_Nodelay : VHBaseViewController

@property(nonatomic,copy)NSString * roomId; //活动id
@property(nonatomic,copy)NSString * kValue; //活动观看密码

@property (nonatomic, assign) BOOL interactBeautifyEnable; //互动美颜开关

@end

NS_ASSUME_NONNULL_END
