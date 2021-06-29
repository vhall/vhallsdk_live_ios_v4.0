//
//  WatchLiveLotteryTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveLotteryTableViewCell.h"
#import "UIImageView+WebCache.h"
@interface WatchLiveLotteryTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;

@end

@implementation WatchLiveLotteryTableViewCell

- (id)init
{
    self = LoadViewNibName;
    if (self) {
        
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setModel:(VHallLotteryResultModel *)model {
    _model = model;
    self.nickName.text = _model.nick_name;
    [self.headIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:BundleUIImage(@"head50")];
}


@end
