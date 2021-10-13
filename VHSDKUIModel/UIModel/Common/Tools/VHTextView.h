//
// VHTextView.h

//#import "IQKeyboardManagerConstants.h"

#import <UIKit/UITextView.h>

/**
 UITextView with placeholder support
 */
@interface VHTextView : UITextView

/**
 Set textView's placeholder text. Default is nil.
 */
@property(nullable, nonatomic,copy) IBInspectable NSString    *placeholder;

/**
 Set textView's placeholder attributed text. Default is nil.
 */
@property(nullable, nonatomic,copy) IBInspectable NSAttributedString    *attributedPlaceholder;

/**
 To set textView's placeholder text color. Default is nil.
 */
@property(nullable, nonatomic,copy) IBInspectable UIColor    *placeholderTextColor;

@end




