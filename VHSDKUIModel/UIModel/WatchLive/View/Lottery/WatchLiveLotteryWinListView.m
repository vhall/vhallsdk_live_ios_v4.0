
//
//  WatchLiveLotteryWinListView.m
//  UIModel
//
//  Created by xiongchao on 2020/9/9.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "WatchLiveLotteryWinListView.h"
#import "WatchLiveLotteryTableViewCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
@interface WatchLiveLotteryWinListView () <UITableViewDelegate,UITableViewDataSource>
/// 奖品icon
@property (nonatomic, strong) UIImageView *awardIcon;
/// 奖品名称
@property (nonatomic, strong) UILabel *awardNameLab;
/// 中奖列表
@property (nonatomic, strong) UITableView *winTableView;
/// 奖品信息
@property (nonatomic, strong) VHallAwardPrizeInfoModel *prizeInfo;
/// 中奖名单
@property (nonatomic, strong) NSArray <VHallLotteryResultModel *> * winList;

@end

@implementation WatchLiveLotteryWinListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.awardIcon];
    [self addSubview:self.awardNameLab];
    [self addSubview:self.winTableView];
    
    [self.awardIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(60, 60)));
        make.top.mas_equalTo(@(20));
        make.centerX.equalTo(self);
    }];
    
    [self.awardNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.awardIcon.mas_bottom).offset(10);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
    }];
    
    [self.winTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.awardNameLab.mas_bottom).offset(13);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.bottom.equalTo(self).offset(-15);
    }];
}


//设置奖品信息和中奖名单信息
- (void)setLotteryPrizeInfo:(VHallAwardPrizeInfoModel *)prizeInfo winList:(NSArray <VHallLotteryResultModel *> *)winList; {
    
    self.prizeInfo = prizeInfo;
    self.winList = winList;
    [self.winTableView reloadData];
    self.awardNameLab.text = prizeInfo.awardName;
    [self.awardIcon sd_setImageWithURL:[NSURL URLWithString:prizeInfo.awardIcon] placeholderImage:BundleUIImage(@"插图_礼物_已中奖")];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.winList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WatchLiveLotteryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WatchLiveLotteryTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.winList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 35)];
    sectionHeader.backgroundColor = MakeColorRGB(0xF5F5F5);
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"中奖名单";
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textColor = MakeColorRGB(0x222222);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [sectionHeader addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sectionHeader);
    }];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    [sectionHeader addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.right.equalTo(sectionHeader);
        make.height.equalTo(@(1));
    }];
    return sectionHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIImageView *)awardIcon
{
    if (!_awardIcon)
    {
        _awardIcon = [[UIImageView alloc] init];
        _awardIcon.contentMode = UIViewContentModeScaleAspectFill;
        _awardIcon.clipsToBounds = YES;
        _awardIcon.layer.cornerRadius = 30;
        _awardIcon.image = BundleUIImage(@"插图_礼物_已中奖");
    }
    return _awardIcon;
}

- (UILabel *)awardNameLab
{
    if (!_awardNameLab)
    {
        _awardNameLab = [[UILabel alloc] init];
        _awardNameLab.textColor = MakeColorRGB(0x222222);
        _awardNameLab.font = [UIFont systemFontOfSize:16];
        _awardNameLab.textAlignment = NSTextAlignmentCenter;
    }
    return _awardNameLab;
}

- (UITableView *)winTableView
{
    if (!_winTableView)
    {
        _winTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _winTableView.backgroundColor = MakeColorRGB(0xF5F5F5);
        _winTableView.layer.cornerRadius = 8;
        _winTableView.layer.masksToBounds = YES;
        _winTableView.delegate = self;
        _winTableView.dataSource = self;
        _winTableView.rowHeight = 40;
        _winTableView.tableFooterView = [[UIView alloc] init];
        NSString *classStr = NSStringFromClass([WatchLiveLotteryTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:classStr bundle:UIModelBundle];
        [_winTableView registerNib:nib forCellReuseIdentifier:classStr];
    }
    return _winTableView;
}
@end
