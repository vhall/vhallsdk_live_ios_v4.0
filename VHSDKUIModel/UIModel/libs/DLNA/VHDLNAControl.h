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

/**
 *  播放初始化开始播放
 */
-(void)startSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
/**
 *  开始播放
 */
-(void)playSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
/**
 *  暂停播放
 */
-(void)pauseSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
/**
 *  停止播放
 */
-(void)stopSuccess:(void (^)(void))successBlock failure:(void (^)(NSError * error))failureBlock;
/**
 *  拖拽到指定进度播放
 */
-(void)seek:(NSInteger)seekpos success:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
/**
 *  更新播放进度
 */
-(void)getPositionInfoSuccess:(void(^)(NSString *currentDuration, NSString *totalDuration))successBlock failure:(void(^)(NSError *error))failureBlock;
/**
 *  音量
 */
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
/**
 *  获取投屏设备列表
 */
-(void)deviceList:(NSArray<VHDLNADevice *>*)deviceList;

@optional
/**
 *  获取播放器状态
 */
-(void)deviceStateChange:(VHDLNADeviceState)deviceState;
@end

