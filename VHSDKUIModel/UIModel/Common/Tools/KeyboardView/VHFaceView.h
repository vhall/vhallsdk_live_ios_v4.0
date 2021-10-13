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

#import <UIKit/UIKit.h>

#import "VHFacialView.h"

@protocol VHFaceDelegate <VHFacialViewDelegate>

@required
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
@optional
- (void)sendFace;

@end


@interface VHFaceView : UIView <VHFacialViewDelegate,UIScrollViewDelegate>

@property (nonatomic, weak) id<VHFaceDelegate> delegate;

@property(strong, nonatomic) UIScrollView *faceScrollView;
@property(strong, nonatomic) UIPageControl *facePageControl;

- (BOOL)stringIsFace:(NSString *)string;

@end
