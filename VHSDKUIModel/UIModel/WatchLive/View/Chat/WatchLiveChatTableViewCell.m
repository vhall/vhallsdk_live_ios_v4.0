//
//  WatchLiveChatTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveChatTableViewCell.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"
#import <VHLiveSDK/VHallApi.h>

@implementation WatchLiveChatTableViewCell
{
    __weak IBOutlet UIImageView *pic;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet MLEmojiLabel *lblContext;
    __weak IBOutlet UILabel *replyContext;
    __weak IBOutlet NSLayoutConstraint *replayTop;
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
    
    lblContext.minimumScaleFactor = 0.3;
    lblContext.lineBreakMode = NSLineBreakByCharWrapping;
    lblContext.isNeedAtAndPoundSign = NO;
    lblContext.textColor = [UIColor blackColor];
    lblContext.customEmojiRegex = CustomEmojiRegex;
    lblContext.customEmojiPlistName = CustomEmojiPlistName;
    lblContext.customEmojiBundleName = BundleName;
    lblContext.userInteractionEnabled=NO;
    lblContext.disableThreeCommon = NO;
}

- (void)setModel:(VHallChatModel *)model {
    _model = model;
    if([_model isKindOfClass:[VHallCustomMsgModel class]])
    {
        VHallCustomMsgModel *model = (VHallCustomMsgModel *)_model;
        pic.image = nil;
        lblNickName.text = @"【用户自定义消息】";
        lblNickName.textColor = [UIColor redColor];
        lblTime.text = model.time;
        //内容
        lblContext.text = [model.jsonstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        replayTop.constant = 0;
        replyContext.text = @"";
    } else {
        [pic sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:BundleUIImage(@"head50")];
        lblNickName.text = [_model.user_name stringByAppendingFormat:@"[%@-%ld]%@",_model.role,(long)_model.role_name,[_model.account_id isEqualToString:[VHallApi currentUserID]]?@"(myself)":@""];
        lblTime.text = _model.time;
        lblNickName.textColor = [UIColor blackColor];
        NSString *contextText = [NSString stringWithFormat:@"%@%@",_model.text?_model.text:@"",_model.imageUrls.count>0? [_model.imageUrls componentsJoinedByString:@";"]:@""];
        //聊天
        if(_model.replyMsg) { //回复
            replayTop.constant = 10;
            NSString *string = [NSString stringWithFormat:@"%@%@",_model.replyMsg.text ?_model.replyMsg.text:@"",_model.replyMsg.imageUrls.count>0? [_model.replyMsg.imageUrls componentsJoinedByString:@";"]:@""];
            replyContext.text = [NSString stringWithFormat:@"%@：%@",_model.replyMsg.user_name,string];
            [lblContext setText:[NSString stringWithFormat:@"回复：%@",contextText]];
        }else { //非回复
            replayTop.constant = 0;
            replyContext.text = @"";
            lblContext.text = contextText;
        }
        
//        //评论
//        if([_model isKindOfClass:[VHCommentModel class]] && _model.replyMsg) {
//            [lblContext setText:[NSString stringWithFormat:@"回复 %@：%@",_model.replyMsg.user_name,_model.text]];
//        }
    }
}


@end
