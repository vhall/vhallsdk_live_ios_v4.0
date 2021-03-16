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
@property (strong, nonatomic) UIView *inputToolView; //表情切换按钮、输入框、发送按钮父视图
@property (strong, nonatomic) DXFaceView *faceView; //表情view
@property (nonatomic, strong) UIButton *endEditBtnView;     ///<透明背景按钮view，用来点击结束输入
@property (nonatomic,strong) UIView *activityButtomView; //当前底部表情键盘view
@end

@implementation VHMessageToolView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, VHScreenWidth, VHScreenHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConfigure];
        return self;
    }
    return self;
}


- (void)setupConfigure {
    _maxLength = 70;
    self.maxTextInputViewHeight = 68; //输入框最大高度
    
    self.backgroundColor = [UIColor clearColor];
    //透明按钮，点击移除键盘
    [self addSubview:self.endEditBtnView];
    //输入框背景view
    [self addSubview:self.inputToolView];
    //表情按钮
    [self.inputToolView addSubview:self.emojiButton];
    //发送按钮
    [self.inputToolView addSubview:self.sendButton];
    //输入框
    [self.inputToolView addSubview:self.msgTextView];
    
    self.inputToolView.frame = CGRectMake(0, self.height ,self.width,[VHMessageToolView defaultHeight]);
    self.msgTextView.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, self.frame.size.width - 100, kInputTextViewMinHeight);
    
    _previousTextViewContentHeight = [self getTextViewContentH:self.msgTextView];
    
    [self updateFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //监听屏幕旋转状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)updateFrame {
    self.frame = CGRectMake(0, 0, VHScreenWidth, VHScreenHeight);
    self.endEditBtnView.frame = self.bounds;
    self.inputToolView.width = self.width;
    self.inputToolView.top = self.height;
    
    if(_activityButtomView) { //表情键盘
        [self willShowBottomView:nil];
        self.hidden = YES;
    }
    
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
    
    [self resetMessageTextHeight];
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
    if (![_activityButtomView isEqual:bottomView]) {
        
        if (_activityButtomView) {
            [_activityButtomView removeFromSuperview];
        }
        _activityButtomView = bottomView;
    }
    if(bottomView) {
        [self addSubview:_activityButtomView];
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

//屏幕旋转
- (void)statusBarOrientationChanged:(NSNotification *)notify{
    [self updateFrame];
}

#pragma mark - UI 点击事件
//发送按钮点击
- (void)sendButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
        [self.delegate didSendText:_msgTextView.text];
        self.msgTextView.text = @"";
        [self resetMessageTextHeight];
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
    if(_activityButtomView) {
        [UIView animateWithDuration:0.25 animations:^{
            self.inputToolView.top = VHScreenHeight;
            self.activityButtomView.top = self.inputToolView.top + self.inputToolView.height;
        } completion:^(BOOL finished) {
            [self willShowBottomView:nil];
            self.hidden = YES;
        }];
    }
    return endEdit;
}

- (void)endEditBtnViewClick {
    [self endEditing:YES];
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
    if(!self.msgTextView.isFirstResponder) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.hidden = NO;
    [self willShowBottomView:nil]; //移除表情键盘
    CGFloat height = (self.inputToolView.height + keyboardHeight);
    [UIView animateWithDuration:duration animations:^{

        self.inputToolView.top = self.height - height;
    } completion:nil];
}

//键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    if(!self.msgTextView.isFirstResponder) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    if(self.activityButtomView) { //表情键盘存在

        CGFloat height = self.inputToolView.height + self.activityButtomView.height;
        
        [UIView animateWithDuration:duration animations:^{
            
            self.inputToolView.top = self.height - height;
            self.activityButtomView.top = self.inputToolView.top + self.inputToolView.height;
            
        } completion:nil];
        
    }else { //不存在表情键盘
        [UIView animateWithDuration:duration animations:^{
            self.inputToolView.top = self.height;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
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
            [self resetMessageTextHeight];
        }
        
        return NO;
    }
    if (textView.text.length >=_maxLength && text.length>0)
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
        NSRange bottom = NSMakeRange(self.msgTextView.text.length -1, 1);
        [self.msgTextView scrollRangeToVisible:bottom];
    }
    [self resetMessageTextHeight];
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
        self.inputToolView.height += changeHeight;
        self.inputToolView.top -= changeHeight;
    }
    _previousTextViewContentHeight = toHeight;
}

//计算文字高度
- (CGFloat)getTextViewContentH:(UITextView *)textView {
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
- (UIView *)inputToolView
{
    if (!_inputToolView)
    {
        _inputToolView = [[UIView alloc] init];
        _inputToolView.backgroundColor = MakeColorRGB(0xf3f4f6);
    }
    return _inputToolView;
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
        [_sendButton setTitleColor:MakeColor(34, 34, 34, 1) forState:UIControlStateNormal];
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
        _faceView = [[DXFaceView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 170, self.frame.size.width, 170)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor lightGrayColor];
    }
    return _faceView;
}

- (UIButton *)endEditBtnView
{
    if (!_endEditBtnView)
    {
        _endEditBtnView = [[UIButton alloc] init];
        _endEditBtnView.backgroundColor = [UIColor clearColor];
        [_endEditBtnView addTarget:self action:@selector(endEditBtnViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endEditBtnView;
}
@end
