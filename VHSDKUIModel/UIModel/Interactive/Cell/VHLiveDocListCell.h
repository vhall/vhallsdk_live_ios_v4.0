//
//  VHLiveDocListCell.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHDocListModel;
NS_ASSUME_NONNULL_BEGIN

@interface VHLiveDocListCell : UITableViewCell

/** 文档列表模型 */
@property (nonatomic, strong) VHDocListModel *model;

@end

NS_ASSUME_NONNULL_END
