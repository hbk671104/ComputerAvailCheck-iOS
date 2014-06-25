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
	
	GMSMapView *map_view;
	SOAPEngine *soap_building, *soap_room;
	NSMutableArray *marker_array, *building_name_array, *total_comp_array,
				*avail_win_array, *avail_mac_array, *avail_linux_array,
				*opp_code_array, *total_room_array, *total_avail_array;
	NSMutableArray *room_avail_win, *room_avail_mac, *room_avail_linux, *room_number;
	
}

+ (BOOL) getConnectionStatus;

- (void) addGoogleMap;
- (void) initializeMarkers;
- (void) finalizeMarkers;
- (void) queryBuildingData;
- (void) queryRoomData:(NSString *)opp_code;
- (void) changeMarkerColor:(GMSMarker*) marker;

@end
