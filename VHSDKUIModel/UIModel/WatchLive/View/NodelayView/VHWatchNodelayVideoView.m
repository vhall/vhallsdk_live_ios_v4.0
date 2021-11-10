//
//  VHWatchNodelayVideoView.m
//  UIModel
//
//  Created by xiongchao on 2021/10/27.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHWatchNodelayVideoView.h"

@interface VHWatchNodelayVideoView ()

@property (nonatomic, strong) UIView *mainSpeakerContentView;     ///<互动直播，主讲人画面容器
@property (nonatomic, strong) VHRenderView *mainSpeakerView;     ///<互动直播，主讲人画面
@property (nonatomic, strong) UIStackView *stackView; ///<互动直播，非主讲人画面容器（非主讲人是小画面，主讲人是大画面）
@property (nonatomic, strong) UIView *fileVideoContentView;     ///<互动直播，共享桌面或插播视频容器
@end

@implementation VHWatchNodelayVideoView

- (void)dealloc {
    VUI_Log(@"%s释放",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {

    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@(VHScreenWidth/5.0 * 9/16.0));
    }];
    
    [self addSubview:self.mainSpeakerContentView];
    [self.mainSpeakerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.bottom.equalTo(self.stackView.mas_top);
        make.width.equalTo(self.mainSpeakerContentView.mas_height).multipliedBy(16.0/9);
    }];
}

- (void)setRoomInfo:(VHRoomInfo *)roomInfo {
    _roomInfo = roomInfo;
    if(self.roomInfo.webinar_type == VHWebinarLiveType_Interactive) {  //互动直播
        self.mainSpeakerContentView.hidden = self.stackView.hidden = self.fileVideoContentView.hidden = NO;
    }else { //视频直播、音频直播
        self.mainSpeakerContentView.hidden = self.stackView.hidden = self.fileVideoContentView.hidden = YES;
    }
}

//添加视频渲染画面
- (void)addRenderView:(VHRenderView *)renderView {
    if(self.roomInfo.webinar_type == VHWebinarLiveType_Interactive) {  //互动直播
        if(renderView.streamType == VHInteractiveStreamTypeScreen || renderView.streamType == VHInteractiveStreamTypeFile) { //共享桌面或插播
            [self.fileVideoContentView addSubview:renderView];
            [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.fileVideoContentView);
            }];
            return;
        }
        
        if([self.roomInfo.mainSpeakerId isEqualToString:renderView.userId]) { //主讲人
            [self addMainSpeakerView:renderView];
        }else { //非主讲人
            if(![self.stackView.arrangedSubviews containsObject:renderView]) {
                [self.stackView addArrangedSubview:renderView];
            }
            [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset((VHScreenWidth/5.0 * self.stackView.arrangedSubviews.count)-VHScreenWidth);
            }];
        }
    }else {//非互动直播，全屏展示
        [self addSubview:renderView];
        [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

//移除视频渲染画面
- (void)removeRenderView:(VHRenderView *)renderView {
    
    if(renderView.streamType == VHInteractiveStreamTypeScreen || renderView.streamType == VHInteractiveStreamTypeFile) { //共享桌面或插播
        [renderView removeFromSuperview];
        return;
    }
    
    if(renderView == self.mainSpeakerView) {
        [self.mainSpeakerView removeFromSuperview];
        self.mainSpeakerView = nil;
    }else {
        if([self.stackView.arrangedSubviews containsObject:renderView]) {
            [self.stackView removeArrangedSubview:renderView];
        }
        [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset((VHScreenWidth/5.0 * self.stackView.arrangedSubviews.count)-VHScreenWidth);
        }];
    }
}

//添加主讲人画面
- (void)addMainSpeakerView:(VHRenderView *)renderView  {
    if(!renderView) {
        return;
    }
    [self.mainSpeakerContentView addSubview:renderView];
    [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainSpeakerContentView);
    }];
    self.mainSpeakerView = renderView;
}


//更新主讲人画面
- (void)updateMainSpeakerView {
    
    VHRenderView *mainSpeakerView;
    for(VHRenderView *view in self.stackView.arrangedSubviews.reverseObjectEnumerator) {
        if([view.userId isEqualToString:self.roomInfo.mainSpeakerId]) {
            mainSpeakerView = view;
        }
    }
    
    if(self.mainSpeakerView) {
        //原主讲人画面添加到非主讲人容器中
        [self.stackView addArrangedSubview:self.mainSpeakerView];
        self.mainSpeakerView = nil;
    }
    //添加新主讲人画面到主讲人画面容器
    [self addMainSpeakerView:mainSpeakerView];
}

//移除所有视频画面
- (void)removeAllRenderView {
    while (self.mainSpeakerContentView.subviews.count) {
        UIView* child = self.mainSpeakerContentView.subviews.lastObject;
        [child removeFromSuperview];
    }
    while (self.stackView.arrangedSubviews.count) {
        UIView* child = self.stackView.arrangedSubviews.lastObject;
        [child removeFromSuperview];
    }
    while (self.fileVideoContentView.subviews.count) {
        UIView* child = self.fileVideoContentView.subviews.lastObject;
        [child removeFromSuperview];
    }
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[VHRenderView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (UIStackView *)stackView
{
    if (!_stackView)
    {
        _stackView = [[UIStackView alloc] init];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentFill;
    }
    return _stackView;
}

- (UIView *)mainSpeakerContentView
{
    if (!_mainSpeakerContentView)
    {
        _mainSpeakerContentView = [[UIView alloc] init];
    }
    return _mainSpeakerContentView;
}

- (UIView *)fileVideoContentView
{
    if (!_fileVideoContentView)
    {
        _fileVideoContentView = [[UIView alloc] init];
        [self addSubview:_fileVideoContentView];
        [_fileVideoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _fileVideoContentView;
}

@end
