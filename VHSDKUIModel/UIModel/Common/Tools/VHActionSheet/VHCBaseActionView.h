//
//  VHCBaseActionView.h
//  VHCUICore
//
//  Created by 郭超 on 2020/11/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ShowCompleteBlock)(void); //显示完成回调
typedef void(^DismissCompleteBlock)(void); //消失完成回调

@interface VHCBaseActionView : UIView

@property (nonatomic, copy) ShowCompleteBlock showBlock;
@property (nonatomic, copy) DismissCompleteBlock disMissBlock;

- (instancetype)initWithFrame:(CGRect)frame popViewLength:(CGFloat)popViewLength;
/** 弹窗内容view */
@property (nonatomic, strong) UIView *contentView;
/** 弹窗高度 (横屏下为弹窗宽度) */
@property (nonatomic, assign) CGFloat popViewLength;

//显示
- (void)showInView:(UIView *)view;

//移除
- (void)dismiss;


@end

NS_ASSUME_NONNULL_END
