//
//  VHMessageToolView.m
//  vhall1
//
//  Created by vhallrd01 on 14-6-20.
//  Copyright (c) 2014年 vhallrd01. All rights reserved.
//

#import "VHMessageToolView.h"
#define CellColor       MakeColor(25, 24, 29, 1)

@interface VHMessageToolView ()<DXFaceDelegate>
{
    CGFloat _previousTextViewContentHeight;//上一次inputTextView的contentSize.height
}
@property (nonatomic,strong) UIButton *sendButton;  //发送按钮
@property (nonatomic,nonatomic) UIButton *emojiButton; //表情键盘切换按钮
@property (nonatomic,strong) VHMessageTextView *msgTextView; //输入框视图
@property (nonatomic,assign) CGFloat maxTextInputViewHeight; //最大输入高度
@property (strong, nonatomic) UIView *toolBackGroundView; //表情切换按钮、输入框、发送按钮父视图
@property (strong, nonatomic) DXFaceView *faceView; //表情view
@end

@implementation VHMessageToolView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, VHScreenHeight , VHScreenWidth, [VHMessageToolView defaultHeight])];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < [VHMessageToolView defaultHeight]) {
        frame.size.height = [VHMessageToolView defaultHeight];
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConfigure];
        _maxLength = 70;
        self.maxTextInputViewHeight = 68; //输入框最大高度
        return self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.toolBackGroundView.width = self.width;
    CGFloat safeMargin = iPhoneX ? 30 : 0;
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) { //设备右转
        self.emojiButton.frame = CGRectMake(10, 10, 30, 30);
        self.sendButton.frame = CGRectMake(self.frame.size.width - 50 - safeMargin, kVerticalPadding, 50, kInputTextViewMinHeight);
        self.msgTextView.frame = CGRectMake(self.emojiButton.right + 10, kVerticalPadding, self.width - (self.emojiButton.right + 10) - (self.sendButton.width + safeMargin) , self.msgTextView.size.height);
    }else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) { //设备左转
        self.emojiButton.frame = CGRectMake(safeMargin + 10, 10, 30, 30);
        self.sendButton.frame = CGRectMake(self.frame.size.width - 50, kVerticalPadding, 50, kInputTextViewMinHeight);
        self.msgTextView.frame = CGRectMake(self.emojiButton.right + 10, kVerticalPadding, self.width - (self.emojiButton.right + 10) - self.sendButton.width, self.msgTextView.size.height);
    }else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) { //设备竖屏
        self.emojiButton.frame = CGRectMake(10, 10, 30, 30);
        self.sendButton.frame = CGRectMake(self.frame.size.width - 50, kVerticalPadding, 50, kInputTextViewMinHeight);
        self.msgTextView.frame = CGRectMake(self.emojiButton.right + 10, kVerticalPadding, self.width - (self.emojiButton.right + 10) - self.sendButton.width, self.msgTextView.size.height);
    }
    
    [self willShowInputTextViewToHeight:[self getTextViewContentH:self.msgTextView]];
}

- (void)setupConfigure {
    //父视图
    self.toolBackGroundView.frame = CGRectMake(0, 0,self.frame.size.width,[VHMessageToolView defaultHeight]);
    [self addSubview:self.toolBackGroundView];
    
    //表情按钮
    [self.toolBackGroundView addSubview:self.emojiButton];
    //发送按钮
    [self.toolBackGroundView addSubview:self.sendButton];
    
    //输入框
    self.msgTextView.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, self.frame.size.width - 100, kInputTextViewMinHeight);
    [self.toolBackGroundView addSubview:self.msgTextView];
    
    _previousTextViewContentHeight = [self getTextViewContentH:self.msgTextView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)updateFrame {
    self.top = CGFLOAT_MAX;
    self.width = VHScreenWidth;
    [self layoutSubviews];
}

//开始文本输入
- (void)beginTextViewInView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.msgTextView becomeFirstResponder];
    });
}


//是否显示表情键盘
- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
    if(bottomView) {
        self.emojiButton.selected = YES;
    }else {
        self.emojiButton.selected = NO;
        _faceView = nil;
    }
}


//重置聊天框高度
- (void)resetMessageTextHeight
{
    [self willShowInputTextViewToHeight:[self getTextViewContentH:_msgTextView]];;
}

#pragma mark - UI 点击事件
//发送按钮点击
- (void)sendButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
        [self.delegate didSendText:_msgTextView.text];
        self.msgTextView.text = @"";
        [self willShowInputTextViewToHeight:[self getTextViewContentH:self.msgTextView]];;
    }
}

//键盘切换按钮点击
- (void)emojiButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) { //输入表情
        [self willShowBottomView:self.faceView];
        [_msgTextView resignFirstResponder];
    } else { //输入文字
        [_msgTextView becomeFirstResponder];
    }
}

//结束编辑
- (BOOL)endEditing:(BOOL)force;
{
    BOOL endEdit = [super endEditing:YES];
    if(self.activityButtomView) {
        [UIView animateWithDuration:0.25 animations:^{
            self.top = VHScreenHeight;
        } completion:^(BOOL finished) {
            [self willShowBottomView:nil];
        }];
    }
    return endEdit;
}

#pragma mark - DXFaceDelegate
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    if (![self textView:_msgTextView shouldChangeTextInRange:NSMakeRange(_msgTextView.text.length, str.length) replacementText:str]) {
        return;
    }
    NSString *chatText = _msgTextView.text;
    
    if (!isDelete && str.length > 0) {
        _msgTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    } else {
        if (chatText.length >= 2)
        {
            NSInteger toIndex = 0;
            BOOL findSatrFace = NO;
            BOOL findEndFace = NO;
            
            NSString *temp = [chatText substringWithRange:NSMakeRange([chatText length] - 1, 1)];
            if ([temp isEqualToString:@"]"])
            {
                findSatrFace = YES;
            }
            
            for (NSInteger i=[chatText length]-1; i>=0; i--)
            {
                NSString *temp = [chatText substringWithRange:NSMakeRange(i, 1)];
                if([temp isEqualToString:@"["])
                {
                    toIndex = i;
                    findEndFace = YES;
                    break;
                }
            }
            if (findSatrFace && findEndFace)
            {
                _msgTextView.text = [chatText substringToIndex:toIndex];
                return;
            }
        }
        if (chatText.length > 0) {
            _msgTextView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    [self textViewDidChange:_msgTextView];
}

#pragma mark - 键盘事件

//键盘弹出
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    [self willShowBottomView:nil]; //移除表情键盘
    
    CGFloat toHeight = self.toolBackGroundView.height + keyboardHeight;
    [UIView animateWithDuration:duration animations:^{
        self.height = toHeight;
        self.top = VHScreenHeight - self.height;
    } completion:^(BOOL finished) {

    }];
}

//键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    if(self.activityButtomView) { //表情键盘存在
        //切换表情输入
        CGFloat toHeight = self.toolBackGroundView.height + self.activityButtomView.height;
        [UIView animateWithDuration:duration animations:^{
            self.height = toHeight;
            self.top = VHScreenHeight - self.height;
            //添加表情键盘
            self.activityButtomView.top = self.toolBackGroundView.height;
            [self addSubview:self.activityButtomView];
            
        } completion:^(BOOL finished) {

        }];
    }else { //不存在表情键盘
        [UIView animateWithDuration:duration animations:^{
            self.top = VHScreenHeight;
//            NSLog(@"两件事消失：%@",NSStringFromCGRect(self.frame));
        } completion:nil];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isFirstResponder]) {
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.msgTextView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.msgTextView]];
        }
        
        return NO;
    }
    if (textView.text.length >=_maxLength&&text.length>0)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        if ([VHMessageToolView isHaveEmoji:textView.text]) {
            textView.text = [VHMessageToolView disableEmoji:textView.text];
            return;
        }
        if (textView.text.length >_maxLength)
        {
            textView.text = [textView.text substringToIndex:_maxLength];
            [textView.undoManager removeAllActions];
        }
    }
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}


- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
//    NSLog(@"输入文字高度：%f",toHeight);
    if (toHeight < kInputTextViewMinHeight) {
        toHeight = kInputTextViewMinHeight;
    }
    if (toHeight > self.maxTextInputViewHeight) {
        toHeight = self.maxTextInputViewHeight;
    }
    
    if (toHeight != _previousTextViewContentHeight) {
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        self.msgTextView.height += changeHeight;
        self.top -= changeHeight;
        self.toolBackGroundView.height += changeHeight;
        _faceView.top += changeHeight;
    }
    _previousTextViewContentHeight = toHeight;
}

//计算文字高度
- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}


//最小高度（输入框最小高度+上下间距）
+ (CGFloat)defaultHeight
{
    return kInputTextViewMinHeight + kVerticalPadding * 2;
}


+ (BOOL)isHaveEmoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return ![modifiedString isEqualToString:text];
}

+ (NSString *)disableEmoji:(NSString *)text
{
    if(text == nil) return nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    //    @"小明 ‍韓國米思納美品牌創始人"@"黄经纬 ‍太陽熊搬家™️"
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"‍"];
    modifiedString = [[modifiedString componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString: @""];
    return modifiedString;
}

#pragma mark - 懒加载
//表情切换按钮、输入框、发送按钮父视图
- (UIView *)toolBackGroundView
{
    if (!_toolBackGroundView)
    {
        _toolBackGroundView = [[UIView alloc] init];
        _toolBackGroundView.backgroundColor = MakeColorRGB(0xf3f4f6);
    }
    return _toolBackGroundView;
}

//输入框视图
- (VHMessageTextView *)msgTextView
{
    if (!_msgTextView)
    {
        _msgTextView = [[VHMessageTextView alloc] init];
        _msgTextView.scrollEnabled = YES;
        _msgTextView.returnKeyType = UIReturnKeySend;
        _msgTextView.enablesReturnKeyAutomatically = YES;
        _msgTextView.backgroundColor = [UIColor whiteColor];
        _msgTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _msgTextView.layer.borderWidth = 0.65f;
        _msgTextView.layer.cornerRadius = 6.0f;
        _msgTextView.delegate = self;
    }
    return _msgTextView;
}

//发送按钮
- (UIButton *)sendButton
{
    if (!_sendButton)
    {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton addTarget:self action:@selector(sendButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setTitleColor:MessageTool_SendBtnColor forState:UIControlStateNormal];
    }
    return _sendButton;
}

//表情切换按钮
- (UIButton *)emojiButton
{
    if (!_emojiButton)
    {
        _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiButton setBackgroundImage: BundleUIImage(@"message_emoji") forState:UIControlStateNormal];
        [_emojiButton setBackgroundImage: BundleUIImage(@"live_keyboard") forState:UIControlStateSelected];
        [_emojiButton addTarget:self action:@selector(emojiButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

//表情键盘view
-(DXFaceView *)faceView
{
    if(!_faceView) {
        _faceView = [[DXFaceView alloc] initWithFrame:CGRectMake(0, ([VHMessageToolView defaultHeight]), self.frame.size.width, 170)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor lightGrayColor];
    }
    return _faceView;
}
@end
