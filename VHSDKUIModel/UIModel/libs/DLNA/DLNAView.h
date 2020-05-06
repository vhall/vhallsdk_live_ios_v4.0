//
//  DLNAView.h
//  UIModel
//
//  Created by yangyang on 2017/9/3.
//  Copyright © 2017年 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VHLiveSDK/VHallMoviePlayer.h>

typedef void (^ DLNACloseBlock)(void);

@class VHDLNAControl;

//消息类型
typedef NS_ENUM(NSInteger,DLNAControlStateType) {
    DLNAControlType_START = 40001,
    DLNAControlType_PALY = 40002,
    DLNAControlType_PAUSE  = 40003,
    DLNAControlType_STOP    = 40004,
    DLNAControlType_SEEK    = 40005
};

@protocol DLNAViewDelegate <NSObject>
#pragma mark - 如果投屏功能出错回调走这里
- (void)dlnaControlState:(DLNAControlStateType)type errormsg:(NSString *)msg;
@end

@interface DLNAView : UIView

-(instancetype)initWithFrame:(CGRect)frame type:(int)type;
@property(nonatomic,assign) int type;//type = 0；直播 默认；type = 1 点播
@property(nonatomic,assign) NSInteger curTime;//当前播放时间 点播有效
@property (nonatomic , strong) NSMutableArray * deviceArray;/// 设备数量

//show
- (BOOL)showInView:(UIView*)view moviePlayer:(VHallMoviePlayer  *)moviePlayer;
@property(nonatomic,copy)   DLNACloseBlock closeBlock;
/**
 *  投屏代理回调
 */
@property (nonatomic, weak) id <DLNAViewDelegate> delegate;

@end
