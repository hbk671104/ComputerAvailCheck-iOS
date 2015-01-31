//
//  BKAppDelegate.h
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JVFloatingDrawerViewController.h>
#import <JVFloatingDrawerSpringAnimator.h>
#import "BKMapViewController.h"
#import "BKBuildingMenuViewController.h"

@interface BKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BKMapViewController *mapViewController;
@property (strong, nonatomic) BKBuildingMenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *naviController;
@property (strong, nonatomic) JVFloatingDrawerViewController *floatingDrawerController;

+ (BKAppDelegate *)globalDelegate;
- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated;

@end
