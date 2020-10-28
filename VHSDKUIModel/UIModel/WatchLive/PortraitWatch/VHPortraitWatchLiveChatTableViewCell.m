//
//  VHPortraitWatchLiveChatTableViewCell.m
//  UIModel
//
//  Created by xiongchao on 2020/9/23.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "VHPortraitWatchLiveChatTableViewCell.h"
#import "Masonry.h"
#import "MLEmojiLabel.h"

@interface VHPortraitWatchLiveChatTableViewCell ()
@property(nonatomic,strong)MLEmojiLabel *txtLab;
@end

@implementation VHPortraitWatchLiveChatTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configUI];
    }
    return self;
}

- (void)configUI{
    //背景view
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = MakeColorRGBA(0x000000,0.5);
    bgView.layer.cornerRadius = 12;
    bgView.clipsToBounds = YES;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
    }];
    
    [bgView addSubview:self.txtLab];
    [self.txtLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(10);
        make.right.equalTo(bgView).offset(-10);
        make.top.equalTo(bgView).offset(5);
        make.bottom.equalTo(bgView).offset(-5);
    }];
}

- (void)setModel:(VHallMsgModels *)model {
    _model = model;
    if([model isKindOfClass:[VHallChatModel class]]) { //聊天消息
        NSString *nikeName = model.user_name;
        UIColor *nameColor = [UIColor whiteColor]; //昵称颜色
        NSString *roleNameStr = @"";
        if(model.role_name == 1) { //主持人
            nameColor =  MakeColorRGB(0x01CBCF);
            roleNameStr = @"[主持人]";
        }else if(model.role_name == 2){
            nameColor =  MakeColorRGB(0xFFB72E);
            roleNameStr = @"[观众]";
        }else if(model.role_name == 3){
            nameColor =  MakeColorRGB(0xFFB72E);
            roleNameStr = @"[助理]";
        }else if(model.role_name == 4){
            nameColor =  MakeColorRGB(0x45B5FF);
            roleNameStr = @"[嘉宾]";
        }
        NSString *nameString;
        if(((VHallChatModel *)model).replyMsg) {//回复消息
            NSString *replyName = ((VHallChatModel *)model).replyMsg.user_name;
            nameString = [NSString stringWithFormat:@"%@%@ 回复 %@：",roleNameStr,nikeName,replyName];
        }else {
            nameString = [NSString stringWithFormat:@"%@%@：",roleNameStr,nikeName];
        }

        NSString *contentStr = [NSString stringWithFormat:@"%@%@",((VHallChatModel *)model).text ? ((VHallChatModel *)model).text : @"",((VHallChatModel *)model).imageUrls.count > 0 ? [((VHallChatModel *)model).imageUrls componentsJoinedByString:@";"] : @""];
        NSString *chatStr = [NSString stringWithFormat:@"%@%@",nameString,contentStr];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:chatStr attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        NSRange nameRange = [chatStr rangeOfString:nameString];
        [text addAttribute:NSForegroundColorAttributeName value:nameColor range:nameRange];
        self.txtLab.text = text;
        
    }else if ([model isKindOfClass:[VHallOnlineStateModel class]]) { //上下线消息
        NSString *chatStr;
        NSString *statuStr = [((VHallOnlineStateModel *)model).event isEqualToString:@"online"] ? @"进入房间" : @"离开房间";
        if(model.role_name == 1) { //主持人
            chatStr = [NSString stringWithFormat:@"[主持人]%@%@",model.user_name,statuStr];
        }else if(model.role_name == 2){
            chatStr = [NSString stringWithFormat:@"[观众]%@%@",model.user_name,statuStr];
        }else if(model.role_name == 3){
            chatStr = [NSString stringWithFormat:@"[助理]%@%@",model.user_name,statuStr];
        }else if(model.role_name == 4){
            chatStr = [NSString stringWithFormat:@"[嘉宾]%@%@",model.user_name,statuStr];
        }
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:chatStr attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.txtLab.text = text;
    }else if ([model isKindOfClass:[VHallCustomMsgModel class]]) { //自定义消息
        NSString *chatStr = ((VHallCustomMsgModel *)model).jsonstr;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:chatStr attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.txtLab.text = text;
    }
    //...其他消息
    
}

- (MLEmojiLabel *)txtLab
{
    if (!_txtLab)
    {
        _txtLab = [MLEmojiLabel new];
        _txtLab.numberOfLines = 0;
        _txtLab.font = [UIFont systemFontOfSize:14];
        _txtLab.adjustsFontSizeToFitWidth = YES;
        
        _txtLab.minimumScaleFactor = 0.3;
        _txtLab.backgroundColor = [UIColor clearColor];
        _txtLab.lineBreakMode = NSLineBreakByCharWrapping;
        _txtLab.textColor = [UIColor whiteColor];
        _txtLab.customEmojiRegex = CustomEmojiRegex;
        _txtLab.customEmojiPlistName = CustomEmojiPlistName;
        _txtLab.customEmojiBundleName = BundleName;
        _txtLab.userInteractionEnabled = NO;
        _txtLab.disableThreeCommon = YES;
    }
    return _txtLab;
}
@end
