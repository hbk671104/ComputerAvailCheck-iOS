//
//  BKBuildingMenuViewController.h
//  ComputerAvailCheck
//
//  Created by BK on 4/12/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKMapViewController.h"
#import "ECSlidingViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface BKBuildingMenuViewController : UITableViewController

+ (void)setBuildingArray:(NSMutableArray *)array;
+ (void)setMarkerArray:(NSMutableArray *)array;
+ (void)setMapView:(GMSMapView *)map;
+ (void)setSlidingViewController:(ECSlidingViewController *)controller;

@end
