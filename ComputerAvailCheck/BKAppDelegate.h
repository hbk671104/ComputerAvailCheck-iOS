//
//  BKAppDelegate.h
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "BKMapViewController.h"
#import "BKBuildingMenuViewController.h"
#import "MEFoldAnimationController.h"
#import "MEZoomAnimationController.h"
#import "MEDynamicTransition.h"

@interface BKAppDelegate : UIResponder <UIApplicationDelegate, ECSlidingViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ECSlidingViewController *slidingViewController;
@property (strong, nonatomic) BKMapViewController *mapViewController;
@property (strong, nonatomic) BKBuildingMenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MEZoomAnimationController *zoomAnimationController;

- (void)anchorNavigationController;

@end
