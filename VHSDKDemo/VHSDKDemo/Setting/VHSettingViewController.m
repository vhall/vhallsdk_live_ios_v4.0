//
//  VHSettingViewController.m
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "VHSettingViewController.h"
#import "VHSettingGroup.h"
#import "VHSettingTextFieldItem.h"
#import "VHSettingTableViewCell.h"
#import "VHSettingArrowItem.h"
#import "CustomPickerView.h"
#import <VHLiveSDK/VHallApi.h>

#define CLASSNAME   "VHAppSetViewController"

@interface VHSettingViewController()<UITableViewDataSource,UITableViewDelegate,CustomPickerViewDataSource,CustomPickerViewDelegate,UITextFieldDelegate>
{
    NSArray * _selectArray;
    
    NSMutableArray * _inavBtns;//互动设置btns

    VHSettingTextFieldItem *item00,*item01,*item02,*item03;
    VHSettingTextFieldItem *item10,*item11,*item12,*item13,*item14,*item15,*item16;
    VHSettingTextFieldItem *item20,*item21;
    VHSettingTextFieldItem *item30;

    UISwitch *_noiseSwitch;
    UISwitch *_beautifySwitch;
    UISwitch *_inavBeautifySwitch;
}
@property(nonatomic,strong) NSMutableArray *groups;

@property(nonatomic,strong) CustomPickerView    *pickerView;//选择框控件
@property(nonatomic,strong) UITableView         *tableView;
@property(nonatomic,strong) UITextField         *tempTextField;
@end

@implementation VHSettingViewController


-(NSMutableArray *)groups
{
    if (!_groups)
    {
        _groups = [NSMutableArray array];
    }
    return _groups;
}


-(void)initWithView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:)  name:UIKeyboardDidHideNotification object:nil];
    
    [[UIApplication sharedApplication].keyWindow setBackgroundColor:[UIColor whiteColor]];
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (iPhoneX?88:64))];
    headerView.backgroundColor= MakeColorRGB(0xEC3544);
    [self.view insertSubview:headerView atIndex:0];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0,(iPhoneX?40:20), 44, 44)];
    [back setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:back];

    UILabel *title=[[UILabel alloc] init];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"参数设置"];
    [title setFont:[UIFont systemFontOfSize:18]];
    [title sizeToFit];
    title.center = CGPointMake(headerView.center.x, (iPhoneX?64:40));
    [headerView addSubview:title];
    
    Class class= objc_getClass(CLASSNAME);
    if(class)
    {
        UIButton *appbtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.width-90,back.top, 80, back.height)];
        [appbtn setTitle:@"应用设置" forState:UIControlStateNormal];
        [appbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        appbtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [appbtn addTarget:self action:@selector(appBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:appbtn];
    }

    _pickerView = [CustomPickerView loadFromXib];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [_pickerView setTitle:@"请选择分辨率"];
    
    _noiseSwitch = [[UISwitch alloc]init];
    [_noiseSwitch addTarget:self action:@selector(noiseSwitch) forControlEvents:UIControlEventValueChanged];
    _beautifySwitch = [[UISwitch alloc]init];
    [_beautifySwitch addTarget:self action:@selector(beautifySwitch) forControlEvents:UIControlEventValueChanged];
    _inavBeautifySwitch = [[UISwitch alloc]init];
    [_inavBeautifySwitch addTarget:self action:@selector(inavBeautifySwitch) forControlEvents:UIControlEventValueChanged];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (iPhoneX?80:64), self.view.width, [UIScreen mainScreen].bounds.size.height-(iPhoneX?80:64)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionHeaderHeight = 35;
    _tableView.rowHeight = 44;
    [self.view addSubview:_tableView];
    if ([_tableView  respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [_tableView reloadData];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _selectArray = @[@"352X288",@"640X480",@"960X540",@"1280X720"];
    self.title = @"设置";
    [self setupGroup0];
    [self setupGroup1];
    [self setupGroup2];
    [self setupGroup3];
    [self initWithView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _pickerView.frame = [UIScreen mainScreen].bounds;

    item10.text = DEMO_Setting.liveToken;
}

- (void)viewWillLayoutSubviews
{
    _tableView.frame = CGRectMake(0, (iPhoneX?80:64), self.view.width, [UIScreen mainScreen].bounds.size.height-(iPhoneX?80:64));
}

-(void)setupGroup0
{
    item00 = [VHSettingTextFieldItem  itemWithTitle:@"活动ID"];
    item00.text=DEMO_Setting.watchActivityID;
    item01 = [VHSettingTextFieldItem  itemWithTitle:@"k值"];
    item01.text =  DEMO_Setting.kValue;
    item02 = [VHSettingTextFieldItem  itemWithTitle:@"缓冲时间"];
    item02.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.bufferTimes];
    item03 = [VHSettingTextFieldItem  itemWithTitle:@"超时时间"];
    item03.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.timeOut];
    VHSettingGroup *group= [VHSettingGroup groupWithItems:@[item00,item01,item02,item03]];
    group.headerTitle = @"看直播/回放";
    [self.groups addObject:group];
}

-(void)setupGroup1
{
    __weak typeof(self) weakSelf = self;
    item10 = [VHSettingTextFieldItem  itemWithTitle:@"直播token"];
    item10.text = DEMO_Setting.liveToken;
    item11 = [VHSettingTextFieldItem  itemWithTitle:@"活动ID"];
    item11.text =  DEMO_Setting.activityID;
    item12 = [VHSettingTextFieldItem  itemWithTitle:@"分辨率"];
    item12.text = _selectArray[[DEMO_Setting.videoResolution intValue]];
    item12.operation=^(NSIndexPath *indexPath)
    {
        [weakSelf.tempTextField endEditing:YES];
        [weakSelf.pickerView showPickerView:weakSelf.view];
    };
    item13 = [VHSettingTextFieldItem  itemWithTitle:@"视频码率(kpbs)"];
    item13.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoBitRate];
    item14 = [VHSettingTextFieldItem  itemWithTitle:@"视频帧率(fps)"];
    item14.text =  [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoCaptureFPS];
    item15 = [VHSettingTextFieldItem  itemWithTitle:@"音频码率(kpbs)"];
    item15.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.audioBitRate];
    item16 = [VHSettingTextFieldItem  itemWithTitle:@"主播昵称"];
    item16.text = DEMO_Setting.live_nick_name;
    VHSettingGroup *group= [VHSettingGroup groupWithItems:@[item10,item11,item12,item13,item14,item15,item16]];
    group.headerTitle = @"发直播";
    [self.groups addObject:group];
}

-(void)setupGroup2
{
    item20 = [VHSettingTextFieldItem  itemWithTitle:@"用户ID"];
    
    if ([VHallApi isLoggedIn])
    {
        item20.text =  DEMO_Setting.account;
    }else
    {
        item20.text =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    item21 = [VHSettingTextFieldItem  itemWithTitle:@"昵称"];
    item21.text = DEMO_Setting.nickName;
    
    VHSettingGroup *group= [VHSettingGroup groupWithItems:@[item20,item21]];
    group.headerTitle = @"其他";
    [self.groups addObject:group];
}
- (void)setupGroup3
{
    __weak typeof(self) weakSelf = self;
    item30 = [VHSettingTextFieldItem  itemWithTitle:@"分辨率"];
    item30.operation=^(NSIndexPath *indexPath)
    {
        [weakSelf.tempTextField endEditing:YES];
    };

    VHSettingGroup *group= [VHSettingGroup groupWithItems:@[item13]];
    group.headerTitle = @"互动直播";
    [self.groups addObject:group];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groups.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VHSettingGroup *group =self.groups[section];
    if(section == 1)
        return group.items.count+2;
    if(section == 3)
        return group.items.count+1;
    return group.items.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHSettingGroup *group=self.groups [indexPath.section];
    if(indexPath.section == 1)
    {
        if(indexPath.row == group.items.count) { //音频降噪
            static   NSString *Identifier = @"noiseSwitchCell";
            UITableViewCell *noiseSwitchcell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (noiseSwitchcell == nil)
                noiseSwitchcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            _noiseSwitch.on = DEMO_Setting.isOpenNoiseSuppresion;
            _noiseSwitch.left = self.view.width - 60;
            _noiseSwitch.top = 7;
            noiseSwitchcell.textLabel.text = @"  音频降噪";
            noiseSwitchcell.textLabel.font = [UIFont systemFontOfSize:14];
            [noiseSwitchcell.contentView addSubview:_noiseSwitch];
            
            return noiseSwitchcell;
        }else if (indexPath.row == group.items.count + 1) { //美颜
            static   NSString *Identifier = @"beautifySwitchcell";
            UITableViewCell *beautifySwitchcell =[tableView dequeueReusableCellWithIdentifier:Identifier];
            if (beautifySwitchcell == nil)
                beautifySwitchcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            beautifySwitchcell.textLabel.text = @"  美颜";
            beautifySwitchcell.textLabel.font = [UIFont systemFontOfSize:14];
            _beautifySwitch.on = DEMO_Setting.beautifyFilterEnable;
            _beautifySwitch.left = self.view.width - 60;
            _beautifySwitch.top = 7;
            [beautifySwitchcell.contentView addSubview:_beautifySwitch];
            
            return beautifySwitchcell;
        }
    }
    else if(indexPath.section == 3 && indexPath.row == 0)
    {
        static   NSString *identifier1 = @"selectedResolutionCell";
        UITableViewCell *resolutionCell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (resolutionCell == nil)
            resolutionCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        resolutionCell.textLabel.text = @"  分辨率";
        resolutionCell.textLabel.font = [UIFont systemFontOfSize:14];
        
        if(!_inavBtns)
        {
            _inavBtns = [NSMutableArray array];
            NSArray *titles = @[@" 省流",@" 流畅",@" 清晰",@" 标清"];
            float w = self.view.width - titles.count*60;
            for (int i = 0; i<titles.count; i++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setTitle:titles[i] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"resolution_normal"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"resolution_Selected"] forState:UIControlStateSelected];
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:15];
                button.frame = CGRectMake(w+i*60, 0, 60, 50);
                [resolutionCell.contentView addSubview:button];
                [_inavBtns addObject:button];
                [button addTarget:self action:@selector(selectedResolution:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
            }
        }
        [self selectedResolution:_inavBtns[DEMO_Setting.pushResolution.intValue]];
        return resolutionCell;
    }
    if(indexPath.section == 3 && indexPath.row == group.items.count)
    {
       static   NSString *Identifier = @"beautifySwitchcell";
       UITableViewCell *beautifySwitchcell =[tableView dequeueReusableCellWithIdentifier:Identifier];
       if (beautifySwitchcell == nil)
           beautifySwitchcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        beautifySwitchcell.textLabel.text = @"  互动美颜";
        beautifySwitchcell.textLabel.font = [UIFont systemFontOfSize:14];
       _inavBeautifySwitch.on = DEMO_Setting.inavBeautifyFilterEnable;
       _inavBeautifySwitch.left = self.view.width - 60;
       _inavBeautifySwitch.top = 7;
       [beautifySwitchcell.contentView addSubview:_inavBeautifySwitch];
       
       return beautifySwitchcell;
    }
 
    __weak typeof(self) weakSelf = self;
    VHSettingTableViewCell *cell =[VHSettingTableViewCell  cellWithTableView:tableView];
    VHSettingItem *item = group.items[indexPath.row];
    item.indexPath = indexPath;
    cell.item  = item;
    
    cell.inputText= ^(NSString *text)
    {
        if ([text isEqualToString:@""])
        {
            text = nil;
        }
        
        [weakSelf value:text indexPath:indexPath];
    };
    
    cell.changePosition=^(UITextField *textField)
    {
        weakSelf.tempTextField=textField;
    };
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VHSettingGroup *group = self.groups[indexPath.section];
    if(indexPath.section == 1 && (indexPath.row >= group.items.count))
    {
        return;
    }
    if(indexPath.section == 3) {
        return;
    }
    
    VHSettingItem  *item = group.items[indexPath.row];
    if (item.operation)
    {
        item.operation(indexPath);
    }else if ([item isKindOfClass:[VHSettingTextFieldItem class]])
    {
        
    }else if ([item isKindOfClass:[VHSettingArrowItem  class]])
    {
        VHSettingArrowItem *arrowItem = (VHSettingArrowItem*)item;
        if (arrowItem.desVc)
        {
            UIViewController *vc =[[arrowItem.desVc alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, VHScreenWidth, 30)];
    label.backgroundColor = MakeColorRGB(0xEFEFF4);
    label.textColor = MakeColorRGB(0xEC3544);
    label.font = [UIFont systemFontOfSize:14];
    VHSettingGroup *group =  self.groups[section];
    label.text = [NSString stringWithFormat:@"  %@",group.headerTitle];
    return label;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)selectedResolution:(UIButton *)sender {
    for (UIButton *button in _inavBtns) {
        button.selected = NO;
    }
    sender.selected = YES;
    DEMO_Setting.pushResolution = [NSString stringWithFormat:@"%ld",sender.tag];
}

- (void)showKeyboard:(NSNotification *)noti
{
    self.view.transform = CGAffineTransformIdentity;
    UIView *editView = _tempTextField;
    
    CGRect tfRect = [editView.superview convertRect:editView.frame toView:self.view];
    NSValue *value = noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"];
//    NSLog(@"%@", value);
    CGRect keyBoardF = [value CGRectValue];
    
    CGFloat animationTime = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGFloat _editMaxY = CGRectGetMaxY(tfRect);
    CGFloat _keyBoardMinY = CGRectGetMinY(keyBoardF);
//    NSLog(@"%f %f", _editMaxY, _keyBoardMinY);
    if (_keyBoardMinY < _editMaxY) {
        CGFloat moveDistance = _editMaxY - _keyBoardMinY;
        [UIView animateWithDuration:animationTime animations:^{
            self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -moveDistance);
        }];
        
    }
}

- (void)hideKeyboard:(NSNotification *)noti
{
    [UIView beginAnimations:nil context:NULL];//此处添加动画，使之变化平滑一点
    [UIView setAnimationDuration:0.3];
    self.view.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
}


#pragma mark event
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

-(void)backBtnClicked:(UIButton*)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)appBtnClicked:(UIButton*)btn
{
    Class class= objc_getClass(CLASSNAME);
    if(class)
    {
        UIViewController* vc = ((UIViewController*)[[class alloc] init]);
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)customPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
{
    NSString * title =_selectArray[row];
    [item12 setText:title];
     DEMO_Setting.videoResolution =  [NSString stringWithFormat:@"%ld",(long)row];
    [_tableView reloadData];
    
}
#pragma mark - CustomPickerViewDataSource
- (NSString*)titleOfRowCustomPickerViewWithRow:(NSInteger)row
{
    NSString * title =_selectArray[row];
    return title;
}

- (NSInteger)numberOfRowsInPickerView
{
    return _selectArray.count;
}

-(void)value:(NSString*)text indexPath:(NSIndexPath*)indexpath
{
    if (indexpath.section == 1)
    {
        switch (indexpath.row)
        {
            case 0:
            {
                if(text.length == 32 || text.length == 0)
                    DEMO_Setting.liveToken = text;
                else
                    [self showMsg:@"Token长度错误" afterDelay:1.5];
                item10.text = DEMO_Setting.liveToken;
            }
                break;
            case 1:
            {
                DEMO_Setting.activityID = text;
                item11.text =  DEMO_Setting.activityID;
            }
                break;
            case 2:
                
                break;
            case 3:
            {
                DEMO_Setting.videoBitRate= [text integerValue];
                item13.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoBitRate];
            }
                break;
            case 4:
            {
                DEMO_Setting.videoCaptureFPS = [text integerValue];
                item14.text =  [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoCaptureFPS];
            }
                break;
            case 5:
            {
                 DEMO_Setting.audioBitRate = [text integerValue];
                 item15.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.audioBitRate];
            }
            case 6:
            {
                 DEMO_Setting.live_nick_name = text;
                 item15.text = [NSString stringWithFormat:@"%@",DEMO_Setting.live_nick_name];
            }
                break;
            default:
                break;
        }
    }else if (indexpath.section ==0)
    {
        switch (indexpath.row)
        {
            case 0:
            {
                DEMO_Setting.watchActivityID = text;
                item00.text=DEMO_Setting.watchActivityID;
            }
                break;
            case 1:
            {
                DEMO_Setting.kValue = text;
                item01.text =  DEMO_Setting.kValue;
            }
                break;
            case 2:
            {
                DEMO_Setting.bufferTimes = [text integerValue];
                item02.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.bufferTimes];
            }
                break;
            case 3:
            {
                DEMO_Setting.timeOut = [text integerValue];
                item03.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.timeOut];
            }
                break;
            default:
                break;
        }
    }else if (indexpath.section == 2)
    {
        switch (indexpath.row)
        {
            case 0:
                DEMO_Setting.account =text;
                break;
            case 1:
                DEMO_Setting.nickName =text;
                break;
            default:
                break;
        }
    }
}

- (void)noiseSwitch
{
    DEMO_Setting.isOpenNoiseSuppresion = _noiseSwitch.on;
}
- (void)beautifySwitch
{
    DEMO_Setting.beautifyFilterEnable = _beautifySwitch.on;
}
- (void)inavBeautifySwitch
{
    DEMO_Setting.inavBeautifyFilterEnable = _inavBeautifySwitch.on;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
     [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

-(BOOL)shouldAutorotate
{
    return NO;
}
@end













