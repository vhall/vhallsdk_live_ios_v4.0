//
//  WatchLiveLotteryWriteWinInfoView.h
//  UIModel
//
//  Created by xiongchao on 2020/9/9.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VHLiveSDK/VHallLottery.h>

NS_ASSUME_NONNULL_BEGIN
@class WatchLiveLotteryWriteWinInfoView;

@protocol WatchLiveLotteryWriteWinInfoViewDelegate <NSObject>

//提交中奖信息
- (void)writeWinInfoView:(WatchLiveLotteryWriteWinInfoView *)writeWinInfoView submitWinInfo:(NSDictionary *)param;

@end


@interface WatchLiveLotteryWriteWinInfoView : UIView

@property (nonatomic, weak) id<WatchLiveLotteryWriteWinInfoViewDelegate> delegate;
@property (nonatomic, strong) NSArray <VHallLotterySubmitConfig *> *submitConfigArr;

@end

NS_ASSUME_NONNULL_END
