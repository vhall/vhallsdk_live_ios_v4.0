//
//  VHDocBrushPopView.m
//  UIModel
//
//  Created by leiheng on 2021/4/22.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHDocBrushPopView.h"

@interface VHDocBrushPopView () <VHDocBrushSelectViewDelegate>
/** 画笔模式选择 */
@property (nonatomic, strong) VHDocBrushSelectView *functionSelectView;
/** 画笔粗细、颜色、形状选择 */
@property (nonatomic, strong) VHDocBrushSelectView *subSelectView;
/** 粗细 */
@property (nonatomic, strong) NSMutableArray <VHDocBrushItemModel *> *lineModels;
/** 颜色 */
@property (nonatomic, strong) NSMutableArray <VHDocBrushItemModel *> *colorModels;
/** 形状 */
@property (nonatomic, strong) NSMutableArray <VHDocBrushItemModel *> *shapeModels;
/** 功能 */
@property (nonatomic, strong) NSMutableArray <VHDocBrushItemModel *> *functionModels;

@property (nonatomic, weak) id<VHDocBrushPopViewDelegate> delegate;
/** 当前选择的颜色 */
@property (nonatomic, strong) UIColor *currentSelectColor;
/** 当前选择画笔粗细 */
@property (nonatomic, assign) NSInteger currentSelectSize;
/** 当前选择的画笔图形 */
@property (nonatomic, assign) VHDrawType currentSelectShape;

@end

@implementation VHDocBrushPopView

- (void)dealloc
{
    VUI_Log(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (instancetype)initWithDelegate:(id<VHDocBrushPopViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        [self configUI];
        [self defaultSelect];
    }
    return self;
}

- (void)configUI {
//    self.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.functionSelectView];
    [self addSubview:self.subSelectView];
    
    [self.subSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.height.equalTo(self.subSelectView);
        make.right.equalTo(self.functionSelectView.mas_left).offset(-8);
    }];
    [self.functionSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.height.equalTo(self.functionSelectView);
    }];
}

//是否开启画笔弹窗
- (void)showPopView:(BOOL)show {
    if(show) {
        self.hidden = NO;
        self.subSelectView.hidden = YES;
    }else {
        self.hidden = YES;
    }
}


- (void)defaultSelect {
    //默认处于形状选择
    [self brushSelectView:self.functionSelectView selectTag:VHBrushFunctionShape];
    //默认画线
    if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
        self.currentSelectShape = VHDrawType_Pen;
        [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
    }
    //默认画笔粗细
    if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
        self.currentSelectSize = 25;
        [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
    }
    //默认画笔颜色
    if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
        self.currentSelectColor = MakeColorRGB(0x3478F6);
        [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
    }
}

#pragma mark - VHDocBrushSelectViewDelegate
- (void)brushSelectView:(VHDocBrushSelectView *)view selectTag:(NSInteger)tag {
    if(tag >= VHBrushFunctionTrash && tag <= VHBrushFunctionShape) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushFunction:)]) {
            [self.delegate brushPopView:self selectBrushFunction:tag];
        }
    }
    //功能选择
    if(tag == VHBrushFunctionTrash) { //垃圾桶
        self.subSelectView.hidden = YES;
    }else if (tag == VHBrushFunctionLine) { //线条
        self.subSelectView.models = self.lineModels;
        self.subSelectView.hidden = NO;
    }else if (tag == VHBrushFunctionRubber) { //橡皮檫
        self.subSelectView.hidden = YES;
    }else if (tag == VHBrushFunctionColor) { //颜色
        self.subSelectView.models = self.colorModels;
        self.subSelectView.hidden = NO;
    }else if (tag == VHBrushFunctionShape) { //形状
        self.subSelectView.models = self.shapeModels;
        self.subSelectView.hidden = NO;
    }
    //线条粗细选择
    else if (tag == VHBrushLine1) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
            self.currentSelectSize = 25;
            [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
        }
    }else if (tag == VHBrushLine2) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
            self.currentSelectSize = 20;
            [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
        }
    }else if (tag == VHBrushLine3) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
            self.currentSelectSize = 15;
            [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
        }
    }else if (tag == VHBrushLine4) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
            self.currentSelectSize = 10;
            [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
        }
    }else if (tag == VHBrushLine5) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushSize:)]) {
            self.currentSelectSize = 5;
            [self.delegate brushPopView:self selectBrushSize:self.currentSelectSize];
        }
    }
    //颜色选择
    else if (tag == VHBrushColorBlue) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
            self.currentSelectColor = MakeColorRGB(0x3478F6);
            [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
        }
    }else if (tag == VHBrushColorGreen) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
            self.currentSelectColor = MakeColorRGB(0x83D754);
            [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
        }
    }else if (tag == VHBrushColorOrange) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
            self.currentSelectColor = MakeColorRGB(0xF09A37);
            [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
        }
    }else if (tag == VHBrushColorRed) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
            self.currentSelectColor = MakeColorRGB(0xDF382C);
            [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
        }
    }else if (tag == VHBrushColorWhite) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushColor:)]) {
            self.currentSelectColor = MakeColorRGB(0xFFFFFF);
            [self.delegate brushPopView:self selectBrushColor:self.currentSelectColor];
        }
    }
    //形状选择
    else if (tag == VHBrushShapeDoubleArrow) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
            self.currentSelectShape = VHDrawType_Double_Arrow;
            [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
        }
    }else if (tag == VHBrushShapeSingleArrow) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
            self.currentSelectShape = VHDrawType_Single_Arrow;
            [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
        }
    }else if (tag == VHBrushShapeLine) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
            self.currentSelectShape = VHDrawType_Pen;
            [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
        }
    }else if (tag == VHBrushColorRound) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
            self.currentSelectShape = VHDrawType_Circle;
            [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
        }
    }else if (tag == VHBrushColorSquare) {
        if([self.delegate respondsToSelector:@selector(brushPopView:selectBrushShape:)]) {
            self.currentSelectShape = VHDrawType_Rectangle;
            [self.delegate brushPopView:self selectBrushShape:self.currentSelectShape];
        }
    }
}

- (VHDocBrushSelectView *)functionSelectView
{
    if (!_functionSelectView)
    {
        _functionSelectView = [[VHDocBrushSelectView alloc] initWithModels:self.functionModels];
        _functionSelectView.delegate = self;
    }
    return _functionSelectView;
}

- (VHDocBrushSelectView *)subSelectView
{
    if (!_subSelectView)
    {
        _subSelectView = [[VHDocBrushSelectView alloc] init];
        _subSelectView.delegate = self;
    }
    return _subSelectView;
}

- (NSMutableArray<VHDocBrushItemModel *> *)functionModels
{
    if (!_functionModels)
    {
        _functionModels = [NSMutableArray array];
        NSArray *imageNames = @[@"icon-文档-trash",@"icon-文档-线条",@"icon-文档-橡皮擦",@"icon-文档-色版",@"icon-文档-图形"];
        for(int i = 0 ; i < 5 ; i ++) {
            VHDocBrushItemModel *model = [[VHDocBrushItemModel alloc] init];
            model.normalImgName = imageNames[i];
            model.tag = VHBrushFunctionTrash + i;
            [_functionModels addObject:model];
        }
    }
    return _functionModels;
}

- (NSMutableArray<VHDocBrushItemModel *> *)lineModels
{
    if (!_lineModels)
    {
        _lineModels = [NSMutableArray array];
        for(int i = 0 ; i < 5 ; i ++) {
            VHDocBrushItemModel *model = [[VHDocBrushItemModel alloc] init];
            model.normalImgName = [NSString stringWithFormat:@"icon-文档-线%d",5-i];
            model.tag = VHBrushLine1 + i;
            if(model.tag == VHBrushLine1) {
                model.isSelect = YES;
            }
            [_lineModels addObject:model];
        }
    }
    return _lineModels;
}

- (NSMutableArray<VHDocBrushItemModel *> *)colorModels
{
    if (!_colorModels)
    {
        _colorModels = [NSMutableArray array];
        NSArray *imageNames = @[@"icon-文档-颜色蓝",@"icon-文档-颜色绿",@"icon-文档-颜色橙",@"icon-文档-颜色红",@"icon-文档-颜色白"];
        for(int i = 0 ; i < 5 ; i ++) {
            VHDocBrushItemModel *model = [[VHDocBrushItemModel alloc] init];
            model.normalImgName = imageNames[i];
            model.tag = VHBrushColorBlue + i;
            if(model.tag == VHBrushColorBlue) {
                model.isSelect = YES;
            }
            [_colorModels addObject:model];
        }
    }
    return _colorModels;
}


- (NSMutableArray<VHDocBrushItemModel *> *)shapeModels
{
    if (!_shapeModels)
    {
        _shapeModels = [NSMutableArray array];
        NSArray *imageNames = @[@"icon-文档-双箭头",@"icon-文档-单箭头",@"icon-文档-单线条",@"icon-文档-圆",@"icon-文档-正方形"];
        for(int i = 0 ; i < 5 ; i ++) {
            VHDocBrushItemModel *model = [[VHDocBrushItemModel alloc] init];
            model.normalImgName = imageNames[i];
            model.tag = VHBrushShapeDoubleArrow + i;
            if(model.tag == VHBrushShapeLine) {
                model.isSelect = YES;
            }
            [_shapeModels addObject:model];
        }
    }
    return _shapeModels;
}

@end


@interface VHDocBrushSelectView ()

@end

@implementation VHDocBrushSelectView

- (instancetype)initWithModels:(NSArray <VHDocBrushItemModel *> *)models
{
    self = [super init];
    if (self) {
        self.models = models;
    }
    return self;
}

- (void)setModels:(NSArray<VHDocBrushItemModel *> *)models {
    _models = models;
    [self removeAllSubviews];
    [self configUI];
}

- (void)configUI {
    self.hidden = NO;
    self.backgroundColor = MakeColorRGBA(0x000000,0.6);
    NSMutableArray *buttonArr = [NSMutableArray array];
    for(int i = 0 ; i < self.models.count ; i ++) {
        VHDocBrushItemModel *model = self.models[i];
        UIButton *button = [[UIButton alloc] init];
//        button.backgroundColor = [UIColor blueColor];
        button.selected = model.isSelect;
        button.tag = model.tag;
        
        [button setImage:BundleUIImage(model.normalImgName) forState:UIControlStateNormal];
        [button setBackgroundImage:BundleUIImage(@"icon-文档工具hover") forState:UIControlStateSelected];
        [button addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttonArr addObject:button];
    }
    [buttonArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(26, 26)));
        make.left.equalTo(self).offset(5);
        make.right.equalTo(self).offset(-5);
    }];
    
    [buttonArr mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:10 leadSpacing:10 tailSpacing:10];
    
    self.layer.cornerRadius = 18;
    self.layer.masksToBounds = YES;
}


- (void)itemButtonClick:(UIButton *)selectBtn {
    for(VHDocBrushItemModel *model in self.models) {
        if(model.tag == selectBtn.tag) {
            if(model.isSelect) { //当前重复选择则直接return
                return;
            }
            model.isSelect = YES;
        }else {
            model.isSelect = NO;
        }
    }
    
    for(UIButton *button in self.subviews) {
        if(button != selectBtn) {
            button.selected = NO;
        }
    }

    selectBtn.selected = YES;
    
    if([self.delegate respondsToSelector:@selector(brushSelectView:selectTag:)]) {
        [self.delegate brushSelectView:self selectTag:selectBtn.tag];
    }
}

@end


@implementation VHDocBrushItemModel

@end
