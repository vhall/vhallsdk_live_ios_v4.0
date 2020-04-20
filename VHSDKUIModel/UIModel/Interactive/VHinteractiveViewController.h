//
//  VHinteractiveViewController.h
//  UIModel
//
//  Created by vhall on 2018/7/30.
//  Copyright © 2018年 www.vhall.com. All rights reserved.
//

#import "VHBaseViewController.h"

@interface VHinteractiveViewController : VHBaseViewController

@property (nonnull,nonatomic, copy) NSString *roomId;//互动房间id

@property(nonatomic, assign)int      pushResolution;  //互动分辨率
@property(nonatomic, assign)BOOL     inavBeautifyFilterEnable;//互动美颜开关
@end
