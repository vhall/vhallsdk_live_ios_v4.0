//
//  VHLiveDocContentView.h
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VHDocumentView;
@class VHLiveDocContentView;

@protocol VHLiveDocContentViewDelegate <NSObject>

//是否能滑动
- (BOOL)canSwipe;

//文档移除完成
- (void)docContentViewDisMissComplete:(VHLiveDocContentView *)docContentView;

///文档左滑/右滑翻页
- (void)docContentView:(VHLiveDocContentView *)docContentView swipeDirection:(UISwipeGestureRecognizerDirection)direction;

@end

@interface VHLiveDocContentView : UIView

/** 文档view父控件 */
@property (nonatomic, strong) UIView *contentView;

/** 无文档空视图提示文案 */
@property (nonatomic, strong) UILabel *emptyLab;

/** 代理 */
@property (nonatomic, weak) id<VHLiveDocContentViewDelegate> delegate;

//添加文档
- (void)addDocumentView:(VHDocumentView *)view;
//删除文档
- (void)removeDocumentView:(VHDocumentView *)view;

//将指定的文档挪到最顶层显示
- (void)bringSubviewToFrontWithDocId:(NSString *)cid;

//当前是否有文档
- (BOOL)haveShowDocView;

//设置文档隐藏/显示
- (void)setDocViewHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
