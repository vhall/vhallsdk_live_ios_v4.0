//
//  VHInteractLiveVC_New.m
//  UIModel
//
//  Created by leiheng on 2021/4/15.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHInteractLiveVC_New.h"
#import "VHInteractContentView.h"
#import <VHInteractive/VHRoom.h>
#import "VHLiveMemberAndLimitView.h"
#import "VHLiveBroadcastInfoDetailView.h"
#import "VHLiveBroadcastInfoDetailTopView.h"
#import "VHLiveBroadcastInfoDetailBootomView.h"
#import "VHLiveStateView.h"
#import "VHLiveMemberModel.h"
#import "VHAlertView.h"
#import "OMTimer.h"
#import "MJExtension.h"
#import "VHDocListVC.h"
#import "VHLiveDocContentView.h"

@interface VHInteractLiveVC_New ()<VHRoomDelegate,VHallChatDelegate,VHDocumentDelegate>
{
    BOOL _NetErrorRetry; //标记当前网络错误重试
    BOOL _noShowDownMicTip; //是否不显示下麦提示
}

/** 互动View */
@property (nonatomic, strong) VHInteractContentView *interactView;

/** 本地视频view */
@property (nonatomic, strong) VHLocalRenderView *localRenderView;

/** 主讲人视频小窗口 */
@property (nonatomic, strong) VHLocalRenderView *smallVideo;

/** 角色 用户类型:1主持人 2观众 3助理 4嘉宾 */
@property (nonatomic, assign) VHLiveRole role;
/** 标记是否为自己主动下麦 */
@property (nonatomic, assign) BOOL downMicrophoneBySelf;
/** 标记是否为自己手动关闭直播 */
@property (nonatomic, assign) BOOL closeLiveBySelf;
/** 标记是否为自己进行麦克风操作 */
@property (nonatomic, assign) BOOL operateMicBySelf;
/** 标记是否为自己进行摄像头操作 */
@property (nonatomic, assign) BOOL operateCameraBySelf;

@end

@implementation VHInteractLiveVC_New

- (instancetype)initWithParams:(NSDictionary *)params isHost:(BOOL)isHost screenLandscape:(BOOL)screenLandscape {
    self = [super initWithParams:params];
    if (self) {
        self.role = isHost ? VHLiveRole_Host : VHLiveRole_Guest;
        self.screenLandscape = screenLandscape;
        if(self.role == VHLiveRole_Guest) { //嘉宾加入互动直播
            self.isSpeaker = NO;
            self.isGuest = YES;
        }else { //主持人开始互动直播
            self.isSpeaker = YES;
            self.isGuest = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)configUI {
    self.infoDetailView.topToolView.liveType = VHLiveType_Interact;
    if(self.role == VHLiveRole_Host) { //主持人
        //添加开始按钮
        [self.liveStateView setLiveState:VHLiveState_Prepare btnTitle:@""];
        //显示开播前本地视频预览
        [self showHostLocalVideo];
        //没上麦时，隐藏视频/语音按钮
        [self.infoDetailView.topToolView hiddenCameraOpenBtn:YES microphoneBtn:YES beautyBtn:NO cameraSwitch:NO];
    }else if(self.role == VHLiveRole_Guest){ //嘉宾
        [self.infoDetailView hiddenMessageView:NO];  //显示消息view
        [self.infoDetailView hiddenHostInfoView:NO]; //显示头像view
        self.infoDetailView.bottomToolView.hidden = NO; //显示底部工具view
        //没上麦时，隐藏视频/语音/美颜等按钮
        [self.infoDetailView.topToolView hiddenCameraOpenBtn:YES microphoneBtn:YES beautyBtn:YES cameraSwitch:YES];
    }
    //添加互动视频容器
    [self.infoDetailView insertSubview:self.interactView atIndex:0];
    [self.interactView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.screenLandscape) {
            make.top.bottom.equalTo(self.infoDetailView);
            make.width.height.equalTo(self.infoDetailView.mas_height);
        }else {
            make.top.equalTo(self.infoDetailView.topToolView.mas_bottom).offset(14);
            make.width.height.equalTo(self.infoDetailView.mas_width);
        }
        make.centerX.equalTo(self.infoDetailView);
    }];
    
    if(self.role == VHLiveRole_Guest) { //嘉宾没有开播按钮，直接加入，成功后加入互动房间
        @weakify(self);
        [self prepareLiveSuccess:^{
            @strongify(self);
            [self.inavRoom guestEnterRoomWithParams:self.params success:^(VHRoomInfo *roomInfo) {
                self.roomInfo = roomInfo;
                self.roomInfo.documentManager.delegate = self;
                //嘉宾端，没有直播计时，显示直播名称
                self.infoDetailView.topToolView.liveTitleStr = self.roomInfo.webinar_title;
                self.infoDetailView.topToolView.headIconStr = self.roomInfo.webinar_user_icon;
                [self startIMServer];
            } fail:^(NSError *error) {
                VH_ShowToast(error.localizedDescription);
            }];
        }];
    }
}

// 初始化IM服务
- (void)startIMServer {
    self.chatService =[[VHallChat alloc] initWithObject:self.inavRoom];
    self.chatService.delegate = self;
}

//显示开播前本地视频预览
- (void)showHostLocalVideo {
    [self.infoDetailView insertSubview:self.localRenderView atIndex:0];
    [self.localRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.infoDetailView);
    }];
}

//互动出错
- (void)interactiveRoomError:(NSError *)error {
    if (!error) {
        return;
    }
    VUI_Log(@"互动房间出错：%@",error);
    if(error.code == 30009) {
        
    }else if(error.code == 284003){ //socket.io fail（一般就是网络错误）
        if(self.isGuest) {
            [self.liveStateView setLiveState:VHLiveState_NetError btnTitle:@"重新连接"];
        }else {
            [self.liveStateView setLiveState:VHLiveState_NetError btnTitle:@"重新推流"];
        }
        //暂时不做重连处理，直接退出
        VH_ShowToast(@"当前网络异常");
        [self leaveInteracRoom]; //离开房间，并停止推流
        [self popViewController];
    }else {
        VH_ShowToast(error.domain);
        [self leaveInteracRoom]; //离开房间，并停止推流
        [self popViewController];
    }
}

- (void)popViewController {
    //防止横屏转竖屏，返回会有视频画面延迟消失现象
    self.interactView.hidden = YES;
    self.smallVideo.hidden = YES;
    //隐藏弹窗，防止出现alert弹窗没有关闭的情况
    [QMUIModalPresentationViewController hideAllVisibleModalPresentationViewControllerIfCan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//离开房间
- (void)leaveInteracRoom {
    if(self.screenLandscape) { //如果横屏，强制转竖屏
        [self forceRotateUIInterfaceOrientation:UIInterfaceOrientationPortrait];
        self.screenLandscape = NO;
    }
    if([self.inavRoom isPublishing]) {
        [self.inavRoom unpublish]; //停止推流
    }
    self.chatService = nil; //移除消息监听
    [self.inavRoom leaveRoom]; //退出互动房间
}

//更新主讲人视频小窗口显示
- (void)updataSmallVideo {
    if(!self.infoDetailView.openDocView) { //文档未显示时，不处理
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //放在主线程，等待collectionView刷新以后，再添加小窗口视频，否则小窗口视频无法添加到文档详情页中，因为collectionView刷新不是立即刷新，先取到模型中的视频view添加，collectionView刷新时又添加同一个视频view,导致又被添加回去
            //视频容器小窗口展示
            self.smallVideo = [self.interactView docPermissionVideoView];
            
            if(self.smallVideo) {
                NSLog(@"添加小窗口：%@",self.smallVideo);
                [self.infoDetailView addSubview:self.smallVideo];
                self.smallVideo.backgroundColor = [UIColor whiteColor];
                [self.smallVideo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.equalTo(@(CGSizeMake(120, 120)));
                    if(self.screenLandscape) {
                        make.right.equalTo(self.infoDetailView).offset(-15);
                        make.top.equalTo(self.infoDetailView).offset(15);
                    }else {
                        make.right.equalTo(self.infoDetailView).offset(0);
                        make.top.equalTo(self.infoDetailView).offset(VH_KStatusBarHeight);
                    }
                }];
            }
    });
}

- (void)prepareLiveSuccess:(void (^)(void))success {
    //设置本地流用户信息
    NSDictionary *attributes = @{
        @"nickName":self.params[@"nickname"],
        @"role":@(self.role),
        @"avatar":self.params[@"avatar"]};
    VUI_Log(@"设置本地流用户信息：%@",attributes);
    [self.localRenderView setAttributes:attributes.mj_JSONString];
    success ? success() : nil;
}

//开播倒计时结束
- (void)startLiveCountDownOver {
    [super startLiveCountDownOver];
    //加入互动房间，成功回调中判断如果是主播，则开启推流
    @weakify(self)
    [self.inavRoom hostEnterRoomStartWithParams:self.params success:^(VHRoomInfo *roomInfo) {
        @strongify(self)
        self.roomInfo = roomInfo;
        self.roomInfo.documentManager.delegate = self;
        self.infoDetailView.topToolView.headIconStr = self.roomInfo.webinar_user_icon;
        [self startIMServer];
    } fail:^(NSError *error) {
        VH_ShowToast(error.localizedDescription);
    }];
}

//网络错误，重新推流
- (void)restartPushForNetError {
    VUI_Log(@"当前房间状态：%zd",self.inavRoom.status);
    _NetErrorRetry = YES;
    if(self.inavRoom.status == VHRoomStatusConnected) { //房间已连接
        VUI_Log(@"房间已经连接，重新推流");
        [self.inavRoom publishWithCameraView:self.localRenderView];
    }else {
        VUI_Log(@"房间没有连接，重新加入房间");
        //重新加入房间
        @weakify(self)
        [self.inavRoom hostEnterRoomStartWithParams:self.params success:^(VHRoomInfo *roomInfo) {
            @strongify(self)
            self.roomInfo = roomInfo;
            [self startIMServer];
        } fail:^(NSError *error) {
            VH_ShowToast(error.localizedDescription);
        }];
    }
}

//前台
- (void)appWillEnterForeground {
    [super appWillEnterForeground];
    if(!self.isGuest && self.liveStateView.liveState == VHLiveState_Success) {//主播端 && 已开播
        //开始推流
        [self.inavRoom publishWithCameraView:self.localRenderView];
    }
}

//后台
- (void)appDidEnterBackground {
    //停止推流
    if([self.inavRoom isPublishing]) {
        [self.inavRoom unpublish];
    }
}

//强杀
- (void)appWillTerminate {
    if (!self.isGuest && self.liveStateView.liveState == VHLiveState_Success) {
        [self.inavRoom leaveRoom];
    }
}

#pragma mark - VHLiveBroadcastInfoDetailViewDelegate
///上麦/下麦
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView upMicrophoneActionBtn:(UIButton *)button {
    button.userInteractionEnabled = NO;
    if(!button.selected) {
        //如果被禁言，不让上麦
        if(self.inavRoom.roomInfo.selfBanChat) {
            VH_ShowToast(@"您已被禁言");
            button.userInteractionEnabled = YES;
            return;
        }
        //上麦请求
        [self.inavRoom applySuccess:^{
            button.userInteractionEnabled = YES;
            VH_ShowToast(@"已发送上麦申请");
            //开启倒计时
            [detailView.bottomToolView startUpMicCountDownTime];
        } fail:^(NSError *error) {
            button.userInteractionEnabled = YES;
            VH_ShowToast(error.localizedDescription);
        }];
    }else {
        //标记自己下麦
        self.downMicrophoneBySelf = YES;
        button.userInteractionEnabled = YES;
        //下麦停止推流
        [self.inavRoom unpublish];
    }
}

///取消上麦
- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView cancaelUpMicrophoneActionBtn:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self.inavRoom cancelApplySuccess:^{
        button.userInteractionEnabled = YES;
        //重置上麦按钮状态
        [self.infoDetailView.bottomToolView endTimeByUpMicSuccess:NO];
        VH_ShowToast(@"已取消上麦申请");
    } fail:^(NSError *error) {
        button.userInteractionEnabled = YES;
        VH_ShowToast(error.localizedDescription);
    }];
}

///退出直播
- (void)liveDetaiViewClickCloseBtn:(VHLiveBroadcastInfoDetailView *)detailView {
    NSString *tipText = self.role == VHLiveRole_Host ? @"确定结束当前直播？" : @"确定退出直播？";
    NSString *cancelText = self.role == VHLiveRole_Host ? @"继续直播" : @"取消";
    NSString *confirmText = self.role == VHLiveRole_Host ? @"结束直播" : @"确定";
    [VHAlertView showAlertWithTitle:tipText content:nil cancelText:cancelText cancelBlock:nil confirmText:confirmText confirmBlock:^{
        if (self.role == VHLiveRole_Host) {
            self.closeLiveBySelf = YES;
            if([self.inavRoom isPublishing]) { //如果当前已经在推流
                [self leaveInteracRoom]; //停止推流，退出互动房间
                [self showLiveEndView]; //显示直播结束页
            }else {
                [self leaveInteracRoom]; //停止推流，退出互动房间
                [self popViewController];
            }
            for (NSString *cid in self.roomInfo.documentManager.documentViewsByIDs.allKeys) {
                [self.roomInfo.documentManager destroyWithCID:cid];
            }
        } else {
            [self leaveInteracRoom];
            [self popViewController];
        }
    }];
}

///前后设置头切换
- (void)liveDetaiViewClickCameraSwitchBtn:(VHLiveBroadcastInfoDetailView *)detailView {
    [self.localRenderView switchCamera];
}

///美颜开关
- (void)liveDetaiViewClickBeautyBtn:(VHLiveBroadcastInfoDetailView *)detailView openBeauty:(BOOL)open{
    self.localRenderView.beautifyEnable = open;
    if(open) {
        VH_ShowToast(@"已开启美颜");
    }else {
        VH_ShowToast(@"已关闭美颜");
    }
}

///麦克风开关
- (void)liveDetaiViewClickMicrophoneBtn:(VHLiveBroadcastInfoDetailView *)detailView voiceBtn:(UIButton *)voiceBtn {
    voiceBtn.userInteractionEnabled = NO;
    BOOL open = voiceBtn.isSelected ? YES : NO;
    self.operateMicBySelf = YES;
    if (open) {
        [self.localRenderView unmuteAudio];
        VH_ShowToast(@"已打开麦克风");
        voiceBtn.userInteractionEnabled = YES;
    } else {
        [self.localRenderView muteAudio];
        VH_ShowToast(@"已关闭麦克风");
        voiceBtn.userInteractionEnabled = YES;
    }
}

///摄像头开关
- (void)liveDetaiViewClickCameraOpenBtn:(VHLiveBroadcastInfoDetailView *)detailView videoBtn:(UIButton *)videoBtn {
    videoBtn.userInteractionEnabled = NO;
    BOOL open = videoBtn.isSelected ? YES : NO;
    self.operateCameraBySelf = YES;
    if (open) {
        [self.localRenderView unmuteVideo];
        VH_ShowToast(@"已打开摄像头");
        videoBtn.userInteractionEnabled = YES;
    } else {
        [self.localRenderView muteVideo];
        VH_ShowToast(@"已关闭摄像头");
        videoBtn.userInteractionEnabled = YES;
    }
}

///打开成员列表
- (void)liveDetailViewOpenMemberListView:(VHLiveBroadcastInfoDetailView *)detailView {
    if(!self.userListView) {
        BOOL isGuest = self.role == VHLiveRole_Guest; //是否为嘉宾
        BOOL members_manage = self.roomInfo.membersManageAuthority; //是否有成员管理权限
        VHLiveMemberAndLimitView *listView = [[VHLiveMemberAndLimitView alloc] initWithRoom:self.inavRoom liveType:VHLiveType_Interact isCuest:isGuest haveMembersManage:members_manage];
        self.userListView = listView;
    }
    [self.userListView showInView:self.view];
}

- (void)liveDetailViewDocumentListBtnClick:(VHLiveBroadcastInfoDetailView *)detailView {
    VHDocListVC *docListVC = [[VHDocListVC alloc] init];
    docListVC.room = self.inavRoom;
    docListVC.docSelectBlcok = ^(NSString * _Nonnull docId) {
        //演示新文档时，确保先关闭之前打开的画笔弹窗
        [self.infoDetailView.bottomToolView cancelSelectBrush];
        [self liveDetaiViewShowDocId:docId];
    };
    [self.navigationController pushViewController:docListVC animated:YES];
}

///打开文档展示容器
- (void)liveDetailViewOpenDocumentView:(VHLiveBroadcastInfoDetailView *)detailView {
    //显示文档演示下的UI
    [self.infoDetailView showDocUI:YES];
    //将文档容器添加到互动视频容器上方
    NSInteger index = [self.infoDetailView.subviews indexOfObject:self.interactView] + 1;
    [self.infoDetailView insertSubview:self.docContentView atIndex:index];
    [UIView animateWithDuration:0.3 animations:^{
        self.docContentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        //更新小窗口视频
        [self updataSmallVideo];
    }];
}

///关闭文档容器
- (void)docContentViewDisMissComplete:(VHLiveDocContentView *)docContentView {
    [super docContentViewDisMissComplete:docContentView];
    [self.smallVideo removeFromSuperview];
    //视频小窗view移除后，需重新刷新互动视频显示
    [self.interactView reloadAllData];
}

- (void)liveDetailView:(VHLiveBroadcastInfoDetailView *)detailView hiddenDocUnRelationView:(BOOL)hidden {
    [super liveDetailView:detailView hiddenDocUnRelationView:hidden];
    self.smallVideo.hidden = hidden;
}

#pragma mark - VHRoomDelegate
- (void)room:(VHRoom *)room enterRoomWithError:(NSError *)error {
    [self interactiveRoomError:error];
}

// 房间连接成功回调
- (void)room:(VHRoom *)room didConnect:(NSDictionary *)roomMetadata {
    if (self.role == VHLiveRole_Host) {
        [self.inavRoom publishWithCameraView:self.localRenderView];
    }
}

//推流成功
- (void)room:(VHRoom *)room didPublish:(VHRenderView *)cameraView {
    _NetErrorRetry = NO;
    [self.liveStateView setLiveState:VHLiveState_Success btnTitle:@""];
    //移除本地预览视频
    [self.localRenderView removeFromSuperview];
    //显示视频、语音、美颜等按钮
    [self.infoDetailView.topToolView hiddenCameraOpenBtn:NO microphoneBtn:NO beautyBtn:NO cameraSwitch:NO];
    //添加自己的视频view
    VHLiveMemberModel *model = [VHLiveMemberModel modelWithVHRenderView:(VHLocalRenderView *)cameraView];
    if(model.videoView.isLocal) { //如果是本地视频，设置当前视频/音频开启情况
        model.closeCamera = self.infoDetailView.topToolView.videoBtn.selected;
        model.closeMicrophone = self.infoDetailView.topToolView.voiceBtn.selected;
    }
    model.haveDocPermission = [self.inavRoom.roomInfo.mainSpeakerId isEqualToString:model.account_id];
    [self.interactView addAttendWithUser:model];
    //更新视频小窗口显示
    [self updataSmallVideo];
}

// 停止推流成功
- (void)room:(VHRoom *)room didUnpublish:(VHRenderView *)cameraView {
    VUI_Log(@"停止推流成功");
}
//房间错误回调
- (void)room:(VHRoom *)room didError:(VHRoomErrorStatus)status reason:(NSString *)reason {
    VUI_Log(@"房间错误：%@",reason);
    VH_ShowToast(@"当前网络异常");
    [self leaveInteracRoom];
    [self popViewController];
}

//房间状态变化
- (void)room:(VHRoom *)room didChangeStatus:(VHRoomStatus)status {
    VUI_Log(@"房间状态变化：%zd",status);
    if(status == VHRoomStatusDisconnected || status == VHRoomStatusError) {
        [self interactiveRoomError:nil];
    }
}

//新成员上麦回调
- (void)room:(VHRoom *)room didAddAttendView:(VHRenderView *)attendView {
    VUI_Log(@"\n某人上麦:%@，流类型：%d，流视频宽高：%@，流id：%@，是否有音频：%d，是否有视频：%d",attendView.userId,attendView.streamType,NSStringFromCGSize(attendView.videoSize),attendView.streamId,attendView.hasAudio,attendView.hasVideo);
    VHLiveMemberModel *model = [VHLiveMemberModel modelWithVHRenderView:(VHLocalRenderView *)attendView];
    model.haveDocPermission = [self.inavRoom.roomInfo.mainSpeakerId isEqualToString:model.account_id];
    [self.interactView addAttendWithUser:model];
    //更新视频小窗口显示
    [self updataSmallVideo];
    //如果收到插播，则关闭自己麦克风，解决插播时文件与人声混音问题。
    if(model.videoView.streamType == VHInteractiveStreamTypeFile) { //插播
        if([self.interactView haveRenderViewWithTargerId:@""] && self.infoDetailView.topToolView.voiceBtn.selected == NO) { //自己已上麦 && 麦克风处于开启状态下
            //关闭麦克风
            [self liveDetaiViewClickMicrophoneBtn:self.infoDetailView voiceBtn:self.infoDetailView.topToolView.voiceBtn];
        }
    }
}

//成员下麦回调
- (void)room:(VHRoom *)room didRemovedAttendView:(VHRenderView *)attendView {
    [self.interactView removeAttendView:(VHLocalRenderView *)attendView];
    //更新视频小窗口显示
    [self updataSmallVideo];
}

- (void)room:(VHRoom *)room receiveRoomMessage:(VHRoomMessage *)message {
    VUI_Log(@"messageType====%ld",(long)message.messageType);

    BOOL targetIsMyself = message.targetForMe;
    NSString *targetId = message.targetId;
    NSString *targetName = message.targetName;

    switch (message.messageType) {
        case VHRoomMessageType_vrtc_connect_apply:{//用户申请上麦
            if (self.role == VHLiveRole_Host) {
                NSString *name = targetName.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[targetName substringToIndex:VH_MaxNickNameCount]] : targetName;
                NSString *title = [NSString stringWithFormat:@"%@\n申请上麦，是否同意？",name];
                [VHAlertView showAlertWithTitle:title content:nil cancelText:@"拒绝" cancelBlock:^{
                    [self.inavRoom rejectApplyWithTargetUserId:targetId success:^{
                        
                    } fail:^(NSError *error) {
                        VH_ShowToast(error.localizedDescription);
                    }];
                } confirmText:@"同意" confirmBlock:^{
                    [self.inavRoom agreeApplyWithTargetUserId:targetId success:^{
                        
                    } fail:^(NSError *error) {
                        VH_ShowToast(error.localizedDescription);
                    }];
                }];
            }
        }break;
        case VHRoomMessageType_vrtc_connect_invite:{//用户被邀请上麦
            if (targetIsMyself) {
                [VHAlertView showAlertWithTitle:@"主持人邀请您上麦，是否同意？" content:nil cancelText:@"拒绝" cancelBlock:^{
                    [self.inavRoom rejectInviteSuccess:^{
                        
                    } fail:^(NSError *error) {
                        VH_ShowToast(error.localizedDescription);
                    }];
                } confirmText:@"同意" confirmBlock:^{
                    [self.inavRoom agreeInviteSuccess:^{
                        [self.inavRoom publishWithCameraView:self.localRenderView];
                    } fail:^(NSError *error) {
                        VH_ShowToast(error.localizedDescription);
                    }];
                }];
            }
        }break;
        case VHRoomMessageType_vrtc_connect_agree:{//用户上麦申请被同意
            if(targetIsMyself) {
                VUI_Log(@"上麦请求被同意，开启推流");
                [self.inavRoom publishWithCameraView:self.localRenderView];
            }
        }break;
        case VHRoomMessageType_vrtc_connect_refused:{//用户上麦申请被拒绝
            if(targetIsMyself) {
                VH_ShowToast(@"主持人拒绝了您的上麦申请");
                [self.infoDetailView.bottomToolView endTimeByUpMicSuccess:NO];
            }
        }break;
        case VHRoomMessageType_vrtc_mute:{//静音
            if(targetIsMyself) {
                self.infoDetailView.topToolView.voiceBtn.selected = YES;
                if (self.operateMicBySelf) {
                    self.operateMicBySelf = NO;
                    [self.localRenderView muteAudio];
                } else {
                    [self.localRenderView muteAudio];
                }
            }
            [self.interactView targerId:targetId closeMicrophone:YES];
            [self updataSmallVideo];
        }break;
        case VHRoomMessageType_vrtc_mute_cancel:{//取消静音
            if(targetIsMyself) {
                self.infoDetailView.topToolView.voiceBtn.selected = NO;
                if (self.operateMicBySelf) {
                    self.operateMicBySelf = NO;
                } else {
                    [self.localRenderView unmuteAudio];
                }
            }
            [self.interactView targerId:targetId closeMicrophone:NO];
            [self updataSmallVideo];
        }break;
        case VHRoomMessageType_vrtc_frames_forbid:{//关闭摄像头
            if(targetIsMyself) {
                self.infoDetailView.topToolView.videoBtn.selected = YES;
                if (self.operateCameraBySelf) {
                    self.operateCameraBySelf = NO;
                } else {
                    [self.localRenderView muteVideo];
                }
            }
            [self.interactView targerId:targetId closeCamera:YES];
            [self updataSmallVideo];
        }break;
        case VHRoomMessageType_vrtc_frames_display:{//开启摄像头
            if(targetIsMyself) {
                self.infoDetailView.topToolView.videoBtn.selected = NO;
                if (self.operateCameraBySelf) {
                    self.operateCameraBySelf = NO;
                } else {
                    [self.localRenderView unmuteVideo];
                }
            }
            [self.interactView targerId:targetId closeCamera:NO];
            [self updataSmallVideo];
        }break;
        case VHRoomMessageType_vrtc_big_screen_set:{//用户互动流画面被设置为旁路大画面
            
        }break;
        case VHRoomMessageType_vrtc_speaker_switch:{//设置主讲人
            if(targetIsMyself) { //自己被设为主讲人
                VH_ShowToast(@"您已被设为主讲人");
                [self setDocEditEnable:YES];
            }else { //其他人被设为主讲人
                [self setDocEditEnable:NO];
                if(self.role != VHLiveRole_Host) { //自己不是主持人，其他人被设置为主讲人时给提示
                    NSString *name = targetName.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[targetName substringToIndex:VH_MaxNickNameCount]] : targetName;
                    NSString *title = [NSString stringWithFormat:@"%@已被设为主讲人",name];
                    VH_ShowToast(title);
                }
            }
            NSMutableArray *micUserList = [self.interactView getMicUserList];
            [micUserList enumerateObjectsUsingBlock:^(VHLiveMemberModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                model.haveDocPermission = [targetId isEqualToString:model.account_id];
            }];
            //更新成员列表与受限列表
            [self updateUserList];
            //更新视频view 主讲人标识
            [self.interactView reloadAllData];
            //更新小窗口视频
            [self updataSmallVideo];
        }break;
        case VHRoomMessageType_live_start:{//开始直播
            if(self.isGuest && self.interactView.dadaSource.count == 0) {
                VH_ShowToast(@"直播开始");
            }
        }break;
        case VHRoomMessageType_live_over:{//结束直播
            if(self.isGuest) {
                VH_ShowToast(@"直播已结束");
                [self leaveInteracRoom];
                [self popViewController];
            }else {
                //非主持人自己手动关闭，则为封禁消息
                if(!self.closeLiveBySelf) {
                    [VHAlertView showAlertWithTitle:@"直播间已被管理员封禁" content:nil cancelText:nil cancelBlock:nil confirmText:@"退出直播间" confirmBlock:^{
                        [self leaveInteracRoom]; //离开房间，并停止推流
                        [self popViewController]; //返回根控制器
                    }];
                }
            }
        }break;
        case VHRoomMessageType_vrtc_disconnect_success:{//用户下麦成功
            if(targetIsMyself) { //自己
                if(_noShowDownMicTip == NO) {
                    if(!self.downMicrophoneBySelf && self.isGuest) {
                        VH_ShowToast(@"您已被主持人下麦");
                    }else {
                        VH_ShowToast(@"您已下麦");
                    }
                }
                self.downMicrophoneBySelf = NO;
                //停止推流
                if (self.inavRoom.isPublishing) {
                    [self.inavRoom unpublish];
                }
                //重置上麦按钮状态
                [self.infoDetailView.bottomToolView endTimeByUpMicSuccess:NO];
                //移除自己的视频view
                [self.interactView removeAttendView:self.localRenderView];
                //隐藏视频、语音、美颜等按钮
                [self.infoDetailView.topToolView hiddenCameraOpenBtn:YES microphoneBtn:YES beautyBtn:YES cameraSwitch:YES];
                //更新小窗口视频
                [self updataSmallVideo];
            }else {
                NSString *name = targetName.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[targetName substringToIndex:VH_MaxNickNameCount]] : targetName;
                NSString *tipText = [NSString stringWithFormat:@"%@已下麦",name];
                VH_ShowToast(tipText);
            }
            //更新成员列表与受限列表
            [self updateUserList];
        }break;
        case VHRoomMessageType_vrtc_connect_success:{//用户上麦成功
            VUI_Log(@"---上麦成功");
            if(targetIsMyself) {
                //重置上麦按钮状态
                [self.infoDetailView.bottomToolView endTimeByUpMicSuccess:YES];
            }else {
                NSString *name = targetName.length > VH_MaxNickNameCount ? [NSString stringWithFormat:@"%@...",[targetName substringToIndex:VH_MaxNickNameCount]] : targetName;
                NSString *tipText = [NSString stringWithFormat:@"%@已上麦",name];
                VH_ShowToast(tipText);
            }
            //更新成员列表与受限列表
            [self updateUserList];
        }break;
        case VHRoomMessageType_room_kickout:{
            if (targetIsMyself) {
                VH_ShowToast(@"您已被踢出");
                //强制退出直播间
                [self leaveInteracRoom];
                [self popViewController];
            } else {
                //更新成员列表与受限列表
                [self updateUserList];
            }
        }break;
        case VHRoomMessageType_room_kickout_cancel:{
            [self updateUserList];
        }break;
        case VHRoomMessageType_room_banChat:{
            if (targetIsMyself) {
                VH_ShowToast(@"您已被禁言");
                if (self.inavRoom.isPublishing) {
                    [self.inavRoom unpublish];
                }
            }
            [self updateUserList];
        }break;
        case VHRoomMessageType_room_banChat_cancel:{
            if (targetIsMyself) {
                VH_ShowToast(@"您已被取消禁言");
            }
            [self updateUserList];
        }break;
        case VHRoomMessageType_room_allBanChat:{
            if (self.isGuest) {
                VH_ShowToast(@"全员已被禁言");
                if (self.inavRoom.isPublishing) {
                    [self.inavRoom unpublish];
                }
            }
            [self updateUserList];
        }break;
        case VHRoomMessageType_room_allBanChat_cancel:{
            if (self.isGuest) {
                VH_ShowToast(@"全员已被取消禁言");
            }
            [self updateUserList];
        }break;
        case VHRoomMessageType_vrtc_connect_invite_refused:{
            if (!self.isGuest) {
                NSString *title = [NSString stringWithFormat:@"%@拒绝了上麦申请",targetName];
                VH_ShowToast(title);
            }
        }break;
        default:
            break;
    }

}

///设置文档演示是否开启
- (void)setDocEditEnable:(BOOL)enable {
    //更新文档容器view空文档时的占位提示文字
    self.docContentView.emptyLab.text = enable ? @"还没有文档哦，点击右下角添加~" : @"还没有文档哦";
    //开启文档编辑
    self.roomInfo.documentManager.editEnable = enable;
    //显示主讲人操作按钮
    self.infoDetailView.bottomToolView.isSpeaker = enable;
    //如果当前正在画笔操作，结束画笔（防止嘉宾在进行画笔操作时，主讲人权限被主持人收回，当前画笔弹窗还在问题）
    if([self.infoDetailView brushPopViewIsShow]) {
        [self.infoDetailView.bottomToolView cancelSelectBrush];
    }
}

#pragma mark - lazy load
- (VHInteractContentView *)interactView
{
    if (!_interactView) {
        _interactView = [[VHInteractContentView alloc] initWithLandscapeShow:self.screenLandscape];
    }
    return _interactView;
}

- (VHRoom *)inavRoom {
    if (!_inavRoom) {
        _inavRoom = [[VHRoom alloc] init];
        _inavRoom.delegate = self;
    }
    return _inavRoom;
}

- (VHLocalRenderView *)localRenderView
{
    if (!_localRenderView) {
        VHFrameResolutionValue resolution = self.role == VHLiveRole_Host ? VHFrameResolution640x480 : VHFrameResolution480x360;
        NSString *simulcastLayers = self.role == VHLiveRole_Host ? @"2" : @"1";//同时推流数
        NSDictionary *options = @{VHFrameResolutionTypeKey:@(resolution),VHStreamOptionStreamType:@(VHInteractiveStreamTypeAudioAndVideo),VHSimulcastLayersKey:simulcastLayers};
        _localRenderView = [[VHLocalRenderView alloc] initCameraViewWithFrame:CGRectZero options:options];
        _localRenderView.scalingMode = VHRenderViewScalingModeAspectFill;
        _localRenderView.beautifyEnable = YES;
        [_localRenderView setDeviceOrientation:self.screenLandscape ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationPortrait];
    }
    return _localRenderView;
}

@end
