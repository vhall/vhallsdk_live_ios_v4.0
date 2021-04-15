//
//  VHScrollTextView.h
//  UIModel
//
//  Created by xiongchao on 2021/4/8.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//
//文字跑马灯
#import <UIKit/UIKit.h>
#import <VHLiveSDK/VHWebinarInfo.h>
NS_ASSUME_NONNULL_BEGIN

@interface VHScrollTextView : UIView

//展示文字跑马灯
- (void)showScrollTextWithModel:(VHWebinarScrollTextInfo *)model;

//停止跑马灯
- (void)stopScrollText;
@end

NS_ASSUME_NONNULL_END
