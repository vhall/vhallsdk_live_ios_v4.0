//
//  VHLiveDocListCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveDocListCell.h"
#import "VHDocListModel.h"

@interface VHLiveDocListCell ()
/** 文件类型图标 */
@property (nonatomic, strong) UIImageView *typeImgView;
/** 文件名 */
@property (nonatomic, strong) UILabel *titleLab;
/** 勾选框 */
@property (nonatomic, strong) UIButton *selectIcon;
/** 时间+大小 */
@property (nonatomic, strong) UILabel *subLab;
/** 分割线 */
@property (nonatomic, strong) UIView *lineView;
@end

@implementation VHLiveDocListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.typeImgView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.subLab];
    [self.contentView addSubview:self.selectIcon];
    [self.contentView addSubview:self.lineView];
    
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(31, 31)));
        make.left.equalTo(@15);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(20, 20)));
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeImgView.mas_right).offset(12);
        make.top.equalTo(@15);
        make.right.equalTo(self.selectIcon.mas_left).offset(-17);
    }];
    
    [self.subLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLab);
        make.top.equalTo(self.titleLab.mas_bottom).offset(4);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(1/VHScreenScale));
    }];
}

//doc/docx：word图标
//xls/xlsx：Excel图标
//ppt，pptx：PPT图标
//pdf：PDF图标
//jpeg，jpg，png，bmp：图片图标
- (void)setModel:(VHDocListModel *)model {
    _model = model;
    NSString *imageName = @"";
    if([model.ext containsString:@"doc"]) {
        imageName = @"icon-word";
    }else if ([model.ext containsString:@"xls"]) {
        imageName = @"icon-xlsx";
    }else if ([model.ext containsString:@"ppt"]) {
        imageName = @"icon-ppt";
    }else if ([model.ext containsString:@"pdf"]) {
        imageName = @"icon-pdf";
    }else if ([model.ext isEqualToString:@"jpeg"] || [model.ext isEqualToString:@"jpg"] || [model.ext isEqualToString:@"png"] || [model.ext isEqualToString:@"bmp"]) {
        imageName = @"icon-jpg";
    }
    self.typeImgView.image = BundleUIImage(imageName);
    
    self.titleLab.text = model.file_name;
    
    self.subLab.text = [NSString stringWithFormat:@"%@ %.2fM",model.created_at,model.size/(1024*1024.0)];
    self.selectIcon.selected = model.selected;
    self.contentView.backgroundColor = model.selected ? MakeColorRGB(0xEFF6FE) : [UIColor whiteColor];
}

#pragma mark - lazyload
- (UIImageView *)typeImgView
{
    if (!_typeImgView)
    {
        _typeImgView = [[UIImageView alloc] init];
        _typeImgView.contentMode = UIViewContentModeCenter;
    }
    return _typeImgView;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = MakeColorRGB(0x333333);
        _titleLab.font = FONT_Medium(16);
    }
    return _titleLab;
}

- (UILabel *)subLab
{
    if (!_subLab)
    {
        _subLab = [[UILabel alloc] init];
        _subLab.textColor = MakeColorRGB(0x999999);
        _subLab.font = FONT_FZZZ(14);
    }
    return _subLab;
}

- (UIButton *)selectIcon
{
    if (!_selectIcon)
    {
        _selectIcon = [[UIButton alloc] init];
        [_selectIcon setImage:BundleUIImage(@"icon-circle") forState:UIControlStateNormal];
        [_selectIcon setImage:BundleUIImage(@"icon-circle hover") forState:UIControlStateSelected];
        _selectIcon.userInteractionEnabled = NO;
    }
    return _selectIcon;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = MakeColorRGB(0xDDDDDD);
    }
    return _lineView;
}

@end
