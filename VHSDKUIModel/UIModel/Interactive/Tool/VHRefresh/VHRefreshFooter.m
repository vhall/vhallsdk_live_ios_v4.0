//
//  ArtRefreshFooter.m
//  Art
//
//  Created by artifeng on 2017/3/9.
//  Copyright © 2017年 Jack. All rights reserved.
//

#import "VHRefreshFooter.h"

@implementation VHRefreshFooter

-(void)prepare
{
    [super prepare];
    self.automaticallyHidden = YES;
    self.stateLabel.font = [UIFont systemFontOfSize:14];
    self.stateLabel.textColor = MakeColorRGB(0x999999);
    [self setTitle:@"" forState:MJRefreshStateIdle];
    [self setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    [self setTitle:@" " forState:MJRefreshStateNoMoreData];
}

- (void)placeSubviews {
    [super placeSubviews];
    self.stateLabel.frame = CGRectMake(0, 0, VHScreenWidth, 60);
    self.loadingView.centerY = self.stateLabel.centerY;
}


@end
