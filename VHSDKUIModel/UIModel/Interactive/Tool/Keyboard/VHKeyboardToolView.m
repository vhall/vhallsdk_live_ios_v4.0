//
//  VHKeyboardToolView.m
//  VHVSS
//
//  Created by vhall on 2019/9/16.
//  Copyright © 2019 vhall. All rights reserved.
//
#define InputViewHeight 50 //输入栏高度
#define FaceViewHeight 230 //表情键盘View高度
#define MaxInputLength  140 //最大输入字数
#import "VHKeyboardToolView.h"
#import "VHFaceView.h"
#import "VUITool.h"
#import "NSAttributedString+YYText.h"
@interface VHKeyboardToolView ()<UITextViewDelegate,VHFaceDelegate>

@property (nonatomic, strong) UIButton *keyboardBackView; ///<背景（点击收起键盘）
@property (nonatomic, strong) UIButton *emojiBtn;
/** 表情view */
@property (nonatomic, strong) VHFaceView *faceView;
@end


@implementation VHKeyboardToolView

- (void)dealloc
{
    [self removeKeyboardMonitor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
        [self configFrame];
        self.frame = CGRectMake(0, VHScreenHeight, VHScreenWidth, InputViewHeight);
    }
    return self;
}

- (void)setUpViews {
    self.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.textView];
    [self addSubview:self.sendBtn];
    [self addSubview:self.emojiBtn];
}

- (void)configFrame {
    [_emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(VH_KScreenIsLandscape ? @40 : @10);
        make.size.equalTo(@(CGSizeMake(30, 30)));
        make.centerY.equalTo(self);
    }];
    
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(-12);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(36);
    }];

    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.emojiBtn.mas_right).offset(10);
        make.centerY.equalTo(self);
        make.height.equalTo(@(36));
        make.right.equalTo(self.sendBtn.mas_left).offset(-12);
    }];
}

//表情匹配
+ (NSMutableAttributedString *)processCommentContent:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor {
    //转成可变属性字符串
    NSMutableAttributedString * mAttributedString = [[NSMutableAttributedString alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];//调整行间距
    [paragraphStyle setParagraphSpacing:4];//断落间距
    NSDictionary *attri = [NSDictionary dictionaryWithObjects:@[font,textColor,paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
    [mAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attri]];
    //创建匹配正则表达式的类型描述模板
    NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    //创建匹配对象
    NSError * error;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    //判断
    if (!regularExpression) { //如果匹配规则对象为nil
        NSLog(@"正则创建失败！");
        NSLog(@"error = %@",[error localizedDescription]);
        return nil;
    }else {
        NSArray * resultArray = [regularExpression matchesInString:mAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mAttributedString.string.length)];
        
        //开始遍历 逆序遍历
        for (NSInteger i = resultArray.count - 1; i >= 0; i --) {
            //获取检查结果，里面有range
            NSTextCheckingResult * result = resultArray[i];
            //根据range获取字符串
            NSString *rangeString = [mAttributedString.string substringWithRange:result.range];
            NSString *imageName = @"";
            if (rangeString && rangeString.length) {
                imageName = VHEmojiDic[rangeString];
                if ([imageName isKindOfClass:[NSNumber class]]) {
                    imageName = [NSString stringWithFormat:@"%@",imageName];
                }
            }
            //获取图片
            UIImage * image = BundleUIImage(imageName);
            if (image != nil) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.width = 20;
                imageView.height = 20;
                NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:14] alignment:YYTextVerticalAlignmentCenter];
                //开始替换
                [mAttributedString replaceCharactersInRange:result.range withAttributedString:attachText];
            }
        }
    }
    return mAttributedString;
}

#pragma mark - 键盘监听
- (void)addKeyboardMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardMonitor {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//键盘弹出
- (void)keyboardShow:(NSNotification *)notification
{
    self.hidden = NO;
    self.faceView.hidden = YES;
    self.keyboardBackView.frame = [UIApplication sharedApplication].delegate.window.bounds;
    [self.superview insertSubview:self.keyboardBackView belowSubview:self];
    self.emojiBtn.selected = NO;
    CGFloat keyboradHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows] lastObject];
    Class class = NSClassFromString(@"UIInputSetHostView");
    for (UIView *subview in keyboardWindow.rootViewController.view.subviews) {
        if ([subview isKindOfClass:class]) {
            if (keyboradHeight != subview.frame.size.height) {
                keyboradHeight = subview.frame.size.height;
            }
        }
    }
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]; //动画时间
    [UIView animateWithDuration:duration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT - keyboradHeight - InputViewHeight, SCREEN_WIDTH, InputViewHeight);
    } completion:^(BOOL finished) {
        [self.superview bringSubviewToFront:self];
    }];
}

//键盘收起
- (void)keyboardHidden:(NSNotification *)notification
{
    if(!self.emojiBtn.selected) { //当前处于输入文本
        [self.keyboardBackView removeFromSuperview];
        self.hidden = YES;
        self.frame = CGRectMake(0, VHScreenHeight, VHScreenWidth, InputViewHeight);
    }
}

//点击背景关闭
- (void)keyboardToolViewBackViewClick {
    [self resignFirstResponder];
    if(self.emojiBtn.selected) { //当前处于输入emoji表情
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, VHScreenHeight, VHScreenWidth, InputViewHeight);
            self.faceView.frame = CGRectMake(0, SCREEN_HEIGHT, self.frame.size.width, FaceViewHeight);
        } completion:^(BOOL finished) {
            [self.keyboardBackView removeFromSuperview];
            self.hidden = YES;
            self.faceView.hidden = YES;
            self.faceView.frame = CGRectMake(0, SCREEN_HEIGHT - FaceViewHeight, self.frame.size.width, FaceViewHeight);
        }];
    }
}


- (void)becomeFirstResponder {
    [self addKeyboardMonitor];
    [self.textView becomeFirstResponder];
}

- (void)resignFirstResponder {
    [self.textView resignFirstResponder];
    [self removeKeyboardMonitor];
}


- (void)clearText {
    self.textView.text = nil;
}

//显示表情键盘
- (void)showFaceView {
    self.faceView.hidden = NO;
    [self.superview bringSubviewToFront:self.faceView];
    self.frame = CGRectMake(0, SCREEN_HEIGHT - FaceViewHeight - InputViewHeight, VHScreenWidth, InputViewHeight);
}


#pragma mark - UI事件
//发送
- (void)sendBtnClick:(UIButton *)sender {
    NSString *text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除首尾空格和换行
    NSString *tempSelf = text;
    while ([tempSelf containsString:@"\r\r"] || [tempSelf containsString:@"\n\n"] || [tempSelf containsString:@"\n\r"] || [tempSelf containsString:@"\r\n"]) {//去除连续两个换行
        tempSelf = [tempSelf stringByReplacingOccurrencesOfString:@"\r\r" withString:@"\r"];
        tempSelf = [tempSelf stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        tempSelf = [tempSelf stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
        tempSelf = [tempSelf stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
    }
    text = tempSelf; //替换连续两个换行为一个
    
    if(VH_EmptyStr(text)) {
        VH_ShowToast(@"请输入内容");
        return;
    }

    if (text && [self.delegate respondsToSelector:@selector(keyboardToolView:sendText:)]) {
        [self.delegate keyboardToolView:self sendText:text];
        self.textView.text = @"";
        //收起键盘
        [self keyboardToolViewBackViewClick];
    }
}

//点击表情键盘
- (void)emojiBtnClick:(UIButton *)emojiBtn {
    emojiBtn.selected = !emojiBtn.selected;
    if(emojiBtn.selected) {
        [self.textView resignFirstResponder];
        [self showFaceView];
    }else {
        [self.textView becomeFirstResponder];
    }
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _isEditing = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _isEditing = NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
//    if (textView.text && textView.text.length) {
//        self.sendBtn.enabled = YES;
//        self.sendBtn.backgroundColor = KMainColor;
//    }else {
//        self.sendBtn.enabled = NO;
//        self.sendBtn.backgroundColor = [UIColor lightGrayColor];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendBtnClick:self.sendBtn];
        return NO;
    }
    
    if([VUITool hasEmoji:text]) { //屏蔽第三方键盘表情
        return NO;
    }
    
    if ([textView isFirstResponder]) {//屏蔽系统表情
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - VHFaceDelegate
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete {
    if (![self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length, str.length) replacementText:str]) {
        return;
    }
    NSString *chatText = self.textView.text;
    if (!isDelete && str.length > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    }else {
        if (chatText.length >= 2) {
            NSInteger toIndex = 0;
            BOOL findStartFace = NO;
            BOOL findEndFace = NO;
            
            NSString *temp = [chatText substringWithRange:NSMakeRange([chatText length] - 1, 1)];
            if ([temp isEqualToString:@"]"]) {
                findStartFace = YES;
            }
            
            for (NSInteger i=[chatText length]-1; i>=0; i--) {
                NSString *temp = [chatText substringWithRange:NSMakeRange(i, 1)];
                if([temp isEqualToString:@"["])
                {
                    toIndex = i;
                    findEndFace = YES;
                    break;
                }
            }
            
            if (findStartFace && findEndFace) {
                _textView.text = [chatText substringToIndex:toIndex];
                return;
            }
        }
        
        if (chatText.length > 0) {
            _textView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    [self textViewDidChange:_textView];
}

- (VHFaceView *)faceView
{
    if (!_faceView)
    {
        _faceView = [[VHFaceView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - FaceViewHeight, self.frame.size.width, FaceViewHeight)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor whiteColor];
        _faceView.hidden = YES;
        [self.superview addSubview:_faceView];
    }
    return _faceView;
}

- (UIButton *)keyboardBackView {
    if (!_keyboardBackView) {
        _keyboardBackView = [UIButton buttonWithType:UIButtonTypeCustom];
        _keyboardBackView.backgroundColor = [UIColor clearColor];
        [_keyboardBackView addTarget:self action:@selector(keyboardToolViewBackViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardBackView;
}

- (UIButton *)emojiBtn
{
    if (!_emojiBtn)
    {
        _emojiBtn = [[UIButton alloc] init];
        [_emojiBtn setImage:BundleUIImage(@"icon_笑脸") forState:UIControlStateNormal];
        [_emojiBtn setImage:BundleUIImage(@"icon_键盘") forState:UIControlStateSelected];
        [_emojiBtn addTarget:self action:@selector(emojiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}

- (UIButton *)sendBtn
{
    if (!_sendBtn)
    {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _sendBtn.layer.cornerRadius = 18;
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.backgroundColor = MakeColorRGBA(0xFC5659,0.8);
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (QMUITextView *)textView
{
    if (!_textView)
    {
        _textView = [[QMUITextView alloc] init];
        _textView.textColor = MakeColorRGB(0x22222);
        _textView.font = FONT_FZZZ(14);
        _textView.placeholder = @"说点什么吧";
        _textView.placeholderColor = MakeColorRGB(0x999999);
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.layer.cornerRadius = 18;
        _textView.backgroundColor = MakeColorRGB(0xF7F7F7);
        _textView.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12);;
        _textView.maximumTextLength = MaxInputLength;
    }
    return _textView;
}
@end
