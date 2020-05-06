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
    __weak IBOutlet UILabel *lblContext;
    MLEmojiLabel *_textLabel;
    UIImage *image;
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
    image = nil;
      [self layoutIfNeeded];
    if(!_textLabel)
    {
        _textLabel = [MLEmojiLabel new];
        _textLabel.numberOfLines = 0;
        
        _textLabel.font = lblContext.font;
        _textLabel.adjustsFontSizeToFitWidth=YES;
        _textLabel.minimumScaleFactor = 0.3;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.isNeedAtAndPoundSign = NO;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.customEmojiRegex = CustomEmojiRegex;
        _textLabel.customEmojiPlistName = CustomEmojiPlistName;
        _textLabel.customEmojiBundleName = BundleName;
        _textLabel.userInteractionEnabled=NO;
        _textLabel.disableThreeCommon = NO;
        _textLabel.frame = lblContext.frame;
        [self.contentView addSubview:_textLabel];
        lblContext.hidden = YES;
    }
//    _textLabel.text = @"[惊讶]";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if(!_model) return;
    
    _textLabel.top = 20;
    _textLabel.width = VH_SW - 60;
    if([_model isKindOfClass:[VHallCustomMsgModel class]])
    {
        VHallCustomMsgModel *model = (VHallCustomMsgModel *)_model;
        pic.image = nil;
        lblNickName.text = @"【用户自定义消息】";
        lblNickName.textColor = [UIColor redColor];
        lblTime.text = model.time;
        //内容
        _textLabel.text = [model.jsonstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
//        [_textLabel sizeToFit];
//        _textLabel.frame = lblContext.frame;
    }
    else{
        [pic sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:BundleUIImage(@"head50")];
        lblNickName.text = [_model.user_name stringByAppendingFormat:@"[%@]%@",_model.role,[_model.account_id isEqualToString:[VHallApi currentUserID]]?@"(myself)":@""];
        lblTime.text = _model.time;
        lblNickName.textColor = [UIColor blackColor];
        //内容
        [_textLabel setText:[NSString stringWithFormat:@"%@%@",_model.text?_model.text:@"",
                             _model.imageUrls.count>0? [_model.imageUrls componentsJoinedByString:@";"]:@""]];
        if([_model isKindOfClass:[VHallChatModel class]] && _model.replyMsg)
            [_textLabel setText:[NSString stringWithFormat:@"回复 %@：%@",_model.replyMsg.user_name,_model.text]];
        if([_model isKindOfClass:[VHCommentModel class]] && _model.replyMsg)
                   [_textLabel setText:[NSString stringWithFormat:@"回复 %@：%@",_model.replyMsg.user_name,_model.text]];
        
//        NSLog(@"************ %@",_model.text);
        
//        [_textLabel sizeToFit];
//        _textLabel.frame = lblContext.frame;
    }
}

@end
