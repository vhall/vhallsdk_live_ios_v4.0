//
//  VHEndPublisherVC.m
//  UIModel
//
//  Created by leiheng on 2021/4/30.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHEndPublisherVC.h"
#import "VHEndPublisherDetailView.h"

@interface VHEndPublisherVC ()
/// 详情
@property (nonatomic , strong) VHEndPublisherDetailView * detailView;
/// 返回首页
@property (nonatomic , strong) UIButton *backHomeBtn;
@end

@implementation VHEndPublisherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.backHomeBtn];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.backHomeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        make.height.equalTo(@(45));
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(280));
    }];
}

#pragma mark - 返回
- (void)backHomeBtnClick
{
    if([self.delegate respondsToSelector:@selector(endPublisherBackAction:)]) {
        [self.delegate endPublisherBackAction:self];
    }
}

#pragma mark - 懒加载
- (VHEndPublisherDetailView *)detailView
{
    if (!_detailView) {
        _detailView = [[VHEndPublisherDetailView alloc] initWithLiveModel:self.liveModel];
    }return _detailView;
}

- (UIButton *)backHomeBtn
{
    if (!_backHomeBtn) {
        _backHomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backHomeBtn.backgroundColor = MakeColorRGBA(0xFC5659,0.8);
        [_backHomeBtn setTitle:@"返回首页" forState:UIControlStateNormal];
        _backHomeBtn.layer.cornerRadius = 45/2.0;
        _backHomeBtn.layer.masksToBounds = YES;
        [_backHomeBtn addTarget:self action:@selector(backHomeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }return _backHomeBtn;
}
@end
