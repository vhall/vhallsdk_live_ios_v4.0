//
//  VHDLNAControl.h
//  VHDLNA
//
//  Created by vhall on 2017/9/7.
//  Copyright © 2017年 111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHDLNADevice.h"

/**
 *  播放器状态 直播状态 回放状态由于用户创建的 MPMoviePlayerController 实例获取
 */
typedef NS_ENUM(NSInteger,VHDLNADeviceState) {
    VHDLNADeviceStateNone       = 0,    //默认状态
    VHDLNADeviceStateStoped     = 1,    //结束
    VHDLNADeviceStateSetUrled   = 2,    //设置Url完成
    VHDLNADeviceStatePlaying    = 3,    //播放中
    VHDLNADeviceStatePause      = 4,    //暂停
};



@protocol VHDLNAControlDelegate;

@interface VHDLNAControl : NSObject
@property (nonatomic,weak) id<VHDLNAControlDelegate> delegate;

@property (nonatomic,weak) VHDLNADevice *curDevice;//设置当前选择的设备后才能正常投屏


@property(nonatomic,assign) VHDLNADeviceState deviceState;
@property(nonatomic,assign) NSInteger duration;//总播放时长
@property(nonatomic,assign) NSInteger curTime;//当前播放时间
@property(nonatomic,assign) NSInteger volume;//设备声音






-(void)startSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
-(void)playSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
-(void)pauseSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
-(void)stopSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
-(void)seek:(NSInteger)seekpos success:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
-(void)getPositionInfoSuccess:(void(^)(NSString *currentDuration, NSString *totalDuration))successBlock failure:(void(^)(NSError *error))failureBlock;
-(void)setVolume:(NSInteger)volume success:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
-(void)getVolumeSuccess:(void(^)(NSInteger volume))successBlock failure:(void(^)(NSError *error))failureBlock;

/**
 * 时间(String)转秒, 格式(xx:xx:xx)
 */
+ (NSInteger)timeIntegerFromString:(NSString *)string;
/**
 * 时间(秒)转String, 格式(xx:xx:xx)
 */
+ (NSString *)timeStringFromInteger:(NSInteger)seconds;
@end


@protocol VHDLNAControlDelegate <NSObject>
-(void)deviceList:(NSArray<VHDLNADevice *>*)deviceList;

@optional
-(void)deviceStateChange:(VHDLNADeviceState)deviceState;
@end

