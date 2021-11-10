//
//  MainViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "LoginViewController.h"
#import "VHHomeViewController.h"
#import "UIModel.h"

//#import "WHDebugToolManager.h"

@interface LoginViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIControl *contentView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

//注册账号登录
@property (weak, nonatomic) IBOutlet UIView *accountLoginView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField; //账号
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField; //密码

//免注册登录
@property (weak, nonatomic) IBOutlet UIView *thirdIdLoginView;
@property (weak, nonatomic) IBOutlet UITextField *thirdIdTextField; //三方账号id
@property (weak, nonatomic) IBOutlet UITextField *thirdNameTextField; //昵称
@property (weak, nonatomic) IBOutlet UITextField *thirdAvatarTextField; //头像

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *accountLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirdIdLoginBtn;

@end

@implementation LoginViewController

#pragma mark - Private Method

-(void)initDatas
{
//   EnableVHallDebugModel(NO);
}

- (void)initViews
{
    _versionLabel.text      = [NSString stringWithFormat:@"v%@",[VHallApi sdkVersion]];
    _accountTextField.text  = DEMO_Setting.account;
    _passwordTextField.text = DEMO_Setting.password;
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentViewAction)]];
}

- (void)tapContentViewAction {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

//登录
- (IBAction)loginBtnClick:(id)sender
{
    [self closeKeyBtnClick:nil];

    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])//此处只用于提示信息判断，只替换CONSTS.h中的AppKey即可
    {
        VH_ShowToast(@"请填写CONSTS.h中的AppKey");
        return;
    }
    
    if(self.accountLoginBtn.selected) {
        [self accountLogin];
    }else {
        [self thirdIdLogin];
    }
}

//注册账号登录
- (void)accountLogin{
    if(_accountTextField.text.length <= 0 || _passwordTextField.text.length <= 0) {
        VH_ShowToast(@"账号或密码不能为空");
        return;
    }
    
    DEMO_Setting.account  = _accountTextField.text;
    DEMO_Setting.password = _passwordTextField.text;
    __weak typeof(self) weekself = self;
    [ProgressHud showLoading];
    [VHallApi loginWithAccount:DEMO_Setting.account password:DEMO_Setting.password success:^{
        
        [ProgressHud hideLoading];
        VHLog(@"Account: %@ userID:%@",[VHallApi currentAccount],[VHallApi currentUserID]);
        VH_ShowToast(@"登录成功");
        VHHomeViewController *homeVC=[[VHHomeViewController alloc] init];
        homeVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [weekself presentViewController:homeVC animated:YES completion:nil];
        
    } failure:^(NSError * error) {
        VHLog(@"登录失败%@",error);
        VH_ShowToast(error.domain);
    }];
}

//第三方id登录
- (void)thirdIdLogin {
    if(_thirdIdTextField.text.length <= 0) {
        VH_ShowToast(@"三方ID不能为空");
        return;
    }

    DEMO_Setting.third_Id = self.thirdIdTextField.text;
    DEMO_Setting.third_nickName = self.thirdNameTextField.text;
    DEMO_Setting.third_avatar = self.thirdAvatarTextField.text;

    __weak typeof(self) weekself = self;
    [ProgressHud showLoading];
    [VHallApi loaginWithThirdUserId:DEMO_Setting.third_Id nickName:DEMO_Setting.third_nickName avatar:DEMO_Setting.third_avatar success:^{

        [ProgressHud hideLoading];
        VHLog(@"Account: %@ userID:%@",[VHallApi currentAccount],[VHallApi currentUserID]);
        VH_ShowToast(@"登录成功");
        
        VHHomeViewController *homeVC=[[VHHomeViewController alloc] init];
        homeVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [weekself presentViewController:homeVC animated:YES completion:nil];
    } failure:^(NSError *error) {

        VHLog(@"登录失败%@",error);
        VH_ShowToast(error.domain);
    }];
}


//注册账号登录
- (IBAction)accountLoginBtnClick:(UIButton *)sender {
    self.accountLoginBtn.selected = YES;
    self.thirdIdLoginBtn.selected = NO;
    self.accountLoginView.hidden = NO;
    self.thirdIdLoginView.hidden = YES;
    _accountTextField.text  = DEMO_Setting.account;
    _passwordTextField.text = DEMO_Setting.password;
}

//第三方id登录
- (IBAction)thirdIdLoginBtnClick:(UIButton *)sender {
    self.accountLoginBtn.selected = NO;
    self.thirdIdLoginBtn.selected = YES;
    self.accountLoginView.hidden = YES;
    self.thirdIdLoginView.hidden = NO;
    _thirdIdTextField.text  = DEMO_Setting.third_Id;
    _thirdNameTextField.text = DEMO_Setting.third_nickName;
    _thirdAvatarTextField.text = DEMO_Setting.third_avatar;
}


- (IBAction)closeKeyBtnClick:(id)sender
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

#pragma mark - Lifecycle Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDatas];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    
    //测试工具
//    [[WHDebugToolManager sharedInstance] toggleWith:DebugToolTypeMemory | DebugToolTypeCPU | DebugToolTypeFPS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtnClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册热线：400-682-6882" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
//        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4006826882"];
//        WKWebView * callWebview = [[WKWebView alloc] init];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//        [self.view addSubview:callWebview];
        
        NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"4006826882"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    return YES;
}

@end
