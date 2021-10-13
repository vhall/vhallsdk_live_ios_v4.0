//
//  VHEndPublisherDetailView.m
//  UIModel
//
//  Created by leiheng on 2021/4/30.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHEndPublisherDetailView.h"
#import "VHLiveModel.h"
#import "VHEndPublisherCell.h"
#import "UIImageView+WebCache.h"

@interface VHEndPublisherDetailView ()<UICollectionViewDelegate,UICollectionViewDataSource>
/// 头像
@property (nonatomic , strong) UIImageView * headerImg;
/// 昵称
@property (nonatomic , strong) UILabel * nameLab;
/// 提示
@property (nonatomic , strong) UILabel * remindLab;
/// ListCV
@property (nonatomic , strong) UICollectionView * listCV;
/// 数据源
@property (nonatomic , strong) NSArray <VHEndPublisherCellModel *> *listArray;
/** 直播信息 */
@property (nonatomic, strong) VHLiveModel *liveModel;
/** 模糊背景 */
@property (nonatomic, strong) UIVisualEffectView *effectView;
/** 互动直播、音频直播、横屏视频直播的背景图 */
@property (nonatomic, strong) UIImageView *bgView;
@end

@implementation VHEndPublisherDetailView

- (instancetype)initWithLiveModel:(VHLiveModel *)liveModel
{
    self = [super init];
    
    if (self) {
        self.liveModel = liveModel;
        [self configDataWithLiveModel:liveModel];
        
        [self addSubview:self.bgView];
        
        [self addSubview:self.effectView];
        
        [self addSubview:self.headerImg];
        
        [self addSubview:self.nameLab];
        
        [self addSubview:self.remindLab];

        [self addSubview:self.listCV];
        
        self.backgroundColor = [UIColor clearColor];
        if(self.liveModel.webinar_layout == VHLiveType_Video) {
            self.bgView.hidden = YES;
            self.effectView.hidden = NO;
        }else {
            self.bgView.hidden = NO;
            self.effectView.hidden = YES;
        }

        [self setupUI];
    }
    return self;
}

- (void)configDataWithLiveModel:(VHLiveModel *)liveModel {
    self.nameLab.text = self.liveModel.webinar_user_nick;
    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:[UIModelTools httpPrefixImgUrlStr:liveModel.webinar_user_icon]] placeholderImage:nil];
    
    VHEndPublisherCellModel *model1 = [[VHEndPublisherCellModel alloc] init];
    model1.title = @"直播时长";
    model1.titleValue = liveModel.liveDuration;
//    VHEndPublisherCellModel *model2 = [[VHEndPublisherCellModel alloc] init];
//    model2.title = @"最高并发";
//    model2.titleValue = [NSString stringWithFormat:@"%zd",liveModel.concurrentNum];
//    VHEndPublisherCellModel *model3 = [[VHEndPublisherCellModel alloc] init];
//    model3.title = @"累计观看";
//    model3.titleValue = [NSString stringWithFormat:@"%zd",liveModel.pageView];
//    VHEndPublisherCellModel *model4 = [[VHEndPublisherCellModel alloc] init];
//    model4.title = @"聊天条数";
//    model4.titleValue = [NSString stringWithFormat:@"%zd",liveModel.chatNum];
//    self.listArray = @[model1,model2,model3,model4];
    self.listArray = @[model1];
}

#pragma mark --- 初始化控件
- (void)setupUI
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).offset(160);
        make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerImg.mas_centerX);
        make.top.mas_equalTo(self.headerImg.mas_bottom).offset(12);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
    }];
    
    [self.remindLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.nameLab.mas_centerX);
        make.top.mas_equalTo(self.nameLab.mas_bottom).offset(25);
    }];
    
    [self.listCV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remindLab.mas_bottom).offset(40);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(@(220));
    }];
}
#pragma mark  设置CollectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"VHEndPublisherCell";
    VHEndPublisherCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.model = self.listArray[indexPath.row];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake(130, 60);
    return CGSizeMake(280, 60);
}

#pragma mark - 懒加载
- (UIImageView *)headerImg {
    if (!_headerImg) {
        _headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        _headerImg.contentMode = UIViewContentModeScaleAspectFill;
        _headerImg.backgroundColor = [UIColor whiteColor];
        _headerImg.layer.masksToBounds = YES;
        _headerImg.layer.cornerRadius = 75/2;
    }return _headerImg;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [UILabel new];
        _nameLab.text = @" ";
        _nameLab.textColor = MakeColorRGB(0xF7F7F7);
        _nameLab.font = FONT_FZZZ(16);
        _nameLab.textAlignment = NSTextAlignmentCenter;
    }return _nameLab;
}
- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [UILabel new];
        _remindLab.text = @"您的直播真精彩";
        _remindLab.textColor = MakeColorRGBA(0xFC5659,0.8);
        _remindLab.font = FONT_Medium(20);
        _remindLab.textAlignment = NSTextAlignmentCenter;
    }return _remindLab;
}

- (UICollectionView *)listCV {
    if (!_listCV) {
        UICollectionViewFlowLayout *listLayout = [[UICollectionViewFlowLayout alloc] init];
        listLayout.minimumLineSpacing = 15;
        listLayout.minimumInteritemSpacing = 15;
//        listLayout.sectionInset = UIEdgeInsetsMake(0, (VHScreenWidth - 130 * 2 - 15)/2.0, 0, (VHScreenWidth - 130 * 2 - 15)/2.0);
        [listLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _listCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:listLayout];
        _listCV.backgroundColor = [UIColor clearColor];
        _listCV.showsHorizontalScrollIndicator = NO;
        _listCV.layer.masksToBounds = YES;
        _listCV.delegate = self;
        _listCV.dataSource = self;
        _listCV.scrollEnabled = NO;
        [_listCV registerClass:[VHEndPublisherCell class] forCellWithReuseIdentifier:@"VHEndPublisherCell"];
    }
    return _listCV;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView)
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    }
    return _effectView;
}

- (UIImageView *)bgView {
    if (!_bgView)
    {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = BundleUIImage(@"live_end_bg");
    }
    return _bgView;
}

@end
