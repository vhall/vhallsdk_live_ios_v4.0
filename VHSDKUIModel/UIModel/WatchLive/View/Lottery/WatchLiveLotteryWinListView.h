//
//  WatchLiveLotteryWinListView.h
//  UIModel
//
//  Created by xiongchao on 2020/9/9.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//
//中奖名单view
#import <UIKit/UIKit.h>
#import <VHLiveSDK/VHallMsgModels.h>
NS_ASSUME_NONNULL_BEGIN

@interface WatchLiveLotteryWinListView : UIView

//设置奖品信息和中奖名单信息
- (void)setLotteryPrizeInfo:(VHallAwardPrizeInfoModel *)prizeInfo winList:(NSArray <VHallLotteryResultModel *> *)winList;

@end

NS_ASSUME_NONNULL_END
