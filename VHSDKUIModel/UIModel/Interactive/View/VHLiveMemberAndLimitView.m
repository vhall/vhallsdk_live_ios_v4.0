//
//  VHLiveMemberAndLimitView.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveMemberAndLimitView.h"
#import "VHLiveMemberAndLimitBaseCell.h"
#import "VHSegmentView.h"
#import "VHLiveMemberListView.h"
#import "VHLiveLimitListView.h"

@interface VHLiveMemberAndLimitView() <UIScrollViewDelegate>
/** 弹窗内容view */
@property (nonatomic, strong) UIView *contentView;
/** 弹窗高度 (横屏下为弹窗宽度) */
@property (nonatomic, assign) CGFloat popViewLength;
/** 标题切换view */
@property (nonatomic, strong) VHSegmentView *titleView;
/** 承载成员列表/受限列表的父视图 */
@property (nonatomic, strong) UIScrollView *scrollView;
/** 成员列表 */
@property (nonatomic, strong) VHLiveMemberListView *memberListView;
/** 受限列表 */
@property (nonatomic, strong) VHLiveLimitListView *limitListView;
/** 当前选中index */
@property (nonatomic, assign) NSInteger currentSelectIndex;
/** 是否为互动直播，嘉宾端 */
@property (nonatomic, assign) BOOL isGuest;
/** 直播类型（不同直播类型下，成员列表展示不一样，需要记录这个值） */
@property (nonatomic, assign) VHLiveType liveType;
/** 嘉宾是否有成员管理权限 */
@property (nonatomic, assign) BOOL memberManage;
@end

@implementation VHLiveMemberAndLimitView

- (void)dealloc
{
    VUI_Log(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (instancetype)initWithRoom:(VHRoom *)room liveType:(VHLiveType)liveType isCuest:(BOOL)isGuest haveMembersManage:(BOOL)memberManage {
    self = [super init];
    if (self) {
        self.room = room;
        self.liveType = liveType;
        self.memberManage = memberManage;
        self.isGuest = isGuest;
        [self setupUI];
        [self configFrame];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    [self.contentView addSubview:self.titleView];
    [self.contentView addSubview:self.scrollView];
    
    _memberListView = [[VHLiveMemberListView alloc] initWithRoom:self.room liveState:self.liveType isGuest:self.isGuest haveMembersManage:self.memberManage];
    [self.scrollView addSubview:_memberListView];
    _limitListView = [[VHLiveLimitListView alloc] initWithRoom:self.room guest:self.isGuest haveMembersManage:self.memberManage];
    [self.scrollView addSubview:_limitListView];
    
    //监听屏幕旋转状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    if(!VH_KScreenIsLandscape) {
        self.contentView.layer.cornerRadius = 15;
        self.contentView.clipsToBounds = YES;
    }
}



- (void)configFrame {
    [self updateFrame];
    
    [_memberListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.width.height.equalTo(_scrollView);
    }];
    
    [_limitListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_memberListView.mas_right);
        make.top.bottom.right.width.height.equalTo(_scrollView);
    }];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.equalTo(@(VHSegmentViewHeight));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.titleView.mas_bottom);
    }];
}


- (void)updateFrame {
    self.popViewLength = VH_KScreenIsLandscape ? VHScreenHeight : VHScreenWidth * 2/3.0;
    if(VH_KScreenIsLandscape) { //横屏
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.top.equalTo(self);
            make.width.equalTo(@(self.popViewLength));
        }];
    }else { //竖屏
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@(self.popViewLength));
        }];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touches.anyObject locationInView:self];
    if(!CGRectContainsPoint(self.contentView.frame, touchPoint)){
        [self dismiss];
    }
}

//显示
- (void)showInView:(UIView *)view {
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    self.contentView.transform = VH_KScreenIsLandscape ? CGAffineTransformMakeTranslation(self.popViewLength, 0) : CGAffineTransformMakeTranslation(0, self.popViewLength);
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
        if(self.showBlock){
            self.showBlock();
        }
    }];
}

//移除
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.contentView.transform = VH_KScreenIsLandscape ? CGAffineTransformMakeTranslation(self.popViewLength, 0) : CGAffineTransformMakeTranslation(0, self.popViewLength);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.disMissBlock){
            self.disMissBlock();
        }
    }];
}

//取消
- (void)handleCancelEvent:(UIButton *)button {
    [self dismiss];
}

//屏幕旋转
- (void)statusBarOrientationChanged:(NSNotification *)noti{
    [self updateFrame];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    if(index != self.currentSelectIndex) {
        [self.titleView setIndicatorViewIndex:index];
        self.currentSelectIndex = index;
        [self loadNewDataWithIndex:index];
    }
}

//刷新数据
- (void)loadNewDataWithIndex:(NSInteger)index {
    if(index == 0) { //成员列表
        [self.memberListView reloadNewData];
    }if (index == 1) { //受限列表
        [self.limitListView reloadNewData];
    }
}

///更新成员列表与受限列表
- (void)updateListData {
    [self.memberListView reloadNewData];
    [self.limitListView reloadNewData];
}


#pragma mark - 懒加载

- (VHSegmentView *)titleView
{
    if (!_titleView)
    {
        NSArray *titles = @[@"成员列表",@"受限列表"];
        _titleView = [[VHSegmentView alloc] initWithItems:titles];
        @weakify(self);
        _titleView.clickBlock = ^(NSInteger index) {
            @strongify(self)
            self.currentSelectIndex = index;
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * index, 0) animated:YES];
            [self loadNewDataWithIndex:index];
        };
    }
    return _titleView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}


@end
