//
//  VHLiveInfoDetailChatView.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveInfoDetailChatView.h"
#import "VHLiveMsgModel.h"
#import "VHLiveInfoDetailChatCell.h"

@interface VHLiveInfoDetailChatView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <VHLiveMsgModel *> *dataSource;
/** 聊天条数 */
@property (nonatomic, assign) NSInteger chatNumCount;

@end

@implementation VHLiveInfoDetailChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.maxCount = 10000;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(34));
    }];
}

- (void)receiveMessage:(VHLiveMsgModel *)model {
    if(!model) {
        return;
    }
    if (!model.nickName || [model.nickName isEqualToString:@""]) {
        return;
    }
    self.chatNumCount ++; //聊天条数累加
    if(self.dataSource.count >= self.maxCount) {
        [self.dataSource removeObjectAtIndex:0];
    }
    [self.dataSource addObject:model];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updataTableViewHeight];
    });
}

//更新tableView高度
- (void)updataTableViewHeight {
    CGFloat contentSizeHeight = self.tableView.contentSize.height;

    if(contentSizeHeight < ChatViewHeight) {
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(contentSizeHeight));
        }];

        //上面contentSizeHeight高度可能计算不准确，强制布局，后重新获取真实的contentSizeHeight
        [self.tableView layoutIfNeeded];
        CGFloat realContentSizeHeight = self.tableView.contentSize.height; //此时获取到的高度才是正确的
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(realContentSizeHeight < ChatViewHeight ? realContentSizeHeight : ChatViewHeight));
        }];
        
    }else {
        if(self.tableView.height < ChatViewHeight) {
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(ChatViewHeight));
            }];
        }
    }
    
    // 滚动到最底部
    if ([self.tableView numberOfSections] > 0) {
        NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
        NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex > 0) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
            [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark - tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHLiveInfoDetailChatCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VHLiveInfoDetailChatCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[VHLiveInfoDetailChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([VHLiveInfoDetailChatCell class])];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    VHLiveMsgModel *message = self.dataSource[indexPath.row];
    cell.msgModel = message;
    return cell;
}

#pragma mark - lazy load
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 34;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[VHLiveInfoDetailChatCell class] forCellReuseIdentifier:NSStringFromClass([VHLiveInfoDetailChatCell class])];
    }return _tableView;
}


@end
