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
@property (strong, nonatomic) BKMapViewController *map_view_controller;
@property (strong, nonatomic) BKBuildingMenuViewController *menu_view_controller;
@property (strong, nonatomic) UINavigationController *navi_controller;
@property (strong, nonatomic) MEZoomAnimationController *zoom_animation_controller;
//@property (strong, nonatomic) MEDynamicTransition *dynamic_animation_controller;
//@property (strong, nonatomic) UIPanGestureRecognizer *dynamic_transition_pan_gesture;

- (void)anchorNavigationController;

@end
