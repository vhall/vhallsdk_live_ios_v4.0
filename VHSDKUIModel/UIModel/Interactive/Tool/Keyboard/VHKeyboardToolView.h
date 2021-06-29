//
//  VHKeyboardToolView.h
//  VHVSS
//
//  Created by vhall on 2019/9/16.
//  Copyright © 2019 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VHKeyboardToolView;

@protocol VHKeyboardToolViewDelegate <NSObject>

@optional
/*! 发送按钮事件回调*/
- (void)keyboardToolView:(VHKeyboardToolView *)view sendText:(NSString *)text;

@end


@interface VHKeyboardToolView : UIView

/*! 发送按钮*/
@property (nonatomic, strong) UIButton *sendBtn;
/*! 输入框*/
@property (nonatomic, strong) QMUITextView *textView;

/*! 是否正在编辑*/
@property (nonatomic , assign , readonly) BOOL isEditing;

/*! 代理指针*/
@property (nonatomic, weak) id <VHKeyboardToolViewDelegate> delegate;

/*! 收起键盘*/
- (void)resignFirstResponder;
/*! 打开键盘*/
- (void)becomeFirstResponder;

/*! 清空内容*/
- (void)clearText;

//表情匹配
+ (NSMutableAttributedString *)processCommentContent:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;

@end

NS_ASSUME_NONNULL_END
