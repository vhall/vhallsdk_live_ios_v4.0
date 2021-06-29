//
//  VHLiveInfoDetailChatView.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ChatViewHeight 200 //聊天视图高度

@class VHLiveMsgModel;
NS_ASSUME_NONNULL_BEGIN

@interface VHLiveInfoDetailChatView : UIView

//本地最大保留消息条数，默认10000
@property (nonatomic,assign) NSUInteger maxCount;
/// 欢迎语
@property (nonatomic , copy) NSString * welcome;
/** 聊天条数 */
@property (nonatomic, assign ,readonly) NSInteger chatNumCount;

//收到消息
- (void)receiveMessage:(VHLiveMsgModel *)model;

@end

NS_ASSUME_NONNULL_END
