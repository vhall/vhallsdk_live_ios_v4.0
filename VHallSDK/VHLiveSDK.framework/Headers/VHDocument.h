//
//  VHDocument.h
//  VHDocument
//
//  Created by vhall on 2019/6/18.
//  Copyright © 2019 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHDocumentView.h"



@protocol VHDocumentDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface VHDocument : NSObject
/**
 *  获得当前SDK版本号
 */
+ (NSString *) getSDKVersion;


@property (nonatomic,weak)id <VHDocumentDelegate>      delegate;

/**
 * 当前选中的文档显示view
 */
@property (nonatomic,weak,readonly)VHDocumentView *selectedView;

/**
 * 文档显示views 字典 以documentView.cid为key
 */
@property (nonatomic,strong,readonly)NSDictionary *documentViewsByIDs;

/*
 * 是否可以编辑 作为发起端 默认NO 不可编辑
 */
@property (nonatomic,assign)BOOL    editEnable;

/*
 * 是否开启观看端演示
 */
@property (nonatomic,assign)BOOL switchOn;

/*
 * 文档显示背景色，默认白色
 */
@property (nonatomic,strong)UIColor *backgroundColor;

/*
 * 文档frame
 */
@property (nonatomic,assign)CGRect frame;


#pragma mark - init
/**
 * 点播文档模块初始化
 */
- (instancetype)initWithRecordID:(NSString*)recordID accessToken:(NSString*)accessToken;

/**
 * 直播+文档模块初始化 生成roomID的回放时会 绑定演示的文档
 * roomID 绑定到直播间
 */
- (instancetype)initWithChannelID:(NSString*)channelID roomID:(NSString*)roomID accessToken:(NSString*)accessToken;

/**
 * 直播+文档模块初始化 生成roomID的回放时会 绑定演示的文档
 * roomID 绑定到直播间
 * isLoadLastDoc 是否恢复上次演示文档
 */
- (instancetype)initWithChannelID:(NSString*)channelID roomID:(NSString*)roomID accessToken:(NSString*)accessToken loadLastDoc:(BOOL)isLoadLastDoc;

#pragma mark - 演示端方法
/**
 * 创建文档 view
 * frame 创建文档frame
 * size  画板宽高，尽量保持与其他端大小一致，最少也要保证比例相同否则画笔会错位
 * documentID 文档ID
 * color 创建文档背景颜色
 */
- (VHDocumentView*)createDocumentWithFrame:(CGRect)frame size:(CGSize)size documentID:(NSString*)documentID backgroundColor:(UIColor *)color;

/**
 * 创建白板 view
 * frame 创建文档frame
 * size  画板宽高，尽量保持与其他端大小一致，最少也要保证比例相同否则画笔会错位
 * color 创建白板背景颜色
 */
- (VHDocumentView*)createBoardWithFrame:(CGRect)frame size:(CGSize)size backgroundColor:(UIColor *)color;

/**
 * 销毁文档
 */
- (void)destroyWithCID:(NSString*)cid;

/**
 * 选择正在演示的文档
 */
- (void)selectWithCID:(NSString*)cid;

/**
 * 文档演示重置 用于同一频道再次演示 清空上次数据
 * @param channelID 文档演示channelID
 */
+ (void)resetDocWithChannelID:(NSString*)channelID
                  accessToken:(NSString*)accessToken
                      success:(void(^)(void))success
                       failed:(void(^)(NSError *error))failedBlock;
@end

@protocol VHDocumentDelegate <NSObject>

@optional
/**
 *  错误回调
 *  @param document 文档实例
 *  @param error    错误
 */
- (void)document:(VHDocument *)document error:(NSError *)error;

/**
 *  直播文档同步
 *  @param document 文档实例
 *  @param channelID   文档channelID
 *  @return float   延迟执行时间单位秒 即直播延迟时间 re     alityBufferTime/1000.0
 */
- (float)document:(VHDocument *)document delayChannelID:(NSString*)channelID;

/**
 *  翻页消息
 *  @param document 文档实例
 *  @param documentView   文档id 为空时没有 文档
 */
- (void)document:(VHDocument *)document changePage:(VHDocumentView*)documentView;

/**
 * 是否显示文档
 */
- (void)document:(VHDocument *)document switchStatus:(BOOL)switchStatus;

/**
 *  选择 documentView
 */
- (void)document:(VHDocument *)document selectDocumentView:(VHDocumentView*)documentView;

/**
 *  添加 documentView
 */
- (void)document:(VHDocument *)document addDocumentView:(VHDocumentView *)documentView;

/**
 *  删除 documentView
 */
- (void)document:(VHDocument *)document removeDocumentView:(VHDocumentView *)documentView;

@end
NS_ASSUME_NONNULL_END


