//
//  VHMessageToolView.h
//  vhall1
//
//  Created by vhallrd01 on 14-6-20.
//  Copyright (c) 2014年 vhallrd01. All rights reserved.
//

//输入工具view
#import <UIKit/UIKit.h>
#import "VHMessageTextView.h"
#import "DXFaceView.h"

#define kInputTextViewMinHeight 34
#define kHorizontalPadding 50
#define kVerticalPadding 8.5

@protocol VHMessageToolBarDelegate <NSObject>

- (void)didSendText:(NSString *)text;

@end
@interface VHMessageToolView : UIView <UITextViewDelegate>

@property (weak, nonatomic) id<VHMessageToolBarDelegate> delegate;

@property(nonatomic,assign) int  maxLength; //最大输入字数，默认70

//结束输入（包括文字输入和表情输入）
- (BOOL)endEditing:(BOOL)force;

//激活键盘，开始文本输入
-(void)beginTextViewInView;
@end
