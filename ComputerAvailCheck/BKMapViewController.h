//
//  BKMapViewController.h
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SOAPEngine64/SOAPEngine.h>
#import "BKRoomViewController.h"

@interface BKMapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) GMSMapView *mapView;

+ (BOOL) getConnectionStatus;

@end
