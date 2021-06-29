//
//  VHEndPublisherCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/30.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHEndPublisherCell.h"

@interface VHEndPublisherCell ()
/// 值
@property (nonatomic , strong) UILabel * numLab;
/// 标题
@property (nonatomic , strong) UILabel * titleLab;

@end

@implementation VHEndPublisherCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 30;
        
        self.contentView.layer.borderColor = MakeColorRGBA(0xFFFFFF, 0.4).CGColor;
        self.contentView.layer.borderWidth = .5;
        
        [self.contentView addSubview:self.titleLab];
        
        [self.contentView addSubview:self.numLab];
        
        [self setupUI];
    }
    
    return self;
}

#pragma mark - 懒加载
- (UILabel *)numLab
{
    if (!_numLab) {
        _numLab = [UILabel new];
        _numLab.text = @"2:10:35";
        _numLab.font = FONT_Medium(20);
        _numLab.textColor = MakeColorRGB(0xFFFFFF);
        _numLab.textAlignment = NSTextAlignmentCenter;
    }return _numLab;
}
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.text = @"直播时长";
        _titleLab.font = FONT_FZZZ(13);
        _titleLab.textColor = MakeColorRGB(0xAAAAAA);
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }return _titleLab;
}

#pragma mark --- 初始化控件
- (void)setupUI
{
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(8);
    }];

    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-6);
    }];
}

- (void)setModel:(VHEndPublisherCellModel *)model {
    _model = model;
    self.titleLab.text = model.title;
    self.numLab.text = model.titleValue;
}

@end

@implementation VHEndPublisherCellModel

@end

