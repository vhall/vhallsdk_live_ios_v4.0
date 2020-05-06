//
//  DLNAView.m
//  UIModel
//
//  Created by yangyang on 2017/9/3.
//  Copyright © 2017年 www.vhall.com. All rights reserved.
//

#import "DLNAView.h"
#import "VHDLNAControl.h"
#import "DeviceTableViewCell.h"
#define DEVICE_CELL_ID @"DeviceCell"
//#import "VHallConst.h"
@interface DLNAView ()<UITableViewDataSource,UITableViewDelegate,VHDLNAControlDelegate>

@property(nonatomic,strong) VHDLNAControl *control;

@property(nonatomic,strong) UIView      *contentView;//容器view
@property(nonatomic,strong) UIButton    *closeBtn;
@property(nonatomic,strong) UIButton    *deviceNameBtn;
@property(nonatomic,strong) UITableView *deviceTableView;

@property(nonatomic,strong) UIView      *controlView;//控制 view
@property(nonatomic,strong) UIButton    *playBtn;
@property(nonatomic,strong) UILabel     *curTimeLb;
@property(nonatomic,strong) UISlider    *timeSlider;
@property(nonatomic,strong) UILabel     *durationLb;
@property(nonatomic,strong) UIButton    *volumeBtn;

@end

@implementation DLNAView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _type = 0;
        [self initUI];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame type:(int)type
{
    if (self = [super initWithFrame:frame])
    {
        _type = type;
        [self initUI];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

//show
- (BOOL)showInView:(UIView*)view moviePlayer:(VHallMoviePlayer  *)moviePlayer
{
    if([moviePlayer dlnaMappingObject:self.control])
    {
        self.frame = view.bounds;
        [view addSubview:self];
        if(_type == 1)
            self.curTime = moviePlayer.currentPlaybackTime;
        return YES;
    }
    return NO;
}

//- (void)onChange {
//    int count = (int)[[[DLNAUpnpServer shareServer] getDeviceList] count];
//        _findDeviceCount.text = [[NSString alloc] initWithFormat:@"%d", count];
//    
//    if (count>0) {
//        [_deviceTableView reloadData];
//    }
//}

- (void)initUI
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(15, self.height/2.0-150, VHScreenWidth-30, 300)];
    _contentView.backgroundColor = MakeColorRGB(0xE2E8EB);
    _contentView.layer.cornerRadius = 10;
    [self addSubview:_contentView];
    
    _deviceNameBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, 40)];
    [_deviceNameBtn setTitle:@"未选择设备" forState:UIControlStateNormal];
    if(self.control.curDevice)
        [_deviceNameBtn setTitle:self.control.curDevice.name forState:UIControlStateNormal];
    
    [_deviceNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_deviceNameBtn addTarget:self action:@selector(deviceNameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_deviceNameBtn setImage:BundleUIImage(@"DLNA_show") forState:UIControlStateNormal];
    [_deviceNameBtn setImage:BundleUIImage(@"DLNA_hide") forState:UIControlStateSelected];
    [_contentView addSubview:_deviceNameBtn];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_contentView.width-40, 0, 40, 40)];
    [_closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:BundleUIImage(@"DLNA_close") forState:UIControlStateNormal];
    [_contentView addSubview:_closeBtn];
        
    _controlView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentView.height/2.0-20, _contentView.width, 40)];
    _controlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_contentView addSubview:_controlView];
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, _controlView.height)];
    [_playBtn addTarget:self action:@selector(playDLNA:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:BundleUIImage(@"DLNA_Pause") forState:UIControlStateNormal];
    [_playBtn setImage:BundleUIImage(@"DLNA_Play") forState:UIControlStateSelected];
    [_controlView addSubview:_playBtn];
    
    _curTimeLb = [[UILabel alloc]initWithFrame:CGRectMake(_playBtn.right, 0, 60, _controlView.height)];
    _curTimeLb.text = @"00:00:00";
    _curTimeLb.textAlignment = NSTextAlignmentCenter;
    _curTimeLb.textColor = [UIColor whiteColor];
    _curTimeLb.font = [UIFont systemFontOfSize:12];
    [_controlView addSubview:_curTimeLb];

    _durationLb = [[UILabel alloc]initWithFrame:CGRectMake(_controlView.width-_curTimeLb.width, 0, _curTimeLb.width, _controlView.height)];
    _durationLb.text = @"00:00:00";
    _durationLb.textAlignment = NSTextAlignmentCenter;
    _durationLb.font = [UIFont systemFontOfSize:12];
    _durationLb.textColor = [UIColor whiteColor];
    [_controlView addSubview:_durationLb];
    
    _timeSlider  = [[UISlider alloc] initWithFrame:CGRectMake(_curTimeLb.right, 0, _durationLb.left-_curTimeLb.right, _controlView.height)];
    [_timeSlider setThumbImage:BundleUIImage(@"DLNA_seekbar") forState:UIControlStateNormal];
    [_timeSlider addTarget:self action:@selector(timeSliderEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_timeSlider addTarget:self action:@selector(timeSliderEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_timeSlider addTarget:self action:@selector(timeSliderEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_timeSlider addTarget:self action:@selector(timeSliderEventTouchUpCancel:) forControlEvents:UIControlEventTouchCancel];
    [_timeSlider addTarget:self action:@selector(timeSliderEventTouchUpCancel:) forControlEvents:UIControlEventTouchUpOutside];
    _timeSlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.5];
    [_controlView addSubview:_timeSlider];
    
    _deviceTableView =[[UITableView alloc] initWithFrame:CGRectMake(self.width/4, 30, self.width/2, 200)];
    _deviceTableView.dataSource = self;
    _deviceTableView.delegate = self;
    _deviceTableView.hidden = YES;
    _deviceTableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_contentView addSubview:_deviceTableView];
    [_deviceTableView registerClass:DeviceTableViewCell.class forCellReuseIdentifier:DEVICE_CELL_ID];
}

- (void)setType:(int)type
{
    _type = type;
    _durationLb.hidden = (_type == 0);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return   self.deviceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = (DeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:DEVICE_CELL_ID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DEVICE_CELL_ID];
    }

    VHDLNADevice *device = [_deviceArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = device.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.control.curDevice = [_deviceArray objectAtIndex:indexPath.row];
    [self deviceNameBtnClicked:_deviceNameBtn];
    [_deviceNameBtn setTitle:self.control.curDevice.name forState:UIControlStateNormal];
}


-(void)layoutSubviews
{
}
#pragma mark - contorl
- (void)play
{
    [self.control playSuccess:^{
        
    } failure:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
            [self.delegate dlnaControlState:DLNAControlType_PALY errormsg:error.description];
        }
    }];
}
- (void)pause
{
    [self.control pauseSuccess:^{
        
    } failure:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
            [self.delegate dlnaControlState:DLNAControlType_PAUSE errormsg:error.description];
        }
    }];
}
- (void)stop
{
    [self.control stopSuccess:^{
        
    } failure:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
            [self.delegate dlnaControlState:DLNAControlType_STOP errormsg:error.description];
        }
    }];
}

- (void)seek:(NSInteger)seekpos
{
    if(self.type == 1)
    {
        [self.control seek:seekpos success:^{
                           
        } failure:^(NSError *error) {
            if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
                [self.delegate dlnaControlState:DLNAControlType_SEEK errormsg:error.description];
            }
        }];
    }
}


#pragma mark - btnClicked
-(void)deviceNameBtnClicked:(UIButton*)btn
{
    _deviceTableView.hidden = btn.selected;
    btn.selected = !btn.selected;
}

-(void)playDLNA:(UIButton*)btn
{
    if(self.control.deviceState == VHDLNADeviceStatePause)
    {
        [self.control playSuccess:^{

        } failure:^(NSError * error) {
            if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
                [self.delegate dlnaControlState:DLNAControlType_PALY errormsg:error.description];
            }
        }];
    }
    else if(self.control.deviceState == VHDLNADeviceStatePlaying)
    {
        [self.control pauseSuccess:^{
            
        } failure:^(NSError * error) {
            if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
                [self.delegate dlnaControlState:DLNAControlType_PAUSE errormsg:error.description];
            }
        }];
    }
    else
    {
        __weak typeof(self) wf = self;
        [self.control startSuccess:^{
            if(wf.type == 1 && wf.curTime>0)
            {
                [wf seek:wf.curTime];
            }
        } failure:^(NSError * error) {
            if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
                [self.delegate dlnaControlState:DLNAControlType_START errormsg:error.description];
            }
        }];
    }
}

- (void)timeSliderEventTouchDown:(UISlider*)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [self pause];
}
- (void)timeSliderEventValueChanged:(UISlider*)slider
{
    self.curTimeLb.text  = [VHDLNAControl timeStringFromInteger:slider.value];
}

- (void)timeSliderEventTouchUpInside:(UISlider*)slider
{
//    __weak typeof(self) wf =self;
    [self.control seek:slider.value success:^{
//         [wf play];
    } failure:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dlnaControlState:errormsg:)]) {
            [self.delegate dlnaControlState:DLNAControlType_SEEK errormsg:error.description];
        }
    }];
    [self updateControlUI];
}
- (void)timeSliderEventTouchUpCancel:(UISlider*)slider
{
//    [self play];
    [self updateControlUI];
}

-(void)close:(UIButton*)btn
{
    [self stop];
    if(_closeBlock)
        _closeBlock();
    [self removeFromSuperview];
}

-(VHDLNAControl *)control
{
    if (!_control) {
        _control=[[VHDLNAControl alloc] init];
        _control.delegate = self;
    }
    return _control;
}
- (NSMutableArray *)deviceArray
{
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }return _deviceArray;
}
#pragma mark - 更新进度
- (void)updateControlUI
{
    if(self.control.deviceState == VHDLNADeviceStatePlaying)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        __weak typeof(self) wf = self;
        [self.control getPositionInfoSuccess:^(NSString *currentDuration, NSString *totalDuration) {
            wf.curTimeLb.text  = currentDuration;
            wf.durationLb.text = totalDuration;
            wf.curTime  = self.control.curTime;
            wf.timeSlider.minimumValue = 0;
            wf.timeSlider.maximumValue = self.control.duration;
            wf.timeSlider.value =  self.control.curTime;
        } failure:^(NSError *error) {
            
        }];
    

        [self performSelector:@selector(updateControlUI) withObject:nil afterDelay:1];
    }
}

#pragma mark - VHDLNAControlDelegate
-(void)deviceList:(NSArray*)deviceList
{
    self.deviceArray = [NSMutableArray arrayWithArray:deviceList];
    
    if (deviceList.count >0 ) {
        [_deviceTableView reloadData];
    }
    else
        [_deviceNameBtn setTitle:@"未选择设备" forState:UIControlStateNormal];
}
-(void)deviceStateChange:(VHDLNADeviceState)deviceState
{
    switch (deviceState) {
        case VHDLNADeviceStateNone:
            self.playBtn.selected = NO;
            break;
        case VHDLNADeviceStateStoped://结束
            self.playBtn.selected = NO;
        break;
        case VHDLNADeviceStateSetUrled://设置Url完成

        break;
        case VHDLNADeviceStatePlaying://播放中
            self.playBtn.selected = YES;
            [self updateControlUI];
        break;
        case VHDLNADeviceStatePause://暂停
            self.playBtn.selected = NO;
        break;
        default:
            break;
    }
}
@end
