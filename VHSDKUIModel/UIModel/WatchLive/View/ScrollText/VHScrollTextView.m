//
//  VHScrollTextView.m
//  UIModel
//
//  Created by xiongchao on 2021/4/8.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHScrollTextView.h"
#import "VHLiveWeakTimer.h"
#import "Masonry.h"
#import <VHLiveSDK/VHallApi.h>
@interface VHScrollTextView ()
@property (nonatomic, strong) UILabel *scrollLabel;
@property (nonatomic, strong) VHWebinarScrollTextInfo *scrollTextInfo;     ///<跑马灯模型
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation VHScrollTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

///展示文字跑马灯
- (void)showScrollTextWithModel:(VHWebinarScrollTextInfo *)model {
    self.scrollTextInfo = model;
    if(model.scrolling_open == 0) {
        return;
    }
    
    BOOL repeats = model.interval > 0 ? YES : NO;
    self.timer = [VHLiveWeakTimer scheduledTimerWithTimeInterval:model.interval target:self selector:@selector(scrollAnimation) userInfo:nil repeats:repeats];
}

//文字滚动动画
- (void)scrollAnimation {
    UILabel *scrollLab = [[UILabel alloc] init];
    [self addSubview:scrollLab];
    scrollLab.alpha = self.scrollTextInfo.alpha / 100.0;
    scrollLab.font = [UIFont systemFontOfSize:self.scrollTextInfo.size];
    scrollLab.textColor = [UIModelTools colorWithHexString:self.scrollTextInfo.color];
    
    if(self.scrollTextInfo.text_type == 1) {
        scrollLab.text = self.scrollTextInfo.text;
    }else if (self.scrollTextInfo.text_type == 2) {
        scrollLab.text = [NSString stringWithFormat:@"%@-%@-%@",self.scrollTextInfo.text,[VHallApi currentUserID],[VHallApi currentUserNickName]];
    }
    CGSize labelSize = [scrollLab sizeThatFits:CGSizeZero];
    [self.superview layoutIfNeeded];
    
    [scrollLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_right);
        make.size.equalTo(@(labelSize));
        if(self.scrollTextInfo.position == 1) { //随机
            int random = arc4random() % 101;
            CGFloat top = (self.size.height - labelSize.height) * random / 100.0;
            make.top.equalTo(@(top));
        }else if (self.scrollTextInfo.position == 2) { //上
            make.top.equalTo(@(40));
        }else if (self.scrollTextInfo.position == 3) { //中
            make.centerY.equalTo(self);
        }else if (self.scrollTextInfo.position == 4) { //下
            make.bottom.equalTo(self).offset(-40);
        }
    }];
    
    NSTimeInterval second = self.scrollTextInfo.speed / 1000.0;
    
    [UIView animateWithDuration:second delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        scrollLab.transform = CGAffineTransformMakeTranslation(-(self.size.width + labelSize.width), 0);
    } completion:^(BOOL finished) {
        [scrollLab removeFromSuperview];
    }];
}

//停止跑马灯
- (void)stopScrollText {
    [self.timer invalidate];
    self.timer = nil;
}


@end
