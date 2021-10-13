//
//  VHStystemSetting.m
//  
//
//  Created by vhall on 16/5/11.
//  Copyright (c) 2016年 www.vhall.com. All rights reserved.
//

#define VHDefaultAvatar @"https://cnstatic01.e.vhall.com/upload/users/face-imgs/24/b6/24b6f81b1a4985d7dcbbeccc707cd7b8.png"

#import "VHStystemSetting.h"

@implementation VHStystemSetting

static VHStystemSetting *_sharedSetting = nil;

+ (VHStystemSetting *)sharedSetting {
    return [[self alloc]init];
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSetting = [super allocWithZone:zone];
    });
    return _sharedSetting;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedSetting;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        _email = [standardUserDefaults objectForKey:@"VHuserID"];        //标示该游客用户唯一id 可填写用户邮箱  为空默认使用设备UUID做为唯一ID
        _kValue     = [standardUserDefaults objectForKey:@"VHkValue"];       //K值        可以为空
        _codeWord     = [standardUserDefaults objectForKey:@"VHCodeWord"];    //口令

        //直播设置
        _videoResolution= [standardUserDefaults objectForKey:@"VHvideoResolution"];//发起直播分辨率
        _liveToken      = [standardUserDefaults objectForKey:@"VHliveToken"];            //直播令牌
        _videoBitRate   = [standardUserDefaults integerForKey:@"VHbitRate"];              //发直播视频码率
        _audioBitRate   = [standardUserDefaults integerForKey:@"VHaudiobitRate"];              //发直播音频码率
        _videoCaptureFPS= [standardUserDefaults integerForKey:@"VHvideoCaptureFPS"];//发直播视频帧率 ［1～30］ 默认10
        _live_nick_name = [standardUserDefaults valueForKey:@"live_nick_name"]; //发直播昵称
        if(!_live_nick_name) {
            _live_nick_name = @"";
        }
        
        //观看设置
        _bufferTimes    = [standardUserDefaults integerForKey:@"VHbufferTimes"];          //RTMP观看缓冲时间
        _timeOut        = [standardUserDefaults integerForKey:@"VHtimeOut"];          //观看超时时间
        if(_timeOut<=0)
            _timeOut = 10;
        
        _account        = [standardUserDefaults objectForKey:@"VHaccount"];      //账号
        _password       = [standardUserDefaults objectForKey:@"VHpassword"];     //密码

        if(_liveToken  == nil)
        {
            _liveToken = DEMO_AccessToken;
        }
        
        if(_account == nil)
        {
            _account = DEMO_account;
        }
        if(_password  == nil)
        {
            _password = DEMO_password;
        }

        if(_email == nil || _email.length == 0)
        {
            _email = [NSString stringWithFormat:@"%@@qq.com",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            if(_email == nil || _email.length == 0)
            {
                _email = @"unknown";
            }
        }
        if(_videoResolution == nil || _videoResolution.length == 0)
        {
            _videoResolution = @"2";
        }

        if(_videoBitRate<=500)
        {
            _videoBitRate = 800;
        }
        if(_audioBitRate<=64)
        {
            _audioBitRate = 64;
        }
        if(_videoCaptureFPS <10)
            _videoCaptureFPS =  15;
        if(_videoCaptureFPS >30)
            _videoCaptureFPS = 30;
        if(_bufferTimes <=0)
            _bufferTimes = 6;
        
        if([standardUserDefaults valueForKey:@"VHisOpenNoiseSuppresion"])
            self.isOpenNoiseSuppresion = [standardUserDefaults boolForKey:@"VHisOpenNoiseSuppresion"];
        else
            self.isOpenNoiseSuppresion = YES;
        self.beautifyFilterEnable = [standardUserDefaults boolForKey:@"VHbeautifyFilterEnable"];
    }
    return self;
}


- (void)setLive_nick_name:(NSString *)live_nick_name {
    _live_nick_name = live_nick_name;
    [[NSUserDefaults standardUserDefaults] setValue:live_nick_name forKey:@"live_nick_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setTimeOut:(NSInteger)timeOut
{
    if(timeOut<=0)
        timeOut = 10;
    
    _timeOut = timeOut;
    [[NSUserDefaults standardUserDefaults] setInteger:timeOut forKey:@"VHtimeOut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setEmail:(NSString*)email
{
    if(email == nil || email.length == 0)
        return;
    
    _email = email;
    [[NSUserDefaults standardUserDefaults] setObject:_email forKey:@"VHuserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setKValue:(NSString*)kValue
{
    _kValue = kValue;
    [[NSUserDefaults standardUserDefaults] setObject:_kValue forKey:@"VHkValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)setCodeWord:(NSString *)codeWord
{
    _codeWord = codeWord;
    [[NSUserDefaults standardUserDefaults] setObject:_codeWord forKey:@"VHCodeWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setInva_avatar:(NSString *)inva_avatar {
    [[NSUserDefaults standardUserDefaults] setValue:inva_avatar forKey:@"VHInvaAvatar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)inva_avatar {
    NSString *avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"VHInvaAvatar"];
    if(!avatar) {
        avatar = VHDefaultAvatar;
    }
    return avatar;
}

- (void)setAccount:(NSString *)account
{
    _account  = account ;
    [[NSUserDefaults standardUserDefaults] setObject:_account forKey:@"VHaccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setPassword:(NSString *)password
{
    _password  = password ;
    [[NSUserDefaults standardUserDefaults] setObject:_password forKey:@"VHpassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setVideoResolution:(NSString*)videoResolution
{
    if(videoResolution == nil || videoResolution.length == 0)
        return;
    if([videoResolution integerValue]<0 || [videoResolution integerValue]>3)
        return;
    
    _videoResolution = videoResolution;
    [[NSUserDefaults standardUserDefaults] setObject:_videoResolution forKey:@"VHvideoResolution"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsOpenNoiseSuppresion:(BOOL)isOpenNoiseSuppresion
{
    _isOpenNoiseSuppresion = isOpenNoiseSuppresion;
    [[NSUserDefaults standardUserDefaults] setBool:_isOpenNoiseSuppresion forKey:@"VHisOpenNoiseSuppresion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setBeautifyFilterEnable:(BOOL)beautifyFilterEnable
{
    _beautifyFilterEnable = beautifyFilterEnable;
    [[NSUserDefaults standardUserDefaults] setBool:_beautifyFilterEnable forKey:@"VHbeautifyFilterEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLiveToken:(NSString*)liveToken
{
    _liveToken = liveToken;
    if(liveToken == nil || liveToken.length == 0)
    {
        _liveToken = DEMO_AccessToken;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VHliveToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_liveToken forKey:@"VHliveToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setVideoBitRate:(NSInteger)videoBitRate
{
    if(videoBitRate<=0)
        return;
    
    _videoBitRate = videoBitRate;
    [[NSUserDefaults standardUserDefaults] setInteger:videoBitRate forKey:@"VHbitRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAudioBitRate:(NSInteger)audioBitRate
{
    if(audioBitRate<=0)
        return;
    
    _audioBitRate = audioBitRate;
    [[NSUserDefaults standardUserDefaults] setInteger:audioBitRate forKey:@"VHaudiobitRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setVideoCaptureFPS:(NSInteger)videoCaptureFPS
{
    if(videoCaptureFPS <1)
        videoCaptureFPS = 10;
    if(videoCaptureFPS >30)
        videoCaptureFPS = 30;

    _videoCaptureFPS = videoCaptureFPS;
    [[NSUserDefaults standardUserDefaults] setInteger:videoCaptureFPS forKey:@"VHvideoCaptureFPS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setBufferTimes:(NSInteger)bufferTimes
{
    if(bufferTimes <=0)
        bufferTimes = 2;
    
    _bufferTimes = bufferTimes;
    [[NSUserDefaults standardUserDefaults] setInteger:bufferTimes forKey:@"VHbufferTimes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



//发起活动id
- (void)setActivityID:(NSString *)activityID {
    [[NSUserDefaults standardUserDefaults] setValue:activityID forKey:@"VHactivityID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)activityID {
    NSString *activityId = [[NSUserDefaults standardUserDefaults] valueForKey:@"VHactivityID"];
    if(!activityId) {
        activityId = DEMO_ActivityId;
    }
    return activityId;
}

//观看活动id
- (void)setWatchActivityID:(NSString *)watchActivityID {
    [[NSUserDefaults standardUserDefaults] setValue:watchActivityID forKey:@"VHwatchActivityID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)watchActivityID {
    NSString *watchActivityID = [[NSUserDefaults standardUserDefaults] valueForKey:@"VHwatchActivityID"];
    if(!watchActivityID) {
        watchActivityID = DEMO_ActivityId;
    }
    return watchActivityID;
}

//三方id
- (void)setThird_Id:(NSString *)third_Id {
    [[NSUserDefaults standardUserDefaults] setValue:third_Id forKey:@"third_Id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)third_Id {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"third_Id"];
}

//三方昵称
- (void)setThird_nickName:(NSString *)third_nickName {
    [[NSUserDefaults standardUserDefaults] setValue:third_nickName forKey:@"third_nickName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)third_nickName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"third_nickName"];
}

//三方头像
- (void)setThird_avatar:(NSString *)third_avatar {
    [[NSUserDefaults standardUserDefaults] setValue:third_avatar forKey:@"third_avatar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)third_avatar {
    NSString *avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"third_avatar"];
    if(!avatar) {
        avatar = VHDefaultAvatar;
    }
    return avatar;
}

@end
