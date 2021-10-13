//
//  VHLiveDocContentView.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveDocContentView.h"
#import <VHInteractive/VHRoom.h>

@interface VHLiveDocContentView ()
/** 返回按钮 */
@property (nonatomic, strong) UIButton *backBtn;
/** 无文档空视图 */
@property (nonatomic, strong) UIView *emptyView;
/** 无文档空视图icon */
@property (nonatomic, strong) UIImageView *emptyImgView;
/** 文档是否显示 */
@property (nonatomic, assign) BOOL docShow;
@end

@implementation VHLiveDocContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        [self addGestureRecognizer];
    }
    return self;
}


- (void)configUI {
    self.backgroundColor = MakeColorRGB(0x222222);
    [self addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.emptyView);
        make.width.centerX.centerY.equalTo(self);
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        if(VH_KScreenIsLandscape) {
            make.height.equalTo(@(VHScreenHeight));
            make.width.equalTo(@(VHScreenHeight * 16/9.0));
        }else {
            make.height.equalTo(@(VHScreenWidth /(16/9.0)));
            make.width.equalTo(@(VHScreenWidth));
        }
    }];
    
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(36, 36)));
        make.left.equalTo(self).offset((VH_KScreenIsLandscape && iPhoneX) ? 30 : 15);
        make.top.equalTo(self).offset(VH_KStatusBarHeight + 15);
    }];
}

//添加手势：左右滑动翻页
- (void)addGestureRecognizer {
    //右滑手势
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:rightRecognizer];
    //左滑手势
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:leftRecognizer];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if(![self.delegate canSwipe]) {
        return;
    }
    if(![self haveShowDocView]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(docContentView:swipeDirection:)]) {
        [self.delegate docContentView:self swipeDirection:recognizer.direction];
    }
}


//当前是否有文档
- (BOOL)haveShowDocView {
    for(UIView *view in self.contentView.subviews) {
        if([view isKindOfClass:[VHDocumentView class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for(UIView *view in self.contentView.subviews) {
        if([view isKindOfClass:[VHDocumentView class]]) {
            view.frame = self.contentView.bounds;
        }
    }
    
}

//设置文档隐藏/显示
- (void)setDocViewHidden:(BOOL)hidden {
    _docShow = !hidden;
    for(UIView *view in self.contentView.subviews) {
        if([view isKindOfClass:[VHDocumentView class]]) {
            view.hidden = hidden;
        }
    }
}

//添加文档
- (void)addDocumentView:(VHDocumentView *)view {
    view.backgroundColor = MakeColorRGB(0x222222);
    [self layoutIfNeeded];
    view.frame = self.contentView.bounds;
    [self.contentView addSubview:view];
}

//将指定的文档挪到最顶层显示
- (void)bringSubviewToFrontWithDocId:(NSString *)cid {
    for(VHDocumentView *view in self.contentView.subviews) {
        if([view isKindOfClass:[VHDocumentView class]] && [view.cid isEqualToString:cid]) {
            [self.contentView bringSubviewToFront:view];
            view.hidden = !_docShow;
            break;
        }
    }
}

//删除文档
- (void)removeDocumentView:(VHDocumentView *)view {
    [view removeFromSuperview];
}

//返回
- (void)backBtnClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(VHScreenWidth, 0);
    } completion:^(BOOL finished) {
        if([self.delegate respondsToSelector:@selector(docContentViewDisMissComplete:)]) {
            [self.delegate docContentViewDisMissComplete:self];
        }
    }];
}

#pragma mark - 懒加载
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:BundleUIImage(@"icon-backwhite") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.backgroundColor = [UIColor blueColor];
        _backBtn.layer.cornerRadius = 18;
        _backBtn.backgroundColor = MakeColorRGBA(0x000000, 0.3);
    }
    return _backBtn;
}

- (UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyImgView = [[UIImageView alloc] init];
        _emptyImgView.image = BundleUIImage(@"icon-文档为空");
        [_emptyView addSubview:_emptyImgView];
        [_emptyImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_emptyView);
            make.width.equalTo(@(96));
            make.height.equalTo(@(70));
            make.centerX.equalTo(_emptyView);
        }];
        
        _emptyLab = [[UILabel alloc] init];
        _emptyLab.text = @"还没有文档哦，点击右下角添加~";
        _emptyLab.textColor = MakeColorRGB(0x999999);
        _emptyLab.font = FONT_FZZZ(16);
        [_emptyView addSubview:_emptyLab];
        [_emptyLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView);
            make.top.equalTo(_emptyImgView.mas_bottom).offset(8);
            make.bottom.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}


- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}


@end
