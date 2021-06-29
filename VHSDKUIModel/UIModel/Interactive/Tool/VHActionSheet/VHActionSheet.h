//
//  VHActionSheet.h
//  VHActionSheet
//
//  Created by Leo on 2015/4/27.
//
//  Copyright (c) 2015-2019 Leo <leodaxia@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import <UIKit/UIKit.h>
#import "VHActionSheetConfig.h"


@class VHActionSheet;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - VHActionSheet Block

/**
 Handle click button.
 */
typedef void(^VHActionSheetClickedHandler)(VHActionSheet *actionSheet, NSInteger buttonIndex);

/**
 Handle action sheet will present.
 */
typedef void(^VHActionSheetWillPresentHandler)(VHActionSheet *actionSheet);
/**
 Handle action sheet did present.
 */
typedef void(^VHActionSheetDidPresentHandler)(VHActionSheet *actionSheet);

/**
 Handle action sheet will dismiss.
 */
typedef void(^VHActionSheetWillDismissHandler)(VHActionSheet *actionSheet, NSInteger buttonIndex);
/**
 Handle action sheet did dismiss.
 */
typedef void(^VHActionSheetDidDismissHandler)(VHActionSheet *actionSheet, NSInteger buttonIndex);


#pragma mark - VHActionSheet Delegate

@protocol VHActionSheetDelegate <NSObject>

@optional

/**
 Handle click button.
 */
- (void)actionSheet:(VHActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

/**
 Handle action sheet will present.
 */
- (void)willPresentActionSheet:(VHActionSheet *)actionSheet;
/**
 Handle action sheet did present.
 */
- (void)didPresentActionSheet:(VHActionSheet *)actionSheet;

/**
 Handle action sheet will dismiss.
 */
- (void)actionSheet:(VHActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;
/**
 Handle action sheet did dismiss.
 */
- (void)actionSheet:(VHActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end


#pragma mark - VHActionSheet

@interface VHActionSheet : UIView


#pragma mark - Properties

/**
 Title.
 */
@property (nullable, nonatomic, copy) NSString *title;

/**
 Cancel button's title.
 */
@property (nullable, nonatomic, copy) NSString *cancelButtonTitle;

/**
 Cancel button's index.
 */
@property (nonatomic, assign, readonly) NSInteger cancelButtonIndex;

/**
 VHActionSheet's delegate.
 */
@property (nullable, nonatomic, weak) id<VHActionSheetDelegate> delegate;

/**
 Deprecated, use `destructiveButtonIndexSet` instead.
 */
@property (nullable, nonatomic, strong) NSIndexSet *redButtonIndexSet __deprecated_msg("Property deprecated. Use `destructiveButtonIndexSet` instead.");

/**
 All destructive buttons' set. You should give it the `NSNumber` type items.
 */
@property (nullable, nonatomic, strong) NSIndexSet *destructiveButtonIndexSet;

/**
 Destructive button's color. Default is RGB(254, 67, 37).
 */
@property (nonatomic, strong) UIColor *destructiveButtonColor;
/**
 Destructive button's background color. Default is `[UIColor clearColor]`.
 */
@property (nonatomic, strong) UIColor *destructiveButtonBgColor;

/**
 Title's color. Default is `[UIColor blackColor]`.
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 Cancel button's color. Default is `buttonColor`.
 */
@property (nonatomic, strong) UIColor *cancelButtonColor;
/**
 Cancel button's backgroundColor, without destructive buttons. Default is `[UIColor clarColor]`.
 */
@property (nonatomic, strong) UIColor *cancelButtonBgColor;

/**
 All buttons' Buttons' color
 */
@property (nonatomic, strong) UIColor *buttonColor;
/**
 Buttons' backgroundColor, without destructive buttons. Default is `[UIColor clarColor]`.
 */
@property (nonatomic, strong) UIColor *buttonBgColor;

/**
 Title's font. Default is `[UIFont systemFontOfSize:14.0f]`.
 */
@property (nonatomic, strong) UIFont *titleFont;
/**
 所有按钮字体 默认 [UIFont systemFontOfSize:16.0f]`.
 */
@property (nonatomic, strong) UIFont *buttonFont;
/**
 所有按钮高度，默认55
 */
@property (nonatomic, assign) CGFloat buttonHeight;

/**
 All buttons' corner. Default is 0.0f;
 */
@property (nonatomic, assign) CGFloat buttonCornerRadius;

/**
 弹出视图左上、右上角圆角值，默认15
 */
@property (nonatomic, assign) CGFloat topCornerRadius;

/**
 If buttons' bottom view can scrolling. Default is NO.
 */
@property (nonatomic, assign, getter=canScrolling) BOOL scrolling;

/**
 Visible buttons' count. You have to set `scrolling = YES` if you want to set it.
 */
@property (nonatomic, assign) CGFloat visibleButtonCount;

/**
 Animation duration. Default is 0.3 seconds.
 */
@property (nonatomic, assign) CGFloat animationDuration;

/**
 Opacity of dark background. Default is 0.5f.
 */
@property (nonatomic, assign) CGFloat darkOpacity;

/**
 If you can tap darkView to dismiss. Defalut is NO, you can tap dardView to dismiss.
 */
@property (nonatomic, assign) BOOL darkViewNoTaped;

/**
 是否关闭弹窗背景模糊效果，默认YES 无模糊效果
 */
@property (nonatomic, assign) BOOL unBlur;

/**
 Style of blur effect. Default is `UIBlurEffectStyleExtraLight`. iOS 8.0 +
 */
@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle;

/**
 Title's edge insets. Default is `UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f)`.
 */
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
/**
 Button's edge insets. Default is `UIEdgeInsetsMake(8.0, 15.0, 8.0f, 15.0f)`.
 */
@property (nonatomic, assign) UIEdgeInsets buttonEdgeInsets;
///**
// ActionSheet's edge insets. Default is `UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)`.
// */
//@property (nonatomic, assign) UIEdgeInsets actionSheetEdgeInsets;

/**
 Cell's separator color. Default is `RGBA(170/255.0f, 170/255.0f, 170/255.0f, 0.5f)`.
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 Blur view's background color. Default is `RGBA(255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 0.5f)`.
 */
@property (nonatomic, strong) UIColor *blurBackgroundColor;

/**
 Title can be limit in numberOfTitleLines. Default is 0.
 */
@property (nonatomic, assign) NSInteger numberOfTitleLines;

/**
 Auto hide when the device rotated. Default is NO, won't auto hide.
 */
@property (nonatomic, assign) BOOL autoHideWhenDeviceRotated;

/**
 Disable auto dismiss after clicking. Default is NO, will auto dismiss.
 */
@property (nonatomic, assign) BOOL disableAutoDismissAfterClicking;


/**
 VHActionSheet clicked handler.
 */
@property (nullable, nonatomic, copy) VHActionSheetClickedHandler     clickedHandler;
/**
 VHActionSheet will present handler.
 */
@property (nullable, nonatomic, copy) VHActionSheetWillPresentHandler willPresentHandler;
/**
 VHActionSheet did present handler.
 */
@property (nullable, nonatomic, copy) VHActionSheetDidPresentHandler  didPresentHandler;
/**
 VHActionSheet will dismiss handler.
 */
@property (nullable, nonatomic, copy) VHActionSheetWillDismissHandler willDismissHandler;
/**
 VHActionSheet did dismiss handler.
 */
@property (nullable, nonatomic, copy) VHActionSheetDidDismissHandler  didDismissHandler;


#pragma mark - Methods

#pragma mark Delegate

/**
 Initialize an instance of VHActionSheet (Delegate).
 
 @param title             title
 @param delegate          delegate
 @param cancelButtonTitle cancelButtonTitle
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
                      delegate:(nullable id<VHActionSheetDelegate>)delegate
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
             otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Delegate).
 
 @param title                 title
 @param delegate              delegate
 @param cancelButtonTitle     cancelButtonTitle
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
                      delegate:(nullable id<VHActionSheetDelegate>)delegate
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
         otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;

/**
 Initialize an instance of VHActionSheet (Delegate).
 
 @param title             title
 @param delegate          delegate
 @param cancelButtonTitle cancelButtonTitle
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
                     delegate:(nullable id<VHActionSheetDelegate>)delegate
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Delegate).
 
 @param title                 title
 @param delegate              delegate
 @param cancelButtonTitle     cancelButtonTitle
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
                     delegate:(nullable id<VHActionSheetDelegate>)delegate
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
        otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;


#pragma mark Block

/**
 Initialize an instance of VHActionSheet (Block).
 
 @param title             title
 @param cancelButtonTitle cancelButtonTitle
 @param clickedHandler    clickedHandler
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                       clicked:(nullable VHActionSheetClickedHandler)clickedHandler
             otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Block).
 
 @param title                 title
 @param cancelButtonTitle     cancelButtonTitle
 @param clickedHandler        clickedHandler
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                       clicked:(nullable VHActionSheetClickedHandler)clickedHandler
         otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;

/**
 Initialize an instance of VHActionSheet (Block).
 
 @param title             title
 @param cancelButtonTitle cancelButtonTitle
 @param clickedHandler    clickedHandler
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                      clicked:(nullable VHActionSheetClickedHandler)clickedHandler
            otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Block).
 
 @param title                 title
 @param cancelButtonTitle     cancelButtonTitle
 @param clickedHandler        clickedHandler
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                      clicked:(nullable VHActionSheetClickedHandler)clickedHandler
        otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;



/**
 Initialize an instance of VHActionSheet (Block).
 
 @param title             title
 @param cancelButtonTitle cancelButtonTitle
 @param didDismissHandler didDismissHandler
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    didDismiss:(nullable VHActionSheetDidDismissHandler)didDismissHandler
             otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Block).
 
 @param title                 title
 @param cancelButtonTitle     cancelButtonTitle
 @param didDismissHandler     didDismissHandler
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
+ (instancetype)sheetWithTitle:(nullable NSString *)title
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    didDismiss:(nullable VHActionSheetDidDismissHandler)didDismissHandler
         otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;

/**
 Initialize an instance of VHActionSheet (Block).
 
 @param title             title
 @param cancelButtonTitle cancelButtonTitle
 @param didDismissHandler didDismissHandler
 @param otherButtonTitles otherButtonTitles
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                   didDismiss:(nullable VHActionSheetDidDismissHandler)didDismissHandler
            otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Initialize an instance of VHActionSheet with title array (Block).
 
 @param title                 title
 @param cancelButtonTitle     cancelButtonTitle
 @param didDismissHandler     didDismissHandler
 @param otherButtonTitleArray otherButtonTitleArray
 
 @return An instance of VHActionSheet.
 */
- (instancetype)initWithTitle:(nullable NSString *)title
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                   didDismiss:(nullable VHActionSheetDidDismissHandler)didDismissHandler
        otherButtonTitleArray:(nullable NSArray<NSString *> *)otherButtonTitleArray;


#pragma mark Append & Show

/**
 Append buttons with titles.
 
 @param titles titles
 */
- (void)appendButtonsWithTitles:(nullable NSString *)titles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Append button at index with title.
 
 @param title title
 @param index index
 */
- (void)appendButtonWithTitle:(nullable NSString *)title atIndex:(NSInteger)index;

/**
 Append buttons at indexSet with titles.
 
 @param titles  titles
 @param indexes indexes
 */
- (void)appendButtonsWithTitles:(NSArray<NSString *> *)titles atIndexes:(NSIndexSet *)indexes;

/**
 Show the instance of VHActionSheet.
 */
- (void)show;

/**
 Get button title with index.
 
 @param index index
 @return button title
 */
- (nullable NSString *)buttonTitleAtIndex:(NSInteger)index;

/**
 Set button title with index.

 @param title title
 @param index index
 */
- (void)setButtonTitle:(nullable NSString *)title atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
