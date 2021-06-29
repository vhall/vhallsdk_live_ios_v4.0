//
//  VHLiveMemberListView.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveMemberListView.h"
#import "VHLiveMemberCell.h"
#import "VHLiveMemberModel.h"
#import "VHActionSheet.h"
#import "VHRefreshHeader.h"
#import "VHRefreshFooter.h"
#import <VHInteractive/VHRoom.h>

@interface VHLiveMemberListView () <UITableViewDelegate,UITableViewDataSource,VHLiveMemberAndLimitBaseCellDelegate>
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

@implementation VHLiveMemberListView

- (instancetype)initWithRoom:(VHRoom *)room liveState:(VHLiveType)liveType isGuest:(BOOL)isGuest haveMembersManage:(BOOL)memberManage {
    self = [super init];
    if (self) {
        self.room = room;
        _liveType = liveType;
        _isGuest = isGuest;
        _haveMemberManage = memberManage;
        _dataSource = [NSMutableArray array];
        [self configUI];
        [self loadMemberListData:1];
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
    [self loadMemberListData:1];
}

//获取在线列表
- (void)loadMemberListData:(NSInteger)pageNum {
    if(pageNum < 1) {
        pageNum = 1;
    }
    NSInteger pageSize = 10;
    [self.room getOnlineUserListWithPageNum:pageNum pageSize:pageSize nickName:nil success:^(NSArray<VHRoomMember *> *list, BOOL haveNextPage) {
        if(pageNum == 1) {//下拉刷新
            self.pageNum = pageNum;
            self.dataSource = [NSMutableArray arrayWithArray:list];
        }else {
            self.pageNum ++;
            [self.dataSource addObjectsFromArray:list];
        }
        //排序：主持人、嘉宾、助理、观众排序
        [self sortDataSource];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        if (!haveNextPage) {
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

//排序
- (void)sortDataSource {
    NSMutableArray *hostArray = [NSMutableArray array];
    NSMutableArray *guestArray = [NSMutableArray array];
    NSMutableArray *assistantArray = [NSMutableArray array];
    NSMutableArray *audienceArray = [NSMutableArray array];
    
    for(int i = 0 ; i < self.dataSource.count ; i++) {
        VHRoomMember *model = self.dataSource[i];
        if(model.role_name == VHLiveRole_Host) { //主持人
            [hostArray addObject:model];
        }else if(model.role_name == VHLiveRole_Guest) { //嘉宾
            [guestArray addObject:model];
        }else if(model.role_name == VHLiveRole_Assistant) { //助理
            [assistantArray addObject:model];
        }else if (model.role_name == VHLiveRole_Audience) { //观众
            [audienceArray addObject:model];
        }
    }
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:hostArray];
    [self.dataSource addObjectsFromArray:guestArray];
    [self.dataSource addObjectsFromArray:assistantArray];
    [self.dataSource addObjectsFromArray:audienceArray];
}

//设置主讲人
- (void)setSpeakerWithUserModel:(VHRoomMember *)model {
    if([model.account_id isEqualToString:self.room.roomInfo.mainSpeakerId]) {
        VH_ShowToast(@"请勿重复设置主讲人");
        return;
    }
    [self.room setMainSpeakerWithTargetUserId:model.account_id success:^{
        VH_ShowToast(@"设置成功");
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
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


#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHLiveMemberCell *cell = [VHLiveMemberCell createCellWithTableView:tableView delegate:self];
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

//当前直播类型
- (VHLiveType)curretLiveType {
    return self.liveType;
}

//更多按钮事件
- (void)moreBtnClickModel:(VHRoomMember *)model {
    if(model.role_name == VHLiveRole_Host) { //主持人，弹出设为主讲人
        VHActionSheet *actionSheet = [VHActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(VHActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if(buttonIndex == 1) {
                [self setSpeakerWithUserModel:model];
            }
        } otherButtonTitles:@"设置主讲人",nil];
        [actionSheet show];
    }else if(model.role_name == VHLiveRole_Guest && model.is_speak == 1) { //嘉宾 && 已上麦
        VHActionSheet *actionSheet = [VHActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(VHActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if(buttonIndex == 1) {
                [self setSpeakerWithUserModel:model];
            }if(buttonIndex == 2) {
                if(model.is_banned) {
                    [self cancelBanVoiceWithUserModel:model];
                }else {
                    [self banVoiceWithUserModel:model];
                }
            }if(buttonIndex == 3) {
                [self kickOutWithUserModel:model];
            }
        } otherButtonTitles:@"设为主讲人",model.is_banned ? @"取消禁言" : @"聊天禁言",@"踢出活动",nil];
        [actionSheet show];
    }else {
        VHActionSheet *actionSheet = [VHActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(VHActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if(buttonIndex == 1) {
                if(model.is_banned) {
                    [self cancelBanVoiceWithUserModel:model];
                }else {
                    [self banVoiceWithUserModel:model];
                }
            }if(buttonIndex == 2) {
                [self kickOutWithUserModel:model];
            }
        } otherButtonTitles:model.is_banned ? @"取消禁言" : @"聊天禁言",@"踢出活动",nil];
        [actionSheet show];
    }
}

//上麦邀请/强制下麦
- (void)upMicrophoneActionWithButton:(UIButton *)button targetId:(NSString *)targetId {
    button.userInteractionEnabled = NO;
    if(!button.selected) { //上麦邀请
        [self.room inviteWithTargetUserId:targetId success:^{
            VH_ShowToast(@"已发送上麦邀请");
            button.userInteractionEnabled = YES;
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
            button.userInteractionEnabled = YES;
        }];
    }else { //强制下麦
        [self.room downMicWithTargetUserId:targetId success:^{
            VH_ShowToast(@"已下麦该用户");
            button.userInteractionEnabled = YES;
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
            button.userInteractionEnabled = YES;
        }];
    }
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
            @strongify(self)
            [self loadMemberListData:1];
        }];
        _tableView.mj_footer = [VHRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMemberListData:self.pageNum + 1];
        }];
    }
    return _tableView;
}
@end
