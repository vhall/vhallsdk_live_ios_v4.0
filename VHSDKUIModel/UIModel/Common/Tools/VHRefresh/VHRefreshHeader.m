//
//  ArtRefreshHeader.m
//  Art
//
//  Created by artifeng on 2017/3/9.
//  Copyright © 2017年 Jack. All rights reserved.
//

#import "VHRefreshHeader.h"

@implementation VHRefreshHeader

-(void)prepare {
    [super prepare];
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.font = [UIFont systemFontOfSize:12];
    
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"释放更新" forState:MJRefreshStatePulling];
    [self setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
}


@end
