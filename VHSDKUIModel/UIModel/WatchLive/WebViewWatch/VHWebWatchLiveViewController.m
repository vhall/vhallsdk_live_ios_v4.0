//
//  VHWebWatchLiveViewController.m
//  UIModel
//
//  Created by xiongchao on 2020/10/29.
//  Copyright © 2020 www.vhall.com. All rights reserved.
//

#import "VHWebWatchLiveViewController.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>
#import <VHLiveSDK/VHallApi.h>

//旧版控制台
//#define WebWatchHost @"http://live.vhall.com/"  //正式环境

//新版控制台
//#define WebWatchHost @"https://t-webinar.e.vhall.com/v3/lives/watch/"  //测试环境
#define WebWatchHost @"https://live.vhall.com/v3/lives/watch/"  //正式环境


@interface VHWebWatchLiveViewController () <WKUIDelegate>
/** 观看地址 */
@property (nonatomic, strong) NSString *watchUrlStr;
/** webView */
@property (nonatomic, strong) WKWebView *webView;
/** 返回按钮 */
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation VHWebWatchLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(30, 30)));
        make.left.equalTo(@(15));
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(@(20));
        }
    }];
    
    [self loadUrl];
}

//加载url
- (void)loadUrl {
    self.watchUrlStr = [NSString stringWithFormat:@"%@%@",WebWatchHost,self.roomId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.watchUrlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.f];
    [self.webView loadRequest:request];
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:BundleUIImage(@"返回.png") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (WKWebView *)webView
{
    if (!_webView)
    {
        WKWebViewConfiguration *wkConfig = [[WKWebViewConfiguration alloc] init];
        wkConfig.allowsInlineMediaPlayback = YES; //允许视频非全屏播放
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkConfig];
        _webView.UIDelegate = self;
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    return _webView;
}


@end
