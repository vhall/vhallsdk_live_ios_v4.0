//
//  VHLiveMemberModel.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHLiveMemberModel.h"
#import "MJExtension.h"
#import <VHInteractive/VHRoom.h>
#import "MJExtension.h"

@implementation VHLiveMemberModel

+ (instancetype)modelWithVHRenderView:(VHLocalRenderView *)view {
    NSDictionary *userData = view.userData.mj_JSONObject;
    NSDictionary *streamAttributes = view.streamAttributes.mj_JSONObject;
    NSDictionary *remoteMuteStream = view.remoteMuteStream.mj_JSONObject;
    VUI_Log(@"---用户进入房间时传的数据：%@---用户推流上麦时所传数据：%@---此流的 流音视频开启情况：%@",userData,streamAttributes,remoteMuteStream);
    //设置视频显示模式，放大填充
    view.scalingMode = VHRenderViewScalingModeAspectFill;
    //如果是插播或共享桌面，留黑边的样式显示
    if(view.streamType == VHInteractiveStreamTypeScreen || view.streamType == VHInteractiveStreamTypeFile) {
         view.scalingMode = VHRenderViewScalingModeAspectFit;
    }
    VHLiveMemberModel *model = [[VHLiveMemberModel alloc] init];
    model.account_id = view.userId;
    model.videoView = view;
    model.role_name = (VHLiveRole)[streamAttributes[@"role"] integerValue];
    model.nickname = streamAttributes[@"nickName"];
    if(!model.nickname) {
        model.nickname = streamAttributes[@"nick_name"];
    }
    if(!model.nickname) {
        model.nickname = streamAttributes[@"nickname"];
    }
    model.avatar = streamAttributes[@"avatar"];
    if(!view.isLocal) {
        //是否禁音、关闭摄像头
        model.closeCamera = [remoteMuteStream[@"video"] integerValue] == 1;
        model.closeMicrophone = [remoteMuteStream[@"audio"] integerValue] == 1;
    }
    return model;
}

- (BOOL)deviceError {
    if(self.device_status == 1) {
        return NO;
    }else {
        return YES;
    }
}

//获取受限列表（包括禁言和踢出）
+ (void)getLimitUsersListWithWebinarId:(NSString *)webinarId page:(NSInteger)page success:(void(^)(NSMutableArray <VHLiveMemberModel *> *array , BOOL isLastPage))successBlock failure:(void(^)(NSError *_Nonnull error))failureBlock {
    
}

@end
