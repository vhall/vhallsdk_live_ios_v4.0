//
//  VHLiveInfoDetailChatCell.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveInfoDetailChatCell.h"
#import "VHLiveMsgModel.h"
#import "VHKeyboardToolView.h"

@interface VHLiveInfoDetailChatCell ()

/** 详细信息*/
@property (nonatomic , strong) YYLabel * msgLab;
/** 角色 */
@property (nonatomic, strong) YYLabel *roleLab;


@end

@implementation VHLiveInfoDetailChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    [self.contentView addSubview:self.msgLab];
    [self.msgLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(2.5);
        make.bottom.mas_equalTo(-2.5);
        make.right.mas_lessThanOrEqualTo(self.contentView.right);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    self.msgLab.preferredMaxLayoutWidth = ChatLabelMaxLayoutWidth;
}

- (void)setMsgModel:(VHLiveMsgModel *)msgModel {
    _msgModel = msgModel;
    
    NSString *contentText = msgModel.context ? msgModel.context : @"";
    if(msgModel.imageUrls.count > 0) { //消息中带有图片，拼接图片地址
        NSString *imgUrlStr = [msgModel.imageUrls componentsJoinedByString:@";\n"];
        contentText = [NSString stringWithFormat:@"%@\n%@",contentText,imgUrlStr];
    }
    //匹配表情
    NSMutableAttributedString *attText = [VHKeyboardToolView processCommentContent:contentText font:FONT_FZZZ(14) textColor:[UIColor whiteColor]];
    //插入昵称
    NSString *name = msgModel.nickName.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[msgModel.nickName substringToIndex:VH_MaxNickNameCount]] : msgModel.nickName;
    [attText yy_insertString:[NSString stringWithFormat:@"%@：",name] atIndex:0];
    //设置昵称颜色与字体
    [attText setAttributes:@{NSForegroundColorAttributeName : MakeColorRGB(0xE2E2E2),NSFontAttributeName : FONT_FZZZ(14)} range:NSMakeRange(0, name.length + 1)];
   
    //插入角色标签
    if(msgModel.role != VHLiveRole_Audience) {
        if(msgModel.role == VHLiveRole_Host) {
            self.roleLab.text = @"主持人";
            self.roleLab.textColor = [UIColor whiteColor];
            self.roleLab.backgroundColor = MakeColorRGBA(0xFC5659,0.8);
        }else if (msgModel.role == VHLiveRole_Assistant) {
            self.roleLab.text = @"助理";
            self.roleLab.textColor = [UIColor whiteColor];
            self.roleLab.backgroundColor = MakeColorRGBA(0xAAAAAA,0.8);
        }else if (msgModel.role == VHLiveRole_Guest) {
            self.roleLab.text = @"嘉宾";
            self.roleLab.textColor = [UIColor whiteColor];
            self.roleLab.backgroundColor = MakeColorRGBA(0x5EA6EC,0.8);
        }
        
        CGSize size = [self.roleLab sizeThatFits:CGSizeZero];
        self.roleLab.size = CGSizeMake(size.width, 16);
        NSMutableAttributedString *attachment = [NSMutableAttributedString yy_attachmentStringWithContent:self.roleLab contentMode:UIViewContentModeLeft attachmentSize:CGSizeMake(size.width + 5, 16)  alignToFont:FONT_FZZZ(14) alignment:YYTextVerticalAlignmentCenter];
        [attText insertAttributedString:attachment atIndex:0];
    }
    
    self.msgLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.msgLab.attributedText = attText;
}

#pragma mark - lazyload
- (YYLabel *)msgLab
{
    if (!_msgLab) {
        _msgLab = [YYLabel new];
        _msgLab.numberOfLines = 0;
        _msgLab.layer.masksToBounds = YES;
        _msgLab.layer.cornerRadius = 12;
        _msgLab.backgroundColor = MakeColorRGBA(0x000000,0.3);
        _msgLab.textContainerInset = UIEdgeInsetsMake(2, 8, 2, 8);
    }
    return _msgLab;
}

- (YYLabel *)roleLab
{
    if (!_roleLab) {
        _roleLab = [[YYLabel alloc] init];
        _roleLab.font = FONT_FZZZ(11);
        _roleLab.layer.cornerRadius = 8;
        _roleLab.textContainerInset = UIEdgeInsetsMake(0, 6, 0, 6);
    }
    return _roleLab;
}

@end
