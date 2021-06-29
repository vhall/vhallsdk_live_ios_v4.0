//
//  VHCBaseActionView.m
//  VHCUICore
//
//  Created by 郭超 on 2020/11/21.
//

#import "VHCBaseActionView.h"
//#import "VUIBaseCore.h"
@implementation VHCBaseActionView

- (void)dealloc
{
    VHLog(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}
- (instancetype)initWithFrame:(CGRect)frame popViewLength:(CGFloat)popViewLength
{
    if ([super initWithFrame:frame]) {
        self.popViewLength = popViewLength;
        [self setupUI];
    }return self;
}
- (void)setupUI {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@(self.popViewLength));
    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touches.anyObject locationInView:self];
    if(!CGRectContainsPoint(self.contentView.frame, touchPoint)){
        [self dismiss];
    }
}

//显示
- (void)showInView:(UIView *)view {
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    self.contentView.transform = VH_KScreenIsLandscape ? CGAffineTransformMakeTranslation(self.popViewLength, 0) : CGAffineTransformMakeTranslation(0, self.popViewLength);
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
        if(self.showBlock){
            self.showBlock();
        }
    }];
}

//移除
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.contentView.transform = VH_KScreenIsLandscape ? CGAffineTransformMakeTranslation(self.popViewLength, 0) : CGAffineTransformMakeTranslation(0, self.popViewLength);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.disMissBlock){
            self.disMissBlock();
        }
    }];
}


@end
