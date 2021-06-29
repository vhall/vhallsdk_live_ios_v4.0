//
//  VHLiveInfoDetailChatCell.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHLiveMsgModel;
NS_ASSUME_NONNULL_BEGIN

#define ChatLabelMaxLayoutWidth 300 //label最大宽度

@interface VHLiveInfoDetailChatCell : UITableViewCell

/** 聊天模型 */
@property (nonatomic, strong) VHLiveMsgModel *msgModel;

@end

NS_ASSUME_NONNULL_END
