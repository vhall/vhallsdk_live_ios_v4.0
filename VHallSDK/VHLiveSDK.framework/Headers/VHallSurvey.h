//
//  VHallSurvey.h
//  VHallSDK
//
//  Created by vhall on 17/2/14.
//  Copyright © 2017年 vhall. All rights reserved.
//
// 问卷
// !!!!:注意实例方法使用时机，看直播/回放————>在收到"播放连接成功回调"或"视频信息预加载成功回调"以后使用。
#import <Foundation/Foundation.h>
#import "VHallBasePlugin.h"

@protocol VHallSurveyDelegate <NSObject>

/*  flsh活动，接收到问卷消息，以下两个方法都会回调。
    H5活动，发布问卷，只回调-receivedSurveyWithURL：。
    如果使用webView的方式加载问卷，在-receivedSurveyWithURL:处理，如果仍保留旧版加载问卷方式，在-receiveSurveryMsgs:方法处理，处理方式不变。
  */


/**
 *  接收问卷消息
 */
-(void)receiveSurveryMsgs:(NSArray*)msg DEPRECATED_MSG_ATTRIBUTE("建议使用receivedSurveyWithURL方式处理问卷消息");;

/**
 收到问卷 v4.0.0新增
 @param surveyURL 问卷地址
 */
- (void)receivedSurveyWithURL:(NSURL *)surveyURL;

@end

@interface VHallSurvey : VHallBasePlugin

@property(nonatomic, weak) id<VHallSurveyDelegate> delegate;


@property (nonatomic,copy) NSString   *surveyId;//问卷Id
@property (nonatomic,copy) NSString   *liveId;//活动Id
@property (nonatomic,copy) NSString   *surveyTitle;//问卷标题
@property (nonatomic,copy) NSArray    *questionArray;//问题列条

//-----------接收问卷建议使用receivedSurveyWithURL方法，嵌入web页面，则无需调用以下接口--------------

/// 获取Flash活动问卷内容，返回转换模型后的数据 (H5活动不支持该方法，请使用web嵌入)
/// @param surveyId 问卷id
/// @param webInarId 活动id
/// @param success 成功回调
/// @param reslutFailedCallback 失败回调
- (void)getSurveryContentWithSurveyId:(NSString*)surveyId webInarId:(NSString*)webInarId success:(void(^)(VHallSurvey* msgs))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;


/// 获取Flash活动问卷内容，返回原始请求数据 (H5活动不支持该方法，请使用web嵌入)
/// @param surveyId 问卷id
/// @param webInarId 活动id
/// @param success 成功回调
/// @param failedCallback 失败回调
- (void)getSurveryRequestWithSurveyId:(NSString *)surveyId webInarId:(NSString *)webInarId success:(void(^)(NSDictionary *result))success failed:(void (^)(NSDictionary* failedData))failedCallback;


/// 发送Flash活动问卷结果，调用请参考demo (H5活动不支持该方法，请使用web嵌入)
/// @param msg 问卷结果数组
/// @param success 成功回调
/// @param reslutFailedCallback 失败回调失败Block 字典结构：{code：错误码，content：错误信息}
- (void)sendMsg:(NSArray *)msg success:(void(^)(void))success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;


@end


@interface VHallSurveyQuestion : NSObject
@property(nonatomic,assign)    NSUInteger questionId;// 问题Id
@property(nonatomic,copy)      NSString   *questionTitle;//问题标题
@property(nonatomic,assign)    NSUInteger orderNum;//问题排序
@property(nonatomic,assign)    BOOL       isMustSelect;
@property(nonatomic,assign)    NSUInteger type ;// 选项类型 （0问答 1单选 2多选）
@property(nonatomic,copy)      NSArray    *quesionSelectArray;//问题选项数组
@end
