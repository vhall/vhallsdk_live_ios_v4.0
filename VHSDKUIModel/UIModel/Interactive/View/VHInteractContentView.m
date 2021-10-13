//
//  VHInteractContentView.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHInteractContentView.h"
#import "VHInteractVideoCell.h"
#import "VHLiveMemberModel.h"
#import "HLHorizontalPageLayout.h"
#import <VHInteractive/VHRoom.h>

@interface VHInteractContentView () <UICollectionViewDelegate,UICollectionViewDataSource,HLHorizontalPageLayoutDetegate>
/** 底部collectionView */
@property (nonatomic, strong) UICollectionView *collectionView;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray <VHLiveMemberModel *> *dadaSource;
/** 共享屏幕或插播数据 ，非空则显示插播或共享屏幕 (如果显示，则有2组section，第一组1个cell展示插播或共享屏幕，第二组展示视频cell，如果不显示，则有1组section，全部展示视频cell)*/
@property (nonatomic, strong) VHLiveMemberModel *screenOrFileModel;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) HLHorizontalPageLayout *collectionViewLayout;
/** 是否横屏显示 */
@property (nonatomic, assign) BOOL landScapeShow;
@end

@implementation VHInteractContentView

- (instancetype)initWithLandscapeShow:(BOOL)landScapeShow;
{
    self = [super init];
    if (self) {
        self.landScapeShow = landScapeShow;
        [self configUI];
        [self configFrame];
    }
    return self;
}

- (void)configUI {
//    self.backgroundColor = [UIColor blueColor];
//    self.collectionView.backgroundColor = [UIColor redColor];
//    self.pageControl.backgroundColor = [UIColor greenColor];
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self configFrame];
}

- (void)configFrame {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(-0.5);
        make.right.equalTo(self).offset(0.5);
        make.top.equalTo(self);
        if(self.landScapeShow) {
            make.height.bottom.equalTo(self);
        }else {
            make.height.equalTo(self.mas_width);
        }
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.height.equalTo(@(10));
        if(self.landScapeShow) {
            make.bottom.equalTo(self).offset(-(iPhoneX ? 15 : 10));
        }else {
            make.bottom.equalTo(self);
            make.top.equalTo(self.collectionView.mas_bottom).offset(10);
        }
    }];
}

- (void)reloadAllData {
    [self.collectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pageControl.hidden = self.collectionViewLayout.pageNum == 1;
        self.pageControl.numberOfPages = self.collectionViewLayout.pageNum;
        self.pageControl.currentPage = self.collectionView.contentOffset.x / self.collectionView.width;
    });
}


//某个用户是否在麦上
- (BOOL)haveRenderViewWithTargerId:(NSString *)targerId {
    __block BOOL have = NO;
    [self.dadaSource enumerateObjectsUsingBlock:^(VHLiveMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.videoView.userId isEqualToString:targerId]) {
            have = YES;
            *stop = YES;
        }
    }];
    return have;
}

//**上麦添加视频画面
- (void)addAttendWithUser:(VHLiveMemberModel *)model {
    NSLog(@"上麦添加视频画面流id:%@",model.videoView.streamId);
    //如果非插播||共享屏幕
    if(model.videoView.streamType != VHInteractiveStreamTypeScreen && model.videoView.streamType != VHInteractiveStreamTypeFile) {
        //防止同一用户视频多次添加
        for(VHLiveMemberModel *memberModel in self.dadaSource.reverseObjectEnumerator) {
            if([model.account_id isEqualToString:memberModel.account_id]) {
                [self.dadaSource removeObject:memberModel];
            }
        }

        [self addNewUserWithModel:model];
        
    } else { //插播 || 共享屏幕
        self.screenOrFileModel = model;
    }
    [self reloadAllData];
}


- (void)addNewUserWithModel:(VHLiveMemberModel *)model {
    NSMutableArray *hostArray = [NSMutableArray array];
    NSMutableArray *guestArray = [NSMutableArray array];
    NSMutableArray *assistantArray = [NSMutableArray array];
    NSMutableArray *audienceArray = [NSMutableArray array];
    
    for(int i = 0 ; i < self.dadaSource.count ; i++) {
        VHLiveMemberModel *tempModel = self.dadaSource[i];
        if(tempModel.role_name == VHLiveRole_Host) { //主持人
            [hostArray addObject:tempModel];
        }else if(tempModel.role_name == VHLiveRole_Guest) { //嘉宾
            [guestArray addObject:tempModel];
        }else if(tempModel.role_name == VHLiveRole_Assistant) { //助理
            [assistantArray addObject:tempModel];
        }else  { //观众
            [audienceArray addObject:tempModel];
        }
    }
    if(model.role_name == VHLiveRole_Host) { //主持人
        [hostArray addObject:model];
    }else if(model.role_name == VHLiveRole_Guest) { //嘉宾
        [guestArray addObject:model];
    }else if(model.role_name == VHLiveRole_Assistant) { //助理
        [assistantArray addObject:model];
    }else { //观众
        [audienceArray addObject:model];
    }
    [self.dadaSource removeAllObjects];
    [self.dadaSource addObjectsFromArray:hostArray];
    [self.dadaSource addObjectsFromArray:guestArray];
    [self.dadaSource addObjectsFromArray:assistantArray];
    [self.dadaSource addObjectsFromArray:audienceArray];
}

//**下麦移除视频画面
- (void)removeAttendView:(VHLocalRenderView *)renderView {
    [renderView removeFromSuperview];
    if(renderView.streamType == VHInteractiveStreamTypeScreen || renderView.streamType == VHInteractiveStreamTypeFile) { //共享屏幕 || 插播
        self.screenOrFileModel = nil;
    }else {
        for(VHLiveMemberModel *model in self.dadaSource.reverseObjectEnumerator) {
            if([model.account_id isEqualToString:renderView.userId]) {
                VUI_Log(@"移除用户");
                [self.dadaSource removeObject:model];
            }
        }
    }
    [self reloadAllData];
}

//某个用户摄像头开关改变
- (void)targerId:(NSString *)targerId closeCamera:(BOOL)state {
    for(int i = 0 ; i < self.dadaSource.count ; i++) {
        VHLiveMemberModel *model = self.dadaSource[i];
        if([model.account_id isEqualToString:targerId] && !(model.videoView.streamType == VHInteractiveStreamTypeScreen || model.videoView.streamType == VHInteractiveStreamTypeFile)) {
            model.closeCamera = state;
            VHInteractVideoCell *cell = (VHInteractVideoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:self.screenOrFileModel ? 1 : 0]];
            cell.model = model;
            break;
        }
    }
}

//某个用户麦克风开关改变
- (void)targerId:(NSString *)targerId closeMicrophone:(BOOL)state {
    for(int i = 0 ; i < self.dadaSource.count ; i++) {
        VHLiveMemberModel *model = self.dadaSource[i];
        if([model.account_id isEqualToString:targerId] && !(model.videoView.streamType == VHInteractiveStreamTypeScreen || model.videoView.streamType == VHInteractiveStreamTypeFile)) {
           // NSLog(@"是否有音频：%zd,是否有视频：%zd,远端流：%@",model.videoView.hasAudio,model.videoView.hasVideo, [model.videoView.remoteMuteStream mj_JSONObject]);
            model.closeMicrophone = state;
            VHInteractVideoCell *cell = (VHInteractVideoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:self.screenOrFileModel ? 1 : 0]];
            cell.model = model;
            break;
        }
    }
}

//某个视频摄像头开关改变
- (void)renderView:(VHRenderView *)renderView closeCamera:(BOOL)state {
    for(int i = 0 ; i < self.dadaSource.count ; i++) {
        VHLiveMemberModel *model = self.dadaSource[i];
        if(model.videoView == renderView) {
           // NSLog(@"是否有音频：%zd,是否有视频：%zd,远端流：%@",model.videoView.hasAudio,model.videoView.hasVideo, [model.videoView.remoteMuteStream mj_JSONObject]);
            model.closeCamera = state;
            VHInteractVideoCell *cell = (VHInteractVideoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:self.screenOrFileModel ? 1 : 0]];
            cell.model = model;
            break;
        }
    }
}

//某个视频麦克风开关改变
- (void)renderView:(VHRenderView *)renderView closeMicrophone:(BOOL)state {
    for(int i = 0 ; i < self.dadaSource.count ; i++) {
        VHLiveMemberModel *model = self.dadaSource[i];
        if(model.videoView == renderView) {
            model.closeMicrophone = state;
            VHInteractVideoCell *cell = (VHInteractVideoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:self.screenOrFileModel ? 1 : 0]];
            cell.model = model;
            break;
        }
    }
}

//主讲人（具有文档操作权限）视频
- (VHLocalRenderView *)docPermissionVideoView {
    for(VHLiveMemberModel *model in self.dadaSource) {
        if(model.haveDocPermission) {
            return model.videoView;
        }
    }
    return nil;
}

//共享屏幕或插播视频
- (VHLocalRenderView *)screenOrFileVideo {
    return self.screenOrFileModel.videoView;
}

- (NSMutableArray *)getMicUserList {
    return self.dadaSource;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.screenOrFileModel ? 2 : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.screenOrFileModel && section == 0) {
        return 1;
    }else {
        return self.dadaSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VHInteractVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VHInteractVideoCell" forIndexPath:indexPath];
    if(self.screenOrFileModel && indexPath.section == 0) {
        cell.model = self.screenOrFileModel;
    }else {
        cell.model = self.dadaSource[indexPath.item];
        //iPhoneX系列横屏调整
        if(iPhoneX && self.landScapeShow && (self.dadaSource.count == 1 || (indexPath.row % 4 == 2 || indexPath.row % 4 == 3))) {
            [cell adaptLandscapeiPhoneX:YES];
        }else {
            [cell adaptLandscapeiPhoneX:NO];
        }
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger pageIndex = scrollView.contentOffset.x / self.collectionView.width;
    self.pageControl.currentPage = pageIndex;
}


#pragma mark - HLHorizontalPageLayoutDetegate
- (CGSize)layout:(HLHorizontalPageLayout *)horizontalPageLayout itemSizeForSection:(NSInteger)section {
    if(self.screenOrFileModel && section == 0) { //插播/共享屏幕
        CGFloat width = self.landScapeShow ? VHScreenHeight : VHScreenWidth;
        return CGSizeMake(width, width);
    }else {
        if(self.dadaSource.count == 1) { //一个画面时的布局
            CGFloat width = self.landScapeShow ? VHScreenHeight : VHScreenWidth;
            return CGSizeMake(width,width);
        }else {
            CGFloat width = self.landScapeShow ? VHScreenHeight : VHScreenWidth;
            CGFloat sizeWH = (width - 1)/2.0;
            return CGSizeMake(sizeWH, sizeWH);
        }
    }
}

- (UIEdgeInsets)layout:(HLHorizontalPageLayout *)horizontalPageLayout insetForSection:(NSInteger)section {
    if(self.screenOrFileModel && section == 0) {
        return UIEdgeInsetsZero;
    }else {
        return UIEdgeInsetsMake(0, 0.5, 0, 0.5);
    }
}


- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        HLHorizontalPageLayout *collectionViewLayout = [[HLHorizontalPageLayout alloc] init];
        collectionViewLayout.minimumInteritemSpacing = 1;
        collectionViewLayout.minimumLineSpacing = 1;
        collectionViewLayout.deslegate = self;
        _collectionViewLayout = collectionViewLayout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[VHInteractVideoCell class] forCellWithReuseIdentifier:@"VHInteractVideoCell"];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc]init];
        [_pageControl setPageIndicatorTintColor:MakeColorRGBA(0xFFFFFF, 0.3)];
        [_pageControl setCurrentPageIndicatorTintColor:MakeColorRGB(0xFFFFFF)];
        _pageControl.numberOfPages = 0;
        _pageControl.currentPage   = 0;
    }
    return _pageControl;
}

- (NSMutableArray<VHLiveMemberModel *> *)dadaSource
{
    if (!_dadaSource)
    {
        _dadaSource = [NSMutableArray array];
    }
    return _dadaSource;
}
@end
