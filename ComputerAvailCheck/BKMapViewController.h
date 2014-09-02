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
#import <dispatch/dispatch.h>
#import "BKRoomViewController.h"

@interface BKMapViewController : UIViewController <SOAPEngineDelegate, GMSMapViewDelegate> {
	
	GMSMapView *mapView;
	SOAPEngine *soapBuilding, *soapRoom;
	NSMutableArray *markerArray, *markerPool, *buildingNameArray, *buildingNamePool, *totalCompArray,
				*availWinArray, *availMacArray, *availLinuxArray,
				*oppCodeArray, *totalRoomArray, *totalAvailArray;
	NSMutableArray *roomAvailWin, *roomAvailMac, *roomAvailLinux, *roomNumber;
	
}

+ (BOOL) getConnectionStatus;

- (void) addGoogleMap;
- (void) initializeMarkerPool;
- (void) finalizeMarkers;
- (void) queryBuildingData;
- (void) queryRoomData:(NSString *)opp_code;
- (void) changeMarkerColor:(GMSMarker*) marker;

@end
