//
//  WatchLiveQATableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveQATableViewCell.h"
#import "UIImageView+WebCache.h"
#import <VHLiveSDK/VHallApi.h>
@implementation WatchLiveQATableViewCell
{
  
    __weak IBOutlet UIButton *lblType;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UILabel *lblContent;
    __weak IBOutlet UIImageView *headImage;
//    __weak IBOutlet UILabel *lblQuestionID;
//    __weak IBOutlet UILabel *lblJoinID;
//    __weak IBOutlet UILabel *lblRole;
}

- (id)init
{
    self = LoadViewNibName;
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if ([_model isKindOfClass:[VHallAnswerModel class]]) {
        VHallAnswerModel* answer = (VHallAnswerModel *)_model;
        
        NSString* role = @"";
        if([answer.role_name isEqualToString:@"host"]) {
            role = @"主持人";
        }else if([answer.role_name isEqualToString:@"guest"]) {
            role = @"嘉宾";
        }else if([answer.role_name isEqualToString:@"assistant"]) {
            role = @"助手";
        }else if([answer.role_name isEqualToString:@"user"]) {
            role = @"观众";
        }

        lblNickName.text   = [NSString stringWithFormat:@"%@:", answer.nick_name];
        lblTime.text       = [NSString stringWithFormat:@"[%@]%@",role,answer.created_at];
        lblContent.text    = [NSString stringWithFormat:@"%@\n\n\n", answer.content];

        [lblType setTitle:@"答" forState:UIControlStateNormal];
        lblType.layer.borderColor=[UIColor blueColor].CGColor;
        [lblType setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

        [headImage sd_setImageWithURL:[NSURL URLWithString:answer.avatar] placeholderImage:BundleUIImage(@"head50")];

    }
    else
    {
        [lblType setTitle:@"问" forState:UIControlStateNormal];
        lblType.layer.borderColor=[UIColor redColor].CGColor;
        [lblType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [headImage sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:BundleUIImage(@"head50")];

        lblNickName.text   = [NSString stringWithFormat:@"%@:", _model.nick_name];
        lblTime.text       = _model.created_at;
        lblContent.text    = [NSString stringWithFormat:@"%@\n\n\n", _model.content];
        
    }
    
    [self layoutIfNeeded];
}

@end
