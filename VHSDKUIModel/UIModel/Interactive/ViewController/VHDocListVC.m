//
//  VHDocListVC.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHDocListVC.h"
#import "VHLiveDocListCell.h"
#import "VHDocListModel.h"
#import "VHRefreshHeader.h"
#import "VHRefreshFooter.h"
#import <VHInteractive/VHRoom.h>
@interface VHDocListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray <VHDocListModel *>* dataSource;
/** 页码 */
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation VHDocListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    [self loadDataWithPageNum:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpUI {
    
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.translucent = NO; //设置导航栏不透明
    bar.titleTextAttributes = @{NSForegroundColorAttributeName:MakeColorRGB(0x333333),NSFontAttributeName:FONT_Medium(17)};
    
    //设置导航栏背景并去除底部黑线
    [bar setBackgroundImage:[UIModelTools imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
    [bar setShadowImage:[UIModelTools imageWithColor:MakeColorRGB(0xE2E2E2) size:CGSizeMake(VHScreenWidth, 1/VHScreenScale)]];
    
    //设置UINavigationBar tintColor （UIBarButtonItem图片/文字颜色）
    [UINavigationBar appearance].tintColor = MakeColorRGB(0x222222);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:BundleUIImage(@"icon-backblack") style:UIBarButtonItemStyleDone target:self action:@selector(backItemClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"文档管理";
    self.emptyLab.text = @"您还没有文档，快去网页控制台资料管理上传吧";
    self.emptyIcon.image = BundleUIImage(@"icon-文档管理为空");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnClick:)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)backItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmBtnClick:(UIButton *)button {
    if(!self.selectIndexPath) {
        VH_ShowToast(@"请选择文档");
        return;
    }
    VHDocListModel *mdoel = self.dataSource[self.selectIndexPath.row];
    self.docSelectBlcok ? self.docSelectBlcok(mdoel.document_id) : nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadDataWithPageNum:(NSInteger)pageNum {
    @weakify(self);
    [self.room getDocListWithPageNum:pageNum pageSize:10 success:^(NSArray<VHRoomDocumentModel *> *list, BOOL haveNextPage) {
        @strongify(self);
        NSArray *docList = [VHDocListModel modelArrWithInteractDocModelArr:list];
        if (pageNum==1) {
            //如果之前有选中的文档且在第一页，维持选中状态
            if (self.selectIndexPath && self.dataSource.count > self.selectIndexPath.row) {
                NSString *selectDocId = @"";
                VHDocListModel *model = self.dataSource[self.selectIndexPath.row];
                selectDocId = model.document_id;
                [docList enumerateObjectsUsingBlock:^(VHDocListModel *docModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([docModel.document_id isEqualToString:selectDocId]) {
                        docModel.selected = YES;
                        *stop = YES;
                    }
                }];
            }
            
            [self.dataSource removeAllObjects];
        } else {
            self.pageNum++;
        }
        [self.tableView.mj_header endRefreshing];
        if (haveNextPage) {
            [self.tableView.mj_footer endRefreshing];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.dataSource addObjectsFromArray:docList];
        self.showEmptyView = self.dataSource.count == 0;
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = self.dataSource.count >= 0;
    } fail:^(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        VH_ShowToast(error.localizedDescription);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.mj_footer.hidden = self.dataSource.count == 0;
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHLiveDocListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VHLiveDocListCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[VHLiveDocListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([VHLiveDocListCell class])];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectIndexPath) {
        VHDocListModel *preMdoel = self.dataSource[self.selectIndexPath.row];
        preMdoel.selected = NO;
    }
    VHDocListModel *mdoel = self.dataSource[indexPath.row];
    mdoel.selected = YES;
    self.selectIndexPath = indexPath;
    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 75;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[VHLiveDocListCell class] forCellReuseIdentifier:NSStringFromClass([VHLiveDocListCell class])];
        @weakify(self);
        _tableView.mj_header = [VHRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadDataWithPageNum:1];
        }];
        _tableView.mj_footer = [VHRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self loadDataWithPageNum:self.pageNum + 1];
        }];
    }
    return _tableView;
}

- (NSMutableArray<VHDocListModel *> *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
