//
//  WatchLiveLotteryViewController.m
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveLotteryViewController.h"
#import "WatchLiveLotteryTableViewCell.h"
#import <VHLiveSDK/VHallLottery.h>
#import "UIAlertController+ITTAdditionsUIModel.h"
#import "UIImageView+WebCache.h"
#import "WatchLiveLotteryWinListView.h"
#import "WatchLiveLotteryWriteWinInfoView.h"
#import "Masonry.h"
#import "MBProgressHUD.h"

@interface WatchLiveLotteryViewController () <WatchLiveLotteryWriteWinInfoViewDelegate>
/**  ----------抽奖结果View---------- */
@property (nonatomic, strong) UIView *lotteryResultView;
@property (nonatomic, strong) UIImageView *lotteryResultIcon; //抽奖结果图标
@property (nonatomic, strong) UILabel *lotteryResultText; //抽奖结果描述文字
@property (nonatomic, strong) UIButton *lotteryResultBtn; //抽奖结果按钮（未中奖——>查看中奖名单;中奖——>立即领奖）

/**  ----------中奖名单View---------- */
@property (nonatomic, strong) WatchLiveLotteryWinListView *winListView;

/**  ----------填写中奖信息View---------- */
@property (nonatomic, strong) WatchLiveLotteryWriteWinInfoView *writeWinInfoView;

@property (weak, nonatomic) IBOutlet UILabel *titleLab; //标题
@property (weak, nonatomic) IBOutlet UIButton *closeBtn; //关闭
@property (weak, nonatomic) IBOutlet UIImageView *lotteryGif; //正在抽奖动画
@property (weak, nonatomic) IBOutlet UIButton *passwordBtn;  //口令立即参与按钮
@property (weak, nonatomic) IBOutlet UILabel *lotteringText; //抽奖文案

@end

@implementation WatchLiveLotteryViewController

- (id)init
{
    self = LoadVCNibName;
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    if([UIModelTools isEmptyStr:self.startLotteryModel.title]) {
        self.titleLab.text = @"抽奖";
    }else {
        self.titleLab.text = self.startLotteryModel.title;
    }
    //动图
    if(![UIModelTools isEmptyStr:self.startLotteryModel.icon]) {
        [self.lotteryGif sd_setImageWithURL:[NSURL URLWithString:self.startLotteryModel.icon] placeholderImage:nil];
    }
    //是否口令抽奖
    if(self.startLotteryModel.type == 1) {
        self.passwordBtn.hidden = NO;
        NSString *text = [NSString stringWithFormat:@"发送口令“%@”参与抽奖吧!",self.startLotteryModel.command];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:MakeColorRGB(0x222222)}];
        NSRange range = [text rangeOfString:[NSString stringWithFormat:@"“%@”",self.startLotteryModel.command]];
        [attStr addAttributes:@{NSForegroundColorAttributeName : MakeColorRGB(0xFC5659)} range:range];
        self.lotteringText.attributedText = attStr;
    }else {
        self.passwordBtn.hidden = YES;
        //说明
        if([UIModelTools isEmptyStr:self.startLotteryModel.remark]) {
            self.lotteringText.text = @"正在进行抽奖...";
        }else {
            self.lotteringText.text = self.startLotteryModel.remark;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//结束抽奖
- (void)setEndLotteryModel:(VHallEndLotteryModel *)endLotteryModel
{
    _endLotteryModel = endLotteryModel;
    self.lotteryResultView.hidden = NO;
    if(endLotteryModel.isWin) { //自己中奖
        self.lotteryResultBtn.hidden = NO;
        [self.lotteryResultBtn setTitle:@"立即领奖" forState:UIControlStateNormal];
        self.lotteryResultText.text = [NSString stringWithFormat:@"中奖啦，\n恭喜您获得“%@”",endLotteryModel.prizeInfo.awardName ? endLotteryModel.prizeInfo.awardName : @"默认奖品"];
        self.lotteryResultText.textColor = MakeColorRGB(0xFF5659);
        [self.lotteryResultIcon sd_setImageWithURL:[NSURL URLWithString:endLotteryModel.prizeInfo.awardIcon] placeholderImage:BundleUIImage(@"插图_礼物_已中奖")];
    }else { //自己没有中奖
        self.lotteryResultBtn.hidden = (self.endLotteryModel.is_new && self.endLotteryModel.publish_winner == NO);
        [self.lotteryResultBtn setTitle:@"查看中奖名单" forState:UIControlStateNormal];
        self.lotteryResultText.text = @"很遗憾，\n您与大奖擦肩而过，感谢您的参与!";
        self.lotteryResultText.textColor = MakeColorRGB(0x222222);
        [self.lotteryResultIcon sd_setImageWithURL:[NSURL URLWithString:endLotteryModel.prizeInfo.awardIcon] placeholderImage:BundleUIImage(@"插图_礼物_未中奖")];
    }
}


//口令立即参与
- (IBAction)passwordBtnClick:(UIButton *)sender {
    //立即参与
    [_lottery lotteryParticipationSuccess:^{
        self.passwordBtn.hidden = YES;
        self.lotteringText.textColor = MakeColorRGB(0xFF5659);
        if([UIModelTools isEmptyStr:self.startLotteryModel.remark]) {
            self.lotteringText.text = @"正在进行抽奖...";
        }else {
            self.lotteringText.text = self.startLotteryModel.remark;
        }
    } failed:^(NSDictionary *failedData) {
        [UIModelTools showMsgInWindow:failedData[@"content"] afterDelay:2];
    }];
}


//关闭
- (IBAction)closeBtnClick:(id)sender
{
    self.view.hidden = YES;
}

//立即领奖/查看中奖名单
- (void)lotteryResultBtnClick:(UIButton *)button {
    if([button.titleLabel.text isEqualToString:@"立即领奖"]) { //领奖
        if(self.startLotteryModel.is_new) { //新版抽奖，填写项通过接口获取
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //获取输入项配置
            [_lottery getSubmitConfigSuccess:^(NSArray<VHallLotterySubmitConfig *> *submitList) {
                self.writeWinInfoView.submitConfigArr = submitList;
                self.writeWinInfoView.hidden = NO;
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            } failed:^(NSDictionary *failedData) {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [UIModelTools showMsgInWindow:failedData[@"content"] afterDelay:2];
            }];
        }else { //老版抽奖，填写项固定只能提交姓名、电话
            NSMutableArray <VHallLotterySubmitConfig *> *array = [NSMutableArray array];
            VHallLotterySubmitConfig *nameConfig = [[VHallLotterySubmitConfig alloc] init];
            nameConfig.field = @"姓名";
            nameConfig.placeholder = @"请输入姓名";
            nameConfig.is_required = 1;
            nameConfig.field_key = @"name";
            nameConfig.rank = 1;
            nameConfig.is_system = 1;
            [array addObject:nameConfig];
            
            VHallLotterySubmitConfig *phoneConfig = [[VHallLotterySubmitConfig alloc] init];
            phoneConfig.field = @"手机号";
            phoneConfig.is_required = 1;
            phoneConfig.field_key = @"phone";
            phoneConfig.placeholder = @"请输入手机号";
            phoneConfig.rank = 2;
            phoneConfig.is_system = 1;
            [array addObject:phoneConfig];
            self.writeWinInfoView.submitConfigArr = array;
            self.writeWinInfoView.hidden = NO;
        }
    }else if([button.titleLabel.text isEqualToString:@"查看中奖名单"]){ //查看中奖名单
        
        if(self.endLotteryModel.is_new) { //新版抽奖，请求接口获取中奖名单
            __weak __typeof(self)weakSelf = self;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_lottery getLotteryWinListSuccess:^(NSArray<VHallLotteryResultModel *> *submitList) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                //获取中奖名单
                [weakSelf.winListView setLotteryPrizeInfo:self.endLotteryModel.prizeInfo winList:submitList];
            } failed:^(NSDictionary *failedData) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [UIModelTools showMsgInWindow:failedData[@"content"] afterDelay:2];
            }];
        }else { //老版抽奖，无奖品信息，从抽奖结束消息里获取中奖名单
            [self.winListView setLotteryPrizeInfo:nil winList:self.endLotteryModel.resultModels];
        }
        
    }
}

#pragma mark - WatchLiveLotteryWriteWinInfoViewDelegate

//提交中奖信息
- (void)writeWinInfoView:(WatchLiveLotteryWriteWinInfoView *)writeWinInfoView submitWinInfo:(NSDictionary *)param {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_lottery submitLotteryInfo:param success:^{
        //提交成功
        self.writeWinInfoView.hidden = YES;
        self.lotteryResultIcon.image = BundleUIImage(@"插图_中奖_信息提交");
        self.lotteryResultText.text = @"信息提交成功";
        self.lotteryResultText.textColor = MakeColorRGB(0xFC5659);
        self.lotteryResultBtn.hidden = (self.endLotteryModel.is_new && self.endLotteryModel.publish_winner == NO);
        [self.lotteryResultBtn setTitle:@"查看中奖名单" forState:UIControlStateNormal];
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    } failed:^(NSDictionary *failedData) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [UIAlertController showAlertControllerTitle:@"信息提交失败" msg:failedData[@"content"] btnTitle:@"确定" callBack:nil];
    }];
}


//抽奖结果
- (UIView *)lotteryResultView
{
    if (!_lotteryResultView)
    {
        _lotteryResultView = [[UIView alloc] init];
        _lotteryResultView.backgroundColor = [UIColor whiteColor];
        _lotteryResultView.hidden = YES;
        [self.view addSubview:_lotteryResultView];
        [_lotteryResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLab.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
        
        _lotteryResultIcon = [[UIImageView alloc] init];
        _lotteryResultIcon.layer.cornerRadius = 50;
        _lotteryResultIcon.clipsToBounds = YES;
        [_lotteryResultView addSubview:_lotteryResultIcon];
        [_lotteryResultIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(100));
            make.top.equalTo(@20);
            make.centerX.equalTo(_lotteryResultView);
        }];
        
        _lotteryResultText = [[UILabel alloc] init];
        _lotteryResultText.font = [UIFont systemFontOfSize:16];
        _lotteryResultText.numberOfLines = 0;
        _lotteryResultText.textAlignment = NSTextAlignmentCenter;
        [_lotteryResultView addSubview:_lotteryResultText];
        [_lotteryResultText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_lotteryResultView);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(45);
            make.top.equalTo(_lotteryResultIcon.mas_bottom).offset(20);
        }];
        
        _lotteryResultBtn = [[UIButton alloc] init];
        _lotteryResultBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _lotteryResultBtn.layer.cornerRadius = 7;
        _lotteryResultBtn.clipsToBounds = YES;
        _lotteryResultBtn.backgroundColor = MakeColorRGB(0xFC5659);
        [_lotteryResultBtn addTarget:self action:@selector(lotteryResultBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lotteryResultView addSubview:_lotteryResultBtn];
        [_lotteryResultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(180);
            make.height.mas_equalTo(45);
            make.top.mas_equalTo(_lotteryResultText.mas_bottom).offset(20);
            make.centerX.mas_equalTo(_lotteryResultView);
        }];
    }
    return _lotteryResultView;
}

//获奖名单
- (WatchLiveLotteryWinListView *)winListView
{
    if (!_winListView)
    {
        _winListView = [[WatchLiveLotteryWinListView alloc] init];
        [self.view addSubview:_winListView];
        
        [_winListView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.titleLab.mas_bottom);
           make.left.right.bottom.equalTo(self);
        }];
    }
    return _winListView;
}

//填写中奖信息
- (WatchLiveLotteryWriteWinInfoView *)writeWinInfoView
{
    if (!_writeWinInfoView)
    {
        _writeWinInfoView = [[WatchLiveLotteryWriteWinInfoView alloc] init];
        _writeWinInfoView.delegate = self;
        [self.view addSubview:_writeWinInfoView];
        
        [_writeWinInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLab.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return _writeWinInfoView;
}

@end
