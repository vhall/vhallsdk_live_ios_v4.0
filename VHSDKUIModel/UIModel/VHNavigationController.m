//
//  VHNavigationController.m
//  UIModel
//
//  Created by leiheng on 2021/4/23.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHNavigationController.h"

@interface VHNavigationController ()

@end

@implementation VHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate{
    if(self.topViewController) {
        return [self.topViewController shouldAutorotate];
    }
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if(self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if(self.topViewController) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationLandscapeRight;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end
