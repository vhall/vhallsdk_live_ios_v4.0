
//
//  WatchLiveLotteryWriteWinInfoView.m
//  UIModel
//
//  Created by xiongchao on 2020/9/9.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "WatchLiveLotteryWriteWinInfoView.h"
#import "Masonry.h"
@interface WatchLiveLotteryWriteWinInfoView () <UITextFieldDelegate>
/** 标题 */
@property (nonatomic, strong) UILabel *titleLab;
/** 提交按钮 */
@property (nonatomic, strong) UIButton *submitBtn;
/** 输入框父视图 */
@property (nonatomic, strong) UIScrollView *scrollView;
/** 当前激活的输入框 */
@property (nonatomic, strong) UITextField *currentInputTextF;
@end

@implementation WatchLiveLotteryWriteWinInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleLab];
    [self addSubview:self.submitBtn];
    [self addSubview:self.scrollView];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(30);
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-25);
        make.size.equalTo(@(CGSizeMake(180, 45)));
        make.centerX.equalTo(self);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(10);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.submitBtn.mas_top).offset(-20);
    }];
}

- (void)setSubmitConfigArr:(NSArray <VHallLotterySubmitConfig *>*)submitConfigArr {
    _submitConfigArr = submitConfigArr;
    UITextField *tempTextField;
    for(int i = 0 ; i < submitConfigArr.count ; i++) {
        VHallLotterySubmitConfig *model = submitConfigArr[i];
        UITextField *textField = [[UITextField alloc] init];
        textField.delegate = self;
        textField.placeholder = model.placeholder;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.tag = 100 + i;
        textField.font = [UIFont systemFontOfSize:14];
        [self.scrollView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(30);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(50);
            if(i == 0) {
                make.top.equalTo(self.scrollView);
                make.left.right.equalTo(self.scrollView);
            }else {
                make.top.equalTo(tempTextField.mas_bottom).offset(15);
            }
            if(i == submitConfigArr.count -1) {
                make.bottom.equalTo(self.scrollView);
            }
        }];
        
        tempTextField = textField;
        //是否必填
        UILabel *requiredLab = [[UILabel alloc] init];
        requiredLab.text = @"*";
        requiredLab.textColor = MakeColorRGB(0xFC5659);
        requiredLab.hidden = model.is_required != 1;
        [self.scrollView addSubview:requiredLab];
        [requiredLab mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self).offset(15);
           make.centerY.equalTo(textField);
        }];
//        //标题
//        UILabel *titleLab = [[UILabel alloc] init];
//        titleLab.userInteractionEnabled = NO;
//        titleLab.text = model.field;
//        titleLab.font = [UIFont systemFontOfSize:14];
//        titleLab.adjustsFontSizeToFitWidth = YES;
//        [self.scrollView addSubview:titleLab];
//        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(30);
//            make.centerY.equalTo(textField);
//            make.right.equalTo(textField.mas_left).offset(-10);
//        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

//提交
- (void)submitBtnClick:(UIButton *)submitBtn {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    for(int i = 0 ; i < self.submitConfigArr.count ; i++) {
        VHallLotterySubmitConfig *model = self.submitConfigArr[i];
        UITextField *textField = [self.scrollView viewWithTag:100+i];
        
        if(model.is_required && textField.text.length == 0) { //判断必填项
            [UIModelTools showMsg:@"必填项不能为空" afterDelay:2];
            return;
        }
        
        [param setValue:textField.text forKey:model.field_key];
    }

    if([self.delegate respondsToSelector:@selector(writeWinInfoView:submitWinInfo:)]) {
        [self.delegate writeWinInfoView:self submitWinInfo:param];
    }
}

#pragma mark - 键盘
//键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect textFRect = [self.scrollView convertRect:self.currentInputTextF.frame toView:[UIApplication sharedApplication].keyWindow];
    CGFloat differ = textFRect.origin.y + textFRect.size.height - keyboardFrame.origin.y;
    if(differ > 0) {
        [UIView animateWithDuration:duration animations:^{
            [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformMakeTranslation(0, -differ);
        }];
    }
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentInputTextF = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"请填写您的领奖信息，方便主办方与您联系。";
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = MakeColorRGB(0x222222);
    }
    return _titleLab;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn)
    {
        _submitBtn = [[UIButton alloc] init];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _submitBtn.backgroundColor = MakeColorRGB(0xFC5659);
        _submitBtn.layer.cornerRadius = 7;
        _submitBtn.layer.masksToBounds = YES;
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}


@end

