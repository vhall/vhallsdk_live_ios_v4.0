//
//  VHEndPublisherCell.h
//  UIModel
//
//  Created by leiheng on 2021/4/30.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class VHEndPublisherCellModel;
@interface VHEndPublisherCell : UICollectionViewCell

@property (nonatomic, strong) VHEndPublisherCellModel *model;

@end

@interface VHEndPublisherCellModel : NSObject
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 标题 */
@property (nonatomic, copy) NSString *titleValue;
@end

NS_ASSUME_NONNULL_END
