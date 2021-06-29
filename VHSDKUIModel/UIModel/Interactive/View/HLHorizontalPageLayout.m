//
//  HLHorizontalPageLayout.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "HLHorizontalPageLayout.h"

@interface HLHorizontalPageLayout()

@property (strong, nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;

/** 单页行数 */
@property (assign, nonatomic) NSInteger  rowCount;
/** 单页列数  */
@property (assign, nonatomic) NSInteger  columnCount;
@property (nonatomic, assign) NSInteger pageNum;
@end

@implementation HLHorizontalPageLayout

#pragma mark - Layout
// 布局前准备
- (void)prepareLayout {
    self.layoutAttributes = [NSMutableArray array];
    _rowCount = 0;
    _columnCount = 0;
    _pageNum = 0;
    NSInteger sections = [self.collectionView numberOfSections];
    for(int i = 0 ; i < sections; i++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:i];
        // 获取所有布局
        for (NSInteger j = 0; j < itemCount; j++) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexpath];
            [self.layoutAttributes addObject:attr];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attri = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    UIEdgeInsets inset = [self insetForSection:section];
    CGSize itemSize = [self itemSizeForSection:section];
    if([self.collectionView numberOfSections] == 2 && section == 0) { //插播/共享屏幕布局
       attri.frame = CGRectMake(0, inset.top, itemSize.width, itemSize.height);
    } else { //普通用户视频布局
        // 总页数
        NSInteger pageNumber = item / (self.rowCount * self.columnCount);
        // 该页中item的序号
        NSInteger itemInPage = item % (self.rowCount * self.columnCount);
        // item的所在列、行
        NSInteger col = itemInPage % self.columnCount;
        NSInteger row = itemInPage / self.columnCount;
  
        CGFloat leftX = [self.collectionView numberOfSections] == 2 ? self.collectionView.bounds.size.width : 0;
        CGFloat x = leftX + inset.left + (itemSize.width + self.minimumInteritemSpacing) * col + pageNumber * self.collectionView.bounds.size.width;
        CGFloat y = inset.top + (itemSize.height + self.minimumLineSpacing) * row ;
        attri.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
    }
    return attri;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    CGSize size = CGSizeMake(self.pageNum * self.collectionView.bounds.size.width, 0);
    return size;
}


- (UIEdgeInsets)insetForSection:(NSInteger)section {

    if([self.deslegate respondsToSelector:@selector(layout:insetForSection:)]) {
        return [self.deslegate layout:self insetForSection:section];
    }else {
        return UIEdgeInsetsZero;
    }
}

- (CGSize)itemSizeForSection:(NSInteger)section {
    if([self.deslegate respondsToSelector:@selector(layout:itemSizeForSection:)]) {
        return [self.deslegate layout:self itemSizeForSection:section];
    }else {
        return CGSizeZero;
    }
}

//获取总页码数
- (NSInteger)pageNum {
    if(_pageNum == 0) {
        NSInteger sections = [self.collectionView numberOfSections];
        NSInteger itemCount = 0;
        if(sections == 2) {
            itemCount = [self.collectionView numberOfItemsInSection:1];
        }else {
            itemCount = [self.collectionView numberOfItemsInSection:0];
        }
        //计算出除了插播/共享屏幕以外，用户视频个数所占屏幕页数
        NSInteger onePageCount = self.rowCount * self.columnCount;
        NSInteger pageNumber = itemCount / onePageCount;
        if (itemCount % onePageCount != 0) {
            pageNumber += 1;
        }
        _pageNum = sections == 2 ? pageNumber + 1 : pageNumber; //添加插播/共享屏幕一屏的页数
        //    NSLog(@"总个数=%zd，单页行数=%zd，单页列数=%zd，单页总数=%zd，总页数=%zd",itemCount,self.rowCount,self.columnCount,onePageCount,pageNumber);
    }
    return _pageNum;
}


// 获取单页item行数 根据itemSize lineSpacing sectionInsets collectionView frame计算取得
- (NSInteger)rowCount {
    if(_rowCount == 0) {
        NSInteger sections = [self.collectionView numberOfSections];
        UIEdgeInsets inset = UIEdgeInsetsZero;
        CGSize size = CGSizeZero;
        if(sections == 2) {
            inset = [self insetForSection:1];
            size = [self itemSizeForSection:1];
        }else {
            inset = [self insetForSection:0];
            size = [self itemSizeForSection:0];
        }

        NSInteger numerator = self.collectionView.bounds.size.height - inset.top - inset.bottom + self.minimumLineSpacing;
        NSInteger denominator = self.minimumLineSpacing + size.height;
        NSInteger count = numerator/denominator;
        _rowCount = count;
        
        // minimumLineSpacing itemSize.height不是刚好填满 将多出来的补给minimumLineSpacing
        if (numerator % denominator != 0) {
            self.minimumLineSpacing = (self.collectionView.bounds.size.height - inset.top - inset.bottom - count * size.height) / (CGFloat)(count - 1);
            if(self.minimumLineSpacing <= 0) {
                self.minimumLineSpacing = 0;
            }
        }
    }
    return _rowCount;
}

// 获取单页item列数 根据itemSize minimumInteritemSpacing sectionInsets collectionView frame计算取得
- (NSInteger)columnCount {
    if(_columnCount == 0) {
        NSInteger sections = [self.collectionView numberOfSections];
        UIEdgeInsets inset = UIEdgeInsetsZero;
        CGSize size = CGSizeZero;
        if(sections == 2) {
            inset = [self insetForSection:1];
            size = [self itemSizeForSection:1];
        }else {
            inset = [self insetForSection:0];
            size = [self itemSizeForSection:0];
        }
        
        NSInteger numerator = self.collectionView.bounds.size.width - inset.left - inset.right + self.minimumInteritemSpacing;
        NSInteger denominator = self.minimumInteritemSpacing + size.width;
        NSInteger count = numerator/denominator;
        _columnCount = count;
        // minimumInteritemSpacing itemSize.width不是刚好填满 将多出来的补给minimumInteritemSpacing
        if (numerator % denominator != 0) {
            self.minimumInteritemSpacing = (self.collectionView.bounds.size.width - inset.left - inset.right - count * size.width) / (CGFloat)(count - 1);
            if(self.minimumInteritemSpacing <= 0) {
                self.minimumInteritemSpacing = 0;
            }
        }
    }
    return _columnCount;
}

@end
