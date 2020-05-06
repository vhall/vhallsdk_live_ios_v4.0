//
//  VHDLNADevice.h
//  VHDLNA
//
//  Created by vhall on 2017/9/7.
//  Copyright © 2017年 111. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaControlService;
@class RenderingControlService;

@interface VHDLNADevice : NSObject

@property (nonatomic, strong) NSString                *uuid;

@property (nonatomic, strong) NSString                *name;

@property (nonatomic, strong) NSString                *location;

@property (nonatomic, strong) MediaControlService     *mediaControlService;

@property (nonatomic, strong) RenderingControlService *renderingControlService;

@end
