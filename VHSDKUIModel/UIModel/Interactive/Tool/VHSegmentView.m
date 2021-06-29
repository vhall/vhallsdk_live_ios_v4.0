//
//  VHSegmentView.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#define VHIndicatorColor MakeColorRGB(0xFC5659)  //指示条颜色
#define TitleSelectColor MakeColorRGB(0x333333)  //标题选中颜色
#define TitleNormalColor MakeColorRGB(0x666666)  //标题未选中颜色
#define TitleFont [UIFont systemFontOfSize:16] //标题字体
#define VHIndicatorHeight 2  //指示条高度

#import "VHSegmentView.h"

@interface VHSegmentView ()
/** 指示标记View */
@property (nonatomic,strong) UIView *indicator;
/** 标签宽度 */
@property (nonatomic,assign) NSInteger itemW;
/** 标签个数 */
@property (nonatomic,strong) NSArray *itemArr;
/** 当前显示的标签 */
@property (nonatomic,assign) NSInteger selectIndex;
/** 当前视图宽度 */
@property (nonatomic,assign) CGFloat width;
/** 分割线 */
@property (nonatomic, strong) UIView *separateLine;
/** 指示条中心约束 */
@property (nonatomic, strong) MASConstraint *indicatorCenter;

@end

@implementation VHSegmentView

//初始化，默认选中第一个
- (instancetype)initWithItems:(NSArray *)array {
    if (self = [super init])
    {
        self.itemArr = array;
        self.selectIndex = 0;
        self.backgroundColor = [UIColor whiteColor];
        [self configUI];
    }
    return self;
}

-(void)setIsShowIndicator:(BOOL)isShowIndicator
{
    _isShowIndicator = isShowIndicator;
    if(!isShowIndicator)
    {
        [self hiddenIndicator];
    }
}

- (void)hiddenIndicator
{
    self.indicator.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.width = frame.size.width;
    
    for (UIView*v in self.subviews) {
        [v removeFromSuperview];
    }
    [self configUI];
}

- (void)configUI
{
    if(_itemArr.count == 0) {
        return;
    }
    NSMutableArray *titleLabs = [NSMutableArray array];
    for (NSInteger i = 0; i < _itemArr.count; i++) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemClick:)];
        UILabel *itemLabel = [[UILabel alloc] init];
        itemLabel.text = self.itemArr[i];
        itemLabel.textColor = i == self.selectIndex ? TitleSelectColor : TitleNormalColor;
        itemLabel.font = TitleFont;
        itemLabel.userInteractionEnabled = YES;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [itemLabel addGestureRecognizer:tap];
        tap.view.tag = i+100;
//        itemLabel.backgroundColor = [UIColor redColor];
        [titleLabs addObject:itemLabel];
        [self addSubview:itemLabel];
        
        if(i == 0) {
            CGFloat lineWidth = [_itemArr[0] sizeWithAttributes:@{NSFontAttributeName:TitleFont}].width;
            UIView *indicator = [[UIView alloc] init];
            indicator.backgroundColor = VHIndicatorColor;
            self.indicator = indicator;
            [self addSubview:indicator];
            [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(itemLabel);
                make.height.equalTo(@(VHIndicatorHeight));
                make.width.equalTo(@(lineWidth));
                self.indicatorCenter = make.centerX.equalTo(itemLabel);
            }];
        }
    }
    
    if(titleLabs.count > 1) {
        [titleLabs mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.equalTo(self);
        }];
        
        [titleLabs mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:40 leadSpacing:30 tailSpacing:30];
    }else {
        [titleLabs[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.centerX.width.equalTo(self);
        }];
    }
    

    _separateLine = [[UIView alloc] init];
    _separateLine.backgroundColor = MakeColorRGB(0xE2E2E2);
    [self addSubview:_separateLine];
    [_separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@(1/VHScreenScale));
    }];
}

//标签点击
- (void)itemClick:(UITapGestureRecognizer *)tap
{
    NSInteger tapIndex = tap.view.tag-100;
    if(self.selectIndex != tapIndex) {
        //改变文字颜色
        [self changeTitleColorWithOldIndex:self.selectIndex newIndex:tapIndex];
        //改变指示条位置
        [self changeIndicatorCenterWithLabel:(UILabel *)tap.view];
        self.clickBlock ? self.clickBlock(tapIndex) : nil;
        self.selectIndex = tapIndex;
    }
}

//改变指示器位置
- (void)changeIndicatorCenterWithLabel:(UILabel *)label {
    [self.indicatorCenter uninstall];
    [self.indicator mas_updateConstraints:^(MASConstraintMaker *make) {
        self.indicatorCenter = make.centerX.equalTo(label);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

 //改变标题颜色
- (void)changeTitleColorWithOldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex {
    UILabel *previousLab = [(UILabel *)self viewWithTag:oldIndex+100];
    previousLab.textColor = TitleNormalColor;
    UILabel *newLab = [(UILabel *)self viewWithTag:newIndex+100];
    newLab.textColor = TitleSelectColor;
}


//通过index变更指示器位置
- (void)setIndicatorViewIndex:(NSInteger)index {
    [self changeTitleColorWithOldIndex:self.selectIndex newIndex:index];
    UILabel *label = [self viewWithTag:index+100];
    [self changeIndicatorCenterWithLabel:label];
    self.selectIndex = index;
}

@end
