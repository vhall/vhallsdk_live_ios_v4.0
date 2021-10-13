//
//  VHActionSheetConfig.m
//  VHActionSheet
//
//  Created by Leo on 2016/11/29.
//
//  Copyright (c) 2015-2019 Leo <leodaxia@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "VHActionSheetConfig.h"


#define kVHActionSheetButtonHeight              55.0f

#define kVHActionSheetRedColor                  kVHActionSheetColor(85, 85, 85)

#define kVHActionSheetTitleFont                 [UIFont systemFontOfSize:14.0f]

#define kVHActionSheetButtonFont                [UIFont systemFontOfSize:16.0f]

#define kVHActionSheetAnimationDuration         0.3f

#define kVHActionSheetDarkOpacity               0.5f

#define kVHActionSheetBlurBgColorNormal         [[UIColor whiteColor] colorWithAlphaComponent:0.5]
//#define kVHActionSheetBlurBgColorHighlighted    [[UIColor whiteColor] colorWithAlphaComponent:0.1]


@implementation VHActionSheetConfig

+ (VHActionSheetConfig *)config {
    static id _config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[self alloc] initSharedInstance];
    });
    return _config;
}

+ (instancetype)shared {
    return self.config;
}

- (instancetype)initSharedInstance {
    if (self = [super init]) {
        self.titleFont                = kVHActionSheetTitleFont;
        self.buttonFont               = kVHActionSheetButtonFont;
        self.destructiveButtonColor   = kVHActionSheetRedColor;
        self.titleColor               = kVHActionSheetColor(111.0f, 111.0f, 111.0f);
        self.buttonColor              = kVHActionSheetColor(34.0f,34.0f,34.0f);
        
        self.buttonHeight             = kVHActionSheetButtonHeight;
        self.animationDuration        = kVHActionSheetAnimationDuration;
        self.darkOpacity              = kVHActionSheetDarkOpacity;
        
        self.titleEdgeInsets          = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
        self.buttonEdgeInsets         = UIEdgeInsetsMake(8.0, 15.0, 8.0, 15.0);
//        self.actionSheetEdgeInsets    = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        self.separatorColor           = kVHActionSheetColorA(150.0f, 150.0f, 150.0f, 0.3f);
        self.blurBackgroundColor      = kVHActionSheetBlurBgColorNormal;
        
        self.cancelButtonColor        = self.buttonColor;
        self.cancelButtonBgColor      = [UIColor clearColor];
        self.buttonBgColor            = [UIColor clearColor];
        self.destructiveButtonBgColor = [UIColor clearColor];
        self.buttonCornerRadius       = 0.0f;
        self.unBlur = YES;
    }
    return self;
}

- (instancetype)init {
    return VHActionSheetConfig.config;
}

- (NSInteger)cancelButtonIndex {
    return 0;
}

@end
