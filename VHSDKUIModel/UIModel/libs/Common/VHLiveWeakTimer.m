//
//  VHLiveWeakTimer.m
//  VHLiveSale
//
//  Created by xiongchao on 2020/3/16.
//  Copyright © 2020 vhall. All rights reserved.
//

#import "VHLiveWeakTimer.h"

@implementation VHLiveWeakTimer
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(nullable id)userInfo
                                     repeats:(BOOL)repeats{

    VHLiveWeakTimer *weakTimer = [VHLiveWeakTimer new];
    weakTimer.target = aTarget;
    weakTimer.selector = aSelector;
    weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:weakTimer selector:@selector(fire:) userInfo:userInfo repeats:repeats];
    [weakTimer.timer fire];
    return weakTimer.timer;
}



-(void)fire:(NSTimer *)timer{

    if (self.target) {
        [self.target performSelector:self.selector withObject:timer.userInfo];
    } else {
        [self.timer invalidate];
    }
}

@end
