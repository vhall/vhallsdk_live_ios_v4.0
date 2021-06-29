//
//  VHDocListVC.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBaseVC.h"

NS_ASSUME_NONNULL_BEGIN
@class VHRoom;
@interface VHDocListVC : VHLiveBaseVC

@property (nonatomic, strong) VHRoom *room;
/** 文档选择回调 */
@property (nonatomic, copy) void(^docSelectBlcok)(NSString *docId);

@end

NS_ASSUME_NONNULL_END
