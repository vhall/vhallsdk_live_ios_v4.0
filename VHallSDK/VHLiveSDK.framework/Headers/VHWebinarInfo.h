//
//  VHWebinarInfo.h
//  VHallSDK
//
//  Created by xiongchao on 2020/12/17.
//  Copyright © 2020 vhall. All rights reserved.
//
//活动相关信息，注意：此类信息仅限新版控制台(v3及以上)创建的活动使用，否则部分属性无值
#import <Foundation/Foundation.h>
#import "VHallConst.h"

NS_ASSUME_NONNULL_BEGIN

//跑马灯配置信息
@interface VHWebinarScrollTextInfo : NSObject
@property (nonatomic, copy, readonly) NSString *webinar_id;     ///<活动id
@property (nonatomic, assign, readonly) NSInteger scrolling_open;     ///<是否开启跑马灯  1：开启 0：关闭
@property (nonatomic, copy, readonly) NSString *text;     ///<文本内容
@property (nonatomic, assign, readonly) NSInteger text_type;     ///<文本显示格式，1：固定文本 2：固定文本+观看者id和昵称
@property (nonatomic, assign, readonly) NSInteger alpha;     ///<不透明度，如：60%不透明度，则属性值为60
@property (nonatomic, assign, readonly) NSInteger size;     ///<字号
@property (nonatomic, copy, readonly) NSString *color;     ///<十六进制色值 如：#FFFFFF
@property (nonatomic, assign, readonly) NSInteger interval;     ///<间隔时间，秒
@property (nonatomic, assign, readonly) NSInteger speed;     ///<滚屏速度 10000：慢 6000：中 3000：快
@property (nonatomic, assign, readonly) NSInteger position;     ///<显示位置 1：随机 2：上 3：中 4：下
@end


@protocol VHWebinarInfoDelegate <NSObject>

/// 房间人数改变回调 （目前仅支持真实人数改变触发此回调）
/// @param online_real 真实在线用户数
/// @param online_virtual 虚拟在线用户数
- (void)onlineChangeRealNum:(NSUInteger)online_real virtualNum:(NSUInteger)online_virtual;

@end

@interface VHWebinarInfo : NSObject
/// 代理
@property (nonatomic, weak) id<VHWebinarInfoDelegate> delegate;
/// 活动直播类型 （视频、音频、互动）
@property (nonatomic, assign, readonly) VHWebinarLiveType liveType;
/// 活动直播状态  (直播、预告、结束、点播/回放)
@property (nonatomic, assign, readonly) VHMovieActiveState liveState;
/// 活动id
@property (nonatomic, copy, readonly) NSString *webinarId;
/// 自己的参会id
@property (nonatomic, copy, readonly) NSString *join_id;


/// 真实在线人数（该值会随房间人数改变实时更新）
@property (nonatomic, assign, readonly) NSUInteger online_real;
/// 虚拟在线人数
@property (nonatomic, assign, readonly) NSUInteger online_virtual;
/// 是否显示在线人数
@property (nonatomic, assign, readonly) BOOL online_show;

/// 真实热度
@property (nonatomic, assign, readonly) NSUInteger pv_real;
/// 虚拟热度
@property (nonatomic, assign, readonly) NSUInteger pv_virtual;
/// 是否显示热度
@property (nonatomic, assign, readonly) BOOL pv_show;

/// 跑马灯信息
@property (nonatomic, strong ,readonly) VHWebinarScrollTextInfo *scrollTextInfo;
@end


NS_ASSUME_NONNULL_END
