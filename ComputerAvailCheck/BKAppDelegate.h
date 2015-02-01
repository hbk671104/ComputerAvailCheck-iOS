//
//  BKAppDelegate.h
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKMapViewController.h"
#import "BKBuildingMenuViewController.h"
#import <MMDrawerController.h>

@interface BKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BKMapViewController *mapViewController;
@property (strong, nonatomic) BKBuildingMenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *naviController;
@property (strong, nonatomic) MMDrawerController *drawerController;

+ (BKAppDelegate *)globalDelegate;

@end
