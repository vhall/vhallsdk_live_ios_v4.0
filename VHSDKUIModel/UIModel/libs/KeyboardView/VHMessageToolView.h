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

@interface VHMessageToolView : UIView<UITextViewDelegate>
@property (nonatomic,strong) UIView *activityButtomView; //当前底部表情键盘view

@property (weak, nonatomic) id<VHMessageToolBarDelegate> delegate;

@property(nonatomic,assign) int  maxLength; //最大字符个数，默认70

//最小输入工具高度
+(CGFloat)defaultHeight;

//结束输入（包括文字输入和表情输入）
- (BOOL)endEditing:(BOOL)force;

//开始文本输入
-(void)beginTextViewInView;

//重置聊天框高度
- (void)resetMessageTextHeight;

//更新键盘frame
- (void)updateFrame;
@end
