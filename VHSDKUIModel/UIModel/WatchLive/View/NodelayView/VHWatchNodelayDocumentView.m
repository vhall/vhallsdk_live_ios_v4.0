//
//  VHWatchNodelayDocumentView.m
//  UIModel
//
//  Created by xiongchao on 2021/10/29.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHWatchNodelayDocumentView.h"

@interface VHWatchNodelayDocumentView () <VHDocumentDelegate>
@property (nonatomic, strong) UILabel *noDocTipLab;     ///<无文档提示
@property (nonatomic, weak) VHDocument *document;  ///<文档对象
@property (nonatomic, assign) BOOL documentShow;  ///<是否显示文档

@end

@implementation VHWatchNodelayDocumentView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configUI];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}


//设置文档对象和初始显示
- (void)setDocument:(VHDocument *)document defaultShow:(BOOL)show {
    self.document = document;
    self.documentShow = show;
    document.delegate = self;
}

- (void)setDocumentShow:(BOOL)documentShow {
    _documentShow = documentShow;
    [self setDocViewHidden:!documentShow];
}


- (void)configUI {
    [self addSubview:self.noDocTipLab];
    [self.noDocTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}


//将指定的文档挪到最顶层显示
- (void)bringSubviewToFrontWithDocId:(NSString *)cid {
    for(VHDocumentView *view in self.subviews) {
        if([view isKindOfClass:[VHDocumentView class]] && [view.cid isEqualToString:cid]) {
            [self bringSubviewToFront:view];
            view.hidden = !self.documentShow;
            break;
        }
    }
    [self bringSubviewToFront:self.noDocTipLab];
}

//设置文档隐藏/显示
- (void)setDocViewHidden:(BOOL)hidden {
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[VHDocumentView class]]) {
            view.hidden = hidden;
        }
    }
    self.noDocTipLab.hidden = !hidden;
}

//添加文档
- (void)addDocumentView:(VHDocumentView *)view {
    view.backgroundColor = [UIColor whiteColor];
    [self layoutIfNeeded];
    view.frame = self.bounds;
    [self addSubview:view];
}

//删除文档
- (void)removeDocumentView:(VHDocumentView *)view {
    [view removeFromSuperview];
}


#pragma mark - VHDocumentDelegate
//文档错误回调
- (void)document:(VHDocument *)document error:(NSError *)error {
    VUI_Log(@"文档出错：%@",error);
}

//文档同步延迟时间
- (float)document:(VHDocument *)document delayChannelID:(NSString*)channelID {
    return 0;
}

//是否显示文档
- (void)document:(VHDocument *)document switchStatus:(BOOL)switchStatus {
    VUI_Log(@"文档显示：%d 是否可编辑：%d 选中的文档：%@",switchStatus,document.editEnable,document.selectedView);
    
    if(self.documentShow != switchStatus) {
        VH_ShowToast(switchStatus ? @"主持人打开文档" : @"主持人关闭文档");
        self.documentShow = switchStatus;
    }
    self.noDocTipLab.hidden = switchStatus;
}

//选择 documentView
- (void)document:(VHDocument *)document selectDocumentView:(VHDocumentView*)documentView {
    VUI_Log(@"选择文档：%@---cid:%@",documentView,documentView.cid);
    //保证选择的文档始终在顶层（web端文档、白板切换时会回调此方法）
    [self bringSubviewToFrontWithDocId:document.selectedView.cid];
}

//添加 documentView
- (void)document:(VHDocument *)document addDocumentView:(VHDocumentView *)documentView {
    VUI_Log(@"添加文档：%@---cid:%@---该文档是否为选中文档：%d",documentView,documentView.cid,[documentView isEqual:document.selectedView]);
    [self addDocumentView:documentView];
    //保证选择的文档始终在顶层（防止其他端演示新文档时，没有销毁老文档，会出现多个文档叠加；或者出现回调先选择文档后添加文档，导致选择文档无法显示）
    [self bringSubviewToFrontWithDocId:document.selectedView.cid];
}

//删除 documentView
- (void)document:(VHDocument *)document removeDocumentView:(VHDocumentView *)documentView {
    VUI_Log(@"删除文档：%@",documentView);
    [self removeDocumentView:documentView];
}


- (UILabel *)noDocTipLab
{
    if (!_noDocTipLab)
    {
        _noDocTipLab = [[UILabel alloc] init];
        _noDocTipLab.text = @"暂未演示文档";
        _noDocTipLab.textAlignment = NSTextAlignmentCenter;
        _noDocTipLab.font = FONT_FZZZ(15);
        _noDocTipLab.hidden = YES;
    }
    return _noDocTipLab;
}
@end
