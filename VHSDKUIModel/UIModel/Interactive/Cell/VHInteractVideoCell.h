//
//  VHInteractVideoCell.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VHLiveMemberModel;
NS_ASSUME_NONNULL_BEGIN

@interface VHInteractVideoCell : UICollectionViewCell
/** 成员模型 */
@property (nonatomic, strong) VHLiveMemberModel *model;

//iPhoneX系列横屏适配
- (void)adaptLandscapeiPhoneX:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
