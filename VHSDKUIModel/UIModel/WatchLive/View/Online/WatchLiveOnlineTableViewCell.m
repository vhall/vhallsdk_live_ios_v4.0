//
//  WatchLiveOnlineTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveOnlineTableViewCell.h"

@implementation WatchLiveOnlineTableViewCell
{
    __weak IBOutlet UILabel *lblShow;
    __weak IBOutlet UILabel *lblState;
}

- (id)init
{
    self = LoadViewNibName;
    if (self) {
    }
    return self;
}

- (void)setModel:(VHallOnlineStateModel *)model {
    _model = model;
    
    NSString *event = @"";
    if([_model.event isEqualToString:@"online"]) {
        event = @"进入";
    }else if([_model.event isEqualToString:@"offline"]){
        event = @"离开";
    }
    
    NSString *role = @"";
    if([_model.role isEqualToString:@"host"]) {
        role = @"主持人";
    }else if([_model.role isEqualToString:@"guest"]) {
        role = @"嘉宾";
    }else if([_model.role isEqualToString:@"assistant"]) {
        role = @"助手";
    }else if([_model.role isEqualToString:@"user"]) {
        role = @"观众";
    }
    NSString *userName = model.user_name ? model.user_name : @"游客";
    lblShow.text = [NSString stringWithFormat:@"%@[%@] %@房间",userName,role,event];
    lblState.text = [NSString stringWithFormat:@"在线:%@ 参会:%@ %@", model.concurrent_user,model.attend_count,model.time];
}

@end
