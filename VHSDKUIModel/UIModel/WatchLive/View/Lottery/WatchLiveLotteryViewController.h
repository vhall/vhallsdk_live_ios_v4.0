//
//  WatchLiveLotteryViewController.h
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VHLiveSDK/VHallLottery.h>
#import <VHLiveSDK/VHallMsgModels.h>

@interface WatchLiveLotteryViewController : UIViewController

@property (nonatomic, strong) VHallLottery * lottery;
@property (nonatomic, strong) VHallStartLotteryModel * startLotteryModel;
@property (nonatomic, strong) VHallEndLotteryModel * endLotteryModel;


@end
