//
//  VHEndPublisherVC.h
//  UIModel
//
//  Created by leiheng on 2021/4/30.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveBaseVC.h"

NS_ASSUME_NONNULL_BEGIN
@class VHEndPublisherVC;
@class VHLiveModel;
@protocol VHEndPublisherVCDelegate <NSObject>

//直播结束页返回
- (void)endPublisherBackAction:(VHEndPublisherVC *)endVC;

@end

@interface VHEndPublisherVC : VHLiveBaseVC

/** 直播信息 */
@property (nonatomic, strong) VHLiveModel *liveModel;

@property (nonatomic, weak) id<VHEndPublisherVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
