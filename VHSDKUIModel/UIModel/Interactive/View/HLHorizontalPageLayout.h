//
//  HLHorizontalPageLayout.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HLHorizontalPageLayout;
@protocol HLHorizontalPageLayoutDetegate <NSObject>

- (CGSize)layout:(HLHorizontalPageLayout *)horizontalPageLayout itemSizeForSection:(NSInteger)section;

- (UIEdgeInsets)layout:(HLHorizontalPageLayout *)horizontalPageLayout insetForSection:(NSInteger)section;

@end

@interface HLHorizontalPageLayout : UICollectionViewLayout

@property (nonatomic, weak) id <HLHorizontalPageLayoutDetegate> deslegate;

@property (nonatomic,assign) CGFloat minimumLineSpacing;
@property (nonatomic,assign) CGFloat minimumInteritemSpacing;
/** 可滚动的总页数 */
@property (nonatomic, assign ,readonly) NSInteger pageNum;

@end

NS_ASSUME_NONNULL_END
