//
//  VHSegmentView.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//
#define VHSegmentViewHeight 45 //标题高度

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VHSegmentView : UIView
/** 是否显示底部指示条,默认：显示 */
@property (nonatomic,assign) BOOL isShowIndicator;
/** 点击回调 */
@property (nonatomic,copy) void(^clickBlock) (NSInteger index);


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

//设置frame，默认选中第一个
- (instancetype)initWithItems:(NSArray *)array;

//设置标签文字底部指示条的位置
- (void)setIndicatorViewIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
