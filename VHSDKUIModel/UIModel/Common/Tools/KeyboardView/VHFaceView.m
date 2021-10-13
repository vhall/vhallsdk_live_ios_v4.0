/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "VHFaceView.h"

#define FaceSectionBarHeight  36   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

#define Pages 5

@interface VHFaceView ()
{
    VHFacialView *_facialView;
}

@end

@implementation VHFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _faceScrollView = [[UIScrollView alloc]init];
        CGFloat leftMargin = iPhoneX ? 45 : 0;
        if(VH_KScreenIsLandscape) {
            _faceScrollView.frame = CGRectMake(leftMargin, 0, (frame.size.width - 2 * leftMargin), frame.size.height);
        }else {
            _faceScrollView.frame = CGRectMake(0, 0, frame.size.width , frame.size.height);
        }
        _faceScrollView.backgroundColor = [UIColor whiteColor];
        _faceScrollView.delegate = self;
        [self addSubview:_faceScrollView];
        [_faceScrollView setPagingEnabled:YES];
        [_faceScrollView setShowsHorizontalScrollIndicator:NO];
        [_faceScrollView setContentSize:CGSizeMake(CGRectGetWidth(_faceScrollView.frame) * Pages,0)];
        
        for (int i= 0;i < Pages; i++) {
            VHFacialView *faceView = [[VHFacialView alloc] initWithFrame:CGRectMake(i * _faceScrollView.bounds.size.width,0.0f,_faceScrollView.bounds.size.width,_faceScrollView.bounds.size.height - FacePageControlHeight - VH_BottomSafeMargin)];
            [faceView loadFaceWithPageIndex:i];
            [_faceScrollView addSubview:faceView];
            faceView.delegate = self;
        }
        
        _facePageControl = [[UIPageControl alloc]init];
        [_facePageControl setFrame:CGRectMake(0,CGRectGetMaxY(_faceScrollView.frame) - FacePageControlHeight - VH_BottomSafeMargin,CGRectGetWidth(self.bounds),FacePageControlHeight)];
        [self addSubview:_facePageControl];
        [_facePageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [_facePageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        _facePageControl.numberOfPages = Pages;
        _facePageControl.currentPage   = 0;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VHScreenWidth, 0.5)];
        lineView.backgroundColor = MakeColorRGB(0xDDDDDD);
        [self addSubview:lineView];
    }
    return self;
}

#pragma mark  scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/self.width;
    _facePageControl.currentPage = page;
}


#pragma mark - FacialViewDelegate

-(void)selectedFacialView:(NSString*)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:NO];
    }
}

-(void)deleteSelected:(NSString *)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:YES];
    }
}

- (void)sendFace
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

#pragma mark - public

- (BOOL)stringIsFace:(NSString *)string
{
    if ([_facialView.faces containsObject:string]) {
        return YES;
    }
    
    return NO;
}

@end
