//
//  VHLiveChatView.m
//  VhallIphone
//
//  Created by dev on 16/8/3.
//  Copyright © 2016年 www.vhall.com. All rights reserved.
//

#import "VHLiveChatView.h"
#import "VHChatTableViewCell.h"
@interface VHLiveChatView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger(^_number)();
    VHActMsg*(^_msgSource)(NSInteger index);
}
@property(nonatomic,copy) void(^action)(ChatViewActionType type ,NSString * userId ,NSString * nickName);
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MASConstraint *tableViewHeight;
@end

@implementation VHLiveChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.tableViewHeight = make.height.equalTo(self);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame msgTotal:(NSInteger(^)())number msgSource:(VHActMsg*(^)(NSInteger index))msg action:(void(^)(ChatViewActionType type ,NSString * userId ,NSString * nickNam))action
{
    self = [self initWithFrame:frame];
    if (self) {
        _number = number;
        _msgSource = msg;
        _action = action;
    }
    return self;
}

- (void)update
{
    [_tableView reloadData];
    [_tableView layoutIfNeeded];
    if (_tableView.contentSize.height < self.height) {
        [self.tableViewHeight uninstall];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.tableViewHeight = make.height.mas_equalTo(_tableView.contentSize.height);
        }];
    }else {
        if(self.tableView.height < self.height){
            [self.tableViewHeight uninstall];
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.tableViewHeight = make.height.mas_equalTo(self);
            }];
        }
        [_tableView setContentOffset:CGPointMake(0, _tableView.contentSize.height - _tableView.height) animated:YES];
    }
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _number();
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHActMsg * msg = _msgSource(indexPath.row);
    NSString * identifier = @"identifier";
    switch (msg.type) {
        case ActMsgTypeMsg:{
            identifier = VHChatMsgIdentifier;
        }break;
        case ActMsgTypeOnline:{
            identifier = VHChatOnlineIdentifier;
        }break;
        case ActMsgTypePay:{
            identifier = VHChatPayIdentifier;
        }break;
        case ActMsgTypeQuestion:{
            identifier = VHChatQuestionIdentifier;
        }break;
        default:
            break;
    }
    VHChatSingleSideTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VHChatSingleSideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    __weak __typeof(self) weakself = self;
    cell.headerViewAction = ^(NSString * userId){
        weakself.action == nil?:weakself.action(ChatViewActionTypeCheckUser,userId,nil);
    };
    cell.bgViewAction = ^(NSString * userId,NSString * userName){
        weakself.action == nil?:weakself.action(ChatViewActionTypeTalkTo,userId,userName);
    };
    cell.msg = msg;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VHChatSingleSideTableViewCell getCellHeight:_msgSource(indexPath.row)];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
    }
    return _tableView;
}


@end
