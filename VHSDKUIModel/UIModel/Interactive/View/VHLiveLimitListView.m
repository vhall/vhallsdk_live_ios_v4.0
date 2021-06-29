//
//  VHLiveLimitListView.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveLimitListView.h"
#import "VHLiveLimitCell.h"
#import "VHLiveMemberModel.h"
#import "VHActionSheet.h"
#import "VHRefreshHeader.h"
#import "VHRefreshFooter.h"
#import <VHInteractive/VHRoom.h>

@interface VHLiveLimitListView () <UITableViewDelegate,UITableViewDataSource,VHLiveMemberAndLimitBaseCellDelegate>
/** 列表 */
@property (nonatomic, strong) UITableView *tableView;
/** 页码 */
@property (nonatomic, assign) NSInteger pageNum;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray <VHRoomMember *> *dataSource;
/** 是否为互动直播，嘉宾端 */
@property (nonatomic, assign) BOOL isGuest;
/** 无数据时展示空视图 */
@property (nonatomic, strong) UIView *emptyView;
/** 直播id */
@property (nonatomic, copy) NSString *liveId;
/** 嘉宾是否有成员管理权限 */
@property (nonatomic, assign) BOOL haveMemberManage;
/** 直播类型（不同直播类型下，成员列表展示不一样，需要记录这个值） */
@property (nonatomic, assign) VHLiveType liveType;
/** 直播对象 */
@property (nonatomic, strong) VHRoom *room;

@end

@implementation VHLiveLimitListView

- (instancetype)initWithRoom:(VHRoom *)room guest:(BOOL)isGuest haveMembersManage:(BOOL)memberManage;
{
    self = [super init];
    if (self) {
        _room = room;
        _isGuest = isGuest;
        _haveMemberManage = memberManage;
        _dataSource = [NSMutableArray array];
        [self configUI];
        [self loadLimitListData:1];
    }
    return self;
}

- (void)configUI {
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

///刷新数据
- (void)reloadNewData {
    CGPoint off = self.tableView.contentOffset;
    off.y = 0 - self.tableView.contentInset.top;
    [self.tableView setContentOffset:off animated:NO];
    [self loadLimitListData:1];
}

//获取受限列表
- (void)loadLimitListData:(NSInteger)pageNum {
    [self.room getLimitUserListWithPageNum:self.pageNum pageSize:20 success:^(NSArray<VHRoomMember *> *list, BOOL haveNextPage) {
        if(pageNum == 1) {//下拉刷新
            self.pageNum = pageNum;
            self.dataSource = [NSMutableArray arrayWithArray:list];
        }else {
            self.pageNum ++;
            [self.dataSource addObjectsFromArray:list];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        if(!haveNextPage) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

//禁言
- (void)banVoiceWithUserModel:(VHRoomMember *)model {
    [self.room setBanned:YES targetUserId:model.account_id success:^{
        VH_ShowToast(@"禁言成功");
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//取消禁言
- (void)cancelBanVoiceWithUserModel:(VHRoomMember *)model {
    [self.room setBanned:NO targetUserId:model.account_id success:^{
        VH_ShowToast(@"取消禁言成功");
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//踢出
- (void)kickOutWithUserModel:(VHRoomMember *)model {
    [self.room setKickOut:YES targetUserId:model.account_id success:^{
        VH_ShowToast(@"踢出成功");
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//取消踢出
- (void)cancelKickOutWithUserModel:(VHRoomMember *)model {
    [self.room setKickOut:NO targetUserId:model.account_id success:^{
        VH_ShowToast(@"取消踢出成功");
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.emptyView.hidden = self.dataSource.count != 0;
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHLiveLimitCell *cell = [VHLiveLimitCell createCellWithTableView:tableView delegate:self];
    cell.mainSpeakerId = self.room.roomInfo.mainSpeakerId;
    cell.model = self.dataSource[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - VHLiveMemberAndLimitBaseCellDelegate
//当前是否为嘉宾端
- (BOOL)currentUserIsGuest {
    return self.isGuest;
}

//嘉宾端是否有成员管理权限
- (BOOL)guestHaveMemberManage {
    return self.haveMemberManage;
}

//更多按钮点击
- (void)moreBtnClickModel:(VHRoomMember *)model {
    VHActionSheet *actionSheet = [VHActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(VHActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == 1) { //禁言
            if(model.is_banned) {
                [self cancelBanVoiceWithUserModel:model];
            }else {
                [self banVoiceWithUserModel:model];
            }
        }else if(buttonIndex == 2) { //踢出
            if(model.is_kicked) {
                [self cancelKickOutWithUserModel:model];
            }else {
                [self kickOutWithUserModel:model];
            }
        }
    } otherButtonTitles:model.is_banned ? @"取消禁言" : @"聊天禁言",model.is_kicked ? @"取消踢出" : @"踢出活动",nil];
    [actionSheet show];
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 60;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        @weakify(self);
        _tableView.mj_header = [VHRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadLimitListData:1];
        }];
        _tableView.mj_footer = [VHRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self loadLimitListData:self.pageNum + 1];
        }];
    }
    return _tableView;
}

- (UIView *)emptyView
{
    if (!_emptyView)
    {
        _emptyView = [[UIView alloc] init];
        _emptyView.userInteractionEnabled = NO;
        _emptyView.hidden = YES;
        [self addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.width.equalTo(self);
            make.height.equalTo(_emptyView);
        }];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = BundleUIImage(@"icon-受限列表为空");
        [_emptyView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(_emptyView);
            make.size.equalTo(@(CGSizeMake(84, 70)));
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"暂时没有禁言或踢出成员";
        label.font = FONT_FZZZ(16);
        label.textColor = MakeColorRGB(0x999999);
        [_emptyView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(8);
            make.centerX.bottom.equalTo(_emptyView);
            make.height.equalTo(@(22));
        }];
    }
    return _emptyView;
}


@end
