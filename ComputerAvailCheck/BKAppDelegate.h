//
//  BKAppDelegate.h
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Penn State. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "BKMapViewController.h"
#import "BKBuildingMenuViewController.h"

@interface BKAppDelegate : UIResponder <UIApplicationDelegate> {
	
	bool sliding_view_is_open;
	
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ECSlidingViewController *slidingViewController;
@property (strong, nonatomic) BKMapViewController *map_view_controller;
@property (strong, nonatomic) BKBuildingMenuViewController *menu_view_controller;
@property (strong, nonatomic) UINavigationController *navi_controller;

- (void)anchorNavigationController;

@end
