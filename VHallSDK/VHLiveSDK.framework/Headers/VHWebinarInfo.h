//
//  VHWebinarInfo.h
//  VHallSDK
//
//  Created by xiongchao on 2020/12/17.
//  Copyright © 2020 vhall. All rights reserved.
//
//活动相关信息------------此类仅限新版控制台(v3及以上)新建的直播活动使用-----------
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VHWebinarInfoDelegate <NSObject>

/// 房间人数改变回调
/// @param online_real 真实在线用户数
/// @param online_virtual 虚拟在线用户数
- (void)onlineChangeRealNum:(NSUInteger)online_real virtualNum:(NSUInteger)online_virtual;

@end

@interface VHWebinarInfo : NSObject
/// 代理
@property (nonatomic, weak) id<VHWebinarInfoDelegate> delegate;

/// 直播类型
@property (nonatomic, assign) VHWebinarLiveType liveType;

/// 真实在线人数
@property (nonatomic, assign ,readonly) NSUInteger online_real;
/// 虚拟在线人数
@property (nonatomic, assign ,readonly) NSUInteger online_virtual;
/// 是否显示在线人数
@property (nonatomic, assign ,readonly) BOOL online_show;

/// 真实热度
@property (nonatomic, assign ,readonly) NSUInteger pv_real;
/// 虚拟热度
@property (nonatomic, assign ,readonly) NSUInteger pv_virtual;
/// 是否显示热度
@property (nonatomic, assign ,readonly) BOOL pv_show;
@end

NS_ASSUME_NONNULL_END
