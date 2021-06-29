//
//  VHDocBrushPopView.h
//  UIModel
//
//  Created by leiheng on 2021/4/22.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VHInteractive/VHRoom.h>

NS_ASSUME_NONNULL_BEGIN

//功能选择
typedef enum : NSUInteger {
    VHBrushFunctionTrash = 100, //垃圾桶
    VHBrushFunctionLine,     //线条
    VHBrushFunctionRubber,   //橡皮檫
    VHBrushFunctionColor,    //颜色
    VHBrushFunctionShape,    //形状
} VHBrushFunctionType;

//线条粗细
typedef enum : NSUInteger {
    VHBrushLine1 = 1000,
    VHBrushLine2,
    VHBrushLine3,
    VHBrushLine4,
    VHBrushLine5,
} VHBrushLineType;

//线条颜色
typedef enum : NSUInteger {
    VHBrushColorBlue = 10000,  //蓝色
    VHBrushColorGreen,        //绿色
    VHBrushColorOrange,       //橙色
    VHBrushColorRed,          //红色
    VHBrushColorWhite,        //白色
} VHBrushColorType;

//图形
typedef enum : NSUInteger {
    VHBrushShapeDoubleArrow = 100000,  //双箭头
    VHBrushShapeSingleArrow,          //单箭头
    VHBrushShapeLine,                 //线
    VHBrushColorRound,              //圆形
    VHBrushColorSquare,             //方形
} VHBrushShapeType;

@class VHDocumentView;
@class VHDocBrushItemModel;
@class VHDocBrushSelectView;
@class VHDocBrushPopView;

@protocol VHDocBrushPopViewDelegate <NSObject>

//颜色选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushColor:(UIColor *)color;

//画笔粗细选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushSize:(NSInteger)size;

//形状选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushShape:(VHDrawType)type;

//功能选择
- (void)brushPopView:(VHDocBrushPopView *)popView selectBrushFunction:(VHBrushFunctionType)type;

//是否开始进行涂鸦
- (void)brushPopView:(VHDocBrushPopView *)popView startBrushState:(BOOL)state;

@end

@interface VHDocBrushPopView : UIView

/** 当前选择的颜色 */
@property (nonatomic, strong ,readonly) UIColor *currentSelectColor;
/** 当前选择画笔粗细 */
@property (nonatomic, assign ,readonly) NSInteger currentSelectSize;
/** 当前选择的画笔图形 */
@property (nonatomic, assign ,readonly) VHDrawType currentSelectShape;

- (instancetype)initWithDelegate:(id<VHDocBrushPopViewDelegate>)delegate;

//是否开启画笔弹窗
- (void)showPopView:(BOOL)show;
@end

@protocol VHDocBrushSelectViewDelegate <NSObject>

- (void)brushSelectView:(VHDocBrushSelectView *)view selectTag:(NSInteger)tag;

@end


@interface VHDocBrushSelectView : UIView

/** 代理 */
@property (nonatomic, weak) id <VHDocBrushSelectViewDelegate> delegate;

@property (nonatomic, strong) NSArray <VHDocBrushItemModel *> *models;

- (instancetype)initWithModels:(NSArray <VHDocBrushItemModel *> *)models;

@end



@interface VHDocBrushItemModel : NSObject

/** 未选中样式图片 */
@property (nonatomic, copy) NSString *normalImgName;
/** 标识 */
@property (nonatomic, assign) NSInteger tag;
/** 当前是否选中状态 */
@property (nonatomic, assign) NSInteger isSelect;

@end

NS_ASSUME_NONNULL_END
