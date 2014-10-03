//
//  BKMapViewController.m
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "BKMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "BKBuildingMenuViewController.h"
#import "MRProgress.h"
#import "Reachability.h"

@interface BKMapViewController ()

@end

@implementation BKMapViewController {
	
	GMSMapView *mapView;
	
	NSMutableArray *markerArray, *markerPool, *buildingNameArray, *buildingNamePool, *totalCompArray,
	*availWinArray, *availMacArray, *availLinuxArray,
	*oppCodeArray, *totalRoomArray, *totalAvailArray;
	
	NSMutableArray *roomAvailWin, *roomAvailMac, *roomAvailLinux, *roomNumber;
	
}

static bool is_connected;

+ (BOOL) getConnectionStatus {return is_connected;}

- (void) viewDidLoad {
	
    [super viewDidLoad];
	
	// Check network connectivity
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		
		// No connection
		is_connected = NO;
		NSLog(@"No Connection");
		
		// Instantiate a UIAlertView object
		UIAlertView *connectivity_alert = [[UIAlertView alloc] initWithTitle:@"No Network Connection"
																	 message:@"Please check the internet connection:(\n\n Double click home button and swipe up to close it. "
																	delegate:nil
														   cancelButtonTitle:nil
														   otherButtonTitles:nil];
		
		// Show the alert
		[connectivity_alert show];
		
		// Release the memory
		connectivity_alert = nil;
		
	} else {
	
		// Connection OK
		is_connected = YES;
		NSLog(@"Connected!");
		
		// Add map to the view
		[self addGoogleMap];
		
		// Instantiate all the markers
		[self initializeMarkerPool];
		[self initBuildingNamePool];

		// Show progress bar until all the markers have been finalized
		[MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
	
		// Instantiate a soap engine for building
		SOAPEngine *soapBuilding = [[SOAPEngine alloc] init];
		soapBuilding.version = VERSION_1_2;
		soapBuilding.licenseKey = @"i4P459CjYnQ2MV09N4/4V/KbVsU4iiLBG9BOvDWAq0HNFTcJGvD1wmGNzHtI6XA6H+x8shUCOcRlrsaJ+3L0bQ==";
		
		// Add the parameter to the soap request and make a request
		[soapBuilding requestURL:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx"
					   soapAction:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx/Buildings"
						   value:@"UP"
						  forKey:@"Campus"
		 completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
			 
			 // After getting the response, parse building data in a separate thread
			 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				 
				 NSLog(@"SOAP Building Response Received!");
				 
				 // Parse and put all the building data into their corresponding array
				 [self queryBuildingData:dict];
				 
				 // Init Marker Array
				 [self initMarker];
				 
				 // After all the array has been fully loaded, update UI back in the
				 // main thread
				 dispatch_async(dispatch_get_main_queue(), ^{
					 
					 // Send those data to Building Menu View controller
					 [BKBuildingMenuViewController setBuildingArray:buildingNameArray];
					 [BKBuildingMenuViewController setMarkerArray:markerArray];
					 [BKBuildingMenuViewController setMapView:mapView];
					 
					 // Add building data to each correponding marker
					 [self finalizeMarkers];
					 
					 // Dismiss the progress bar
					 [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
					 
				 });
				 
			 });
			  
		 } failWithError:nil];
	
		NSLog(@"Map View Loaded Successfully!");
		
	}
	
}
 
/*
 * When the map view is about to disappear, cut out useless the references
 * in order to release memory
 */
- (void) viewWillDisappear:(BOOL)animated {
	
	roomNumber = nil;
	roomAvailWin = nil;
	roomAvailMac = nil;
	roomAvailLinux = nil;
	
}

# pragma mark - GMSMapView Delegate

/*
 * Callback when info window has been tapped
 */
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
	
	// Show progress bar
	[MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
	
	// Get the opp code first
	NSString *opp_code = [oppCodeArray objectAtIndex:[markerArray indexOfObject:marker]];
	
	// Instantiate a soap engine
	SOAPEngine *soapRoom = [[SOAPEngine alloc] init];
	soapRoom.version = VERSION_1_2;
	soapRoom.licenseKey = @"i4P459CjYnQ2MV09N4/4V/KbVsU4iiLBG9BOvDWAq0HNFTcJGvD1wmGNzHtI6XA6H+x8shUCOcRlrsaJ+3L0bQ==";
	
	// Add the parameter to the soap request and make a request
	[soapRoom requestURL:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx"
			  soapAction:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx/Rooms"
				   value:opp_code
				  forKey:@"OppCode"
  completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
		
	  // After getting the response, parse building data in a separate thread
	  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		  
		  NSLog(@"SOAP Room Response Received!");
		  
		  // Parse and put all the building data into their corresponding array
		  [self queryRoomData:opp_code dictValue:dict];
		  
		  // After all the array has been fully loaded, update UI back in the
		  // main thread
		  dispatch_async(dispatch_get_main_queue(), ^{
		   
			   BKRoomViewController *room_view_c = [[BKRoomViewController alloc] init];
			   
			   // Set the title
			   room_view_c.navigationItem.title = [buildingNameArray objectAtIndex:[markerArray indexOfObject:marker]];
			   
			   // Pass the data to the room view controller
			   [BKRoomViewController setTotalRoom:totalRoomArray];
			   [BKRoomViewController setAvailWin:roomAvailWin];
			   [BKRoomViewController setAvailMac:roomAvailMac];
			   [BKRoomViewController setAvailLinux:roomAvailLinux];
			   [BKRoomViewController setRoomNumber:roomNumber];
			   [BKRoomViewController setOppCode:opp_code];
			   [BKRoomViewController setOppCodeArray:oppCodeArray];
			   
			   // Dismiss the progress bar and push it to the Room view controller while completed
			   [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^{
				   [self.navigationController pushViewController:room_view_c animated:YES];
			   }];
			  
		  });
		  
	  });
	  
	} failWithError:nil];
	
}

# pragma mark - Google Map Related Method

/*
 * Add Google map to the root view
 */
- (void) addGoogleMap {
	
	// Position the camera in the center of the map
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.800509
															longitude:-77.864252
																 zoom:15];
	
	// Get the height of the navi bar, the status bar and the screen
	CGFloat navi_bar_height = self.navigationController.navigationBar.frame.size.height;
	CGFloat status_bar_height = [UIApplication sharedApplication].statusBarFrame.size.height;
	CGFloat screen_height = [[UIScreen mainScreen] bounds].size.height;
	
    // Initialize the frame
	CGRect frame = CGRectMake(0, navi_bar_height + status_bar_height, self.view.frame.size.width, screen_height - (navi_bar_height + status_bar_height));
	
	// Instantiate the map view with the frame
	mapView = [GMSMapView mapWithFrame:frame camera:camera];
	
	// Configure the segmented control
	UISegmentedControl *segmented_control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil]];
	segmented_control.tintColor = [UIColor whiteColor];
	segmented_control.selectedSegmentIndex = 0;
	[segmented_control addTarget:self
						  action:@selector(segmentAction:)
				forControlEvents:UIControlEventValueChanged];
	[segmented_control sizeToFit];
	
	// Add it to the navigation bar title view
	self.navigationItem.titleView = segmented_control;
	
	// Enable users' location
	mapView.myLocationEnabled = YES;
	mapView.settings.myLocationButton = YES;
	
	// Enable compass button
	mapView.settings.compassButton = YES;
	
	// Set the delegate to itself
	mapView.delegate = self;
	
	// Add the map view as a subview
	[self.view addSubview:mapView];
		
}

/*
 * Init Building Name Pool
 */
- (void) initBuildingNamePool {
	
	buildingNamePool = [[NSMutableArray alloc] init];
	[buildingNamePool addObject:@"AgSci"];
	[buildingNamePool addObject:@"Boucke"];
	[buildingNamePool addObject:@"Bryce Jordan Center"];
	[buildingNamePool addObject:@"Business Bldg"];
	[buildingNamePool addObject:@"Cedar"];
	[buildingNamePool addObject:@"Chambers"];
	[buildingNamePool addObject:@"Davey Lab"];
	[buildingNamePool addObject:@"Deike"];
	[buildingNamePool addObject:@"EAL"];
	[buildingNamePool addObject:@"EES"];
	[buildingNamePool addObject:@"Ferguson"];
	[buildingNamePool addObject:@"Findlay"];
	[buildingNamePool addObject:@"Ford Building"];
	[buildingNamePool addObject:@"Forest Resources"];
	[buildingNamePool addObject:@"Hammond"];
	[buildingNamePool addObject:@"Henderson"];
	[buildingNamePool addObject:@"HHDev"];
	[buildingNamePool addObject:@"Hintz"];
	[buildingNamePool addObject:@"Hosler"];
	[buildingNamePool addObject:@"HUB"];
	[buildingNamePool addObject:@"IST"];
	[buildingNamePool addObject:@"Katz"];
	[buildingNamePool addObject:@"Keller"];
	[buildingNamePool addObject:@"LifeSci"];
	[buildingNamePool addObject:@"Mateer"];
	[buildingNamePool addObject:@"Osmond"];
	[buildingNamePool addObject:@"Paterno"];
	[buildingNamePool addObject:@"Patterson"];
	[buildingNamePool addObject:@"Pollock"];
	[buildingNamePool addObject:@"Rackley"];
	[buildingNamePool addObject:@"RecHall"];
	[buildingNamePool addObject:@"Redifer"];
	[buildingNamePool addObject:@"Sackett"];
	[buildingNamePool addObject:@"Sparks"];
	[buildingNamePool addObject:@"Stuckeman"];
	[buildingNamePool addObject:@"Walker"];
	[buildingNamePool addObject:@"Waring"];
	[buildingNamePool addObject:@"Warnock"];
	[buildingNamePool addObject:@"West Pattee"];
	[buildingNamePool addObject:@"Willard"];
	
}

/*
 * Init building markers pool
 */
- (void) initializeMarkerPool {
	
	// Initialized the marker array and populate it
	markerPool = [[NSMutableArray alloc] init];
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.803636, -77.863764)]]; // Ag Science
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799342, -77.861819)]]; // Boucke
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.809053, -77.855428)]]; // BJC
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.803926, -77.865199)]]; // Business
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799135, -77.868380)]]; // Cedar
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798325, -77.867731)]]; // Chambers
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798116, -77.862798)]]; // Davey Lab
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794266, -77.865405)]]; // Deike
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.804889, -77.856182)]]; // EAL
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.792146, -77.870880)]]; // EES
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801011, -77.863638)]]; // Ferguson
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.806479, -77.862265)]]; // Findlay
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799691, -77.869528)]]; // Ford
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.80483,  -77.863994)]]; // Forest Resources
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.793742, -77.862985)]]; // Hammond
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796982, -77.861375)]]; // Henderson
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796544, -77.859884)]]; // HHDev
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794306, -77.863671)]]; // Hintz
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794668, -77.865838)]]; // Hosler
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798136, -77.861272)]]; // Hub
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.793673, -77.868112)]]; // IST
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.807461, -77.866494)]]; // Katz
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798144, -77.870666)]]; // Keller
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.800934, -77.861492)]]; // Life Science
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798623, -77.870312)]]; // Mateer
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798607, -77.862223)]]; // Osmond
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798493, -77.865452)]]; // Paterno
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.800239, -77.864937)]]; // Patterson
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801129, -77.858510)]]; // Pollock
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798233, -77.868628)]]; // Rackley
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795435, -77.868651)]]; // Rec Hall
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799585, -77.855996)]]; // Redifer
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794757, -77.862641)]]; // Sackett
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796962, -77.865757)]]; // Sparks
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801108, -77.866744)]]; // Stuckeman
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.79323,  -77.866857)]]; // Walker
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795715, -77.867405)]]; // Waring
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.80294,  -77.866079)]]; // Warnock
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.797546, -77.866610)]]; // West Pattee
	[markerPool addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795967, -77.864255)]]; // Willard
	
}

/*
 * Init markers
 */
- (void) initMarker {
	
	markerArray = [[NSMutableArray alloc] init];
	for (int i = 0; i < [buildingNameArray count]; i++) {
		
		NSString *name = [buildingNameArray objectAtIndex:i];
		
		for (int j = 0; i < [buildingNamePool count]; j++) {
			
			if ([name isEqual:[buildingNamePool objectAtIndex:j]]) {
				
				// If name matches, add the marker
				[markerArray addObject:[markerPool objectAtIndex:j]];
				break;
				
			}
			
		}
		
	}
	
}

/*
 * Query building result
 */
- (void) queryBuildingData:(NSDictionary *) dic_result{
	
	// Get down the hierarchy to the building array
	NSMutableArray *building_array = [[[dic_result valueForKey:@"diffgram"]
								valueForKey:@"DocumentElement"]
							   valueForKey:@"Buildings"];
	
	// Instantiate each array
	oppCodeArray = [[NSMutableArray alloc] init];
	buildingNameArray = [[NSMutableArray alloc] init];
	totalRoomArray = [[NSMutableArray alloc] init];
	totalCompArray = [[NSMutableArray alloc] init];
	totalAvailArray = [[NSMutableArray alloc] init];
	availWinArray = [[NSMutableArray alloc] init];
	availMacArray = [[NSMutableArray alloc] init];
	availLinuxArray = [[NSMutableArray alloc] init];
	
	// Populate each array
	oppCodeArray = [building_array valueForKey:@"OppCode"];
	buildingNameArray = [building_array valueForKey:@"Building"];
	totalRoomArray = [building_array valueForKey:@"nRooms"];
	totalCompArray = [building_array valueForKey:@"nComputers"];
	totalAvailArray = [building_array valueForKey:@"nAvailable"];
	availWinArray = [building_array valueForKey:@"nWindows"];
	availMacArray = [building_array valueForKey:@"nMacintosh"];
	availLinuxArray = [building_array valueForKey:@"nLinux"];
	 
}

/*
 * Query room result
 */
- (void) queryRoomData:(NSString *)opp_code dictValue:(NSDictionary *)dic_result{
	
	// Get down the hierarchy to the room array
	NSMutableArray *room_array = [[[dic_result valueForKey:@"diffgram"]
								   valueForKey:@"DocumentElement"]
								  valueForKey:@"Rooms"];
	
	// Instantiate the available arrays
	roomNumber = [[NSMutableArray alloc] init];
	roomAvailWin = [[NSMutableArray alloc] init];
	roomAvailMac = [[NSMutableArray alloc] init];
	roomAvailLinux = [[NSMutableArray alloc] init];
	
	// For those building that has only one room that has available computers
	// The xml callbackr return room list as an array
	// so we have to manually add it to each array
	if ([[totalRoomArray objectAtIndex:[oppCodeArray indexOfObject:opp_code]] isEqual: @"1"]) {
		
		[roomNumber addObject:[room_array valueForKey:@"Room"]];
		[roomAvailWin addObject:[room_array valueForKey:@"nWindows"]];
		[roomAvailMac addObject:[room_array valueForKey:@"nMacintosh"]];
		[roomAvailLinux addObject:[room_array valueForKey:@"nLinux"]];
		
	} else {
	
		roomNumber = [room_array valueForKey:@"Room"];
		roomAvailWin = [room_array valueForKey:@"nWindows"];
		roomAvailMac = [room_array valueForKey:@"nMacintosh"];
		roomAvailLinux = [room_array valueForKey:@"nLinux"];
	
	}
	 
}

/*
 * Finalize all the markers by adding building info to each marker 
 * and eventually put each of them onto the map
 */
- (void) finalizeMarkers {
	
	for (int i = 0; i < [markerArray count]; i++) {
		
		// Make the marker snippet display computer avail info for each building
		[[markerArray objectAtIndex:i] setTitle:[buildingNameArray objectAtIndex:i]];
		[[markerArray objectAtIndex:i] setSnippet:[NSString stringWithFormat:@"Win:%@ Mac:%@ Linux:%@",
													[availWinArray objectAtIndex:i],
													[availMacArray objectAtIndex:i],
													[availLinuxArray objectAtIndex:i]]];
		
		// Change the color of the marker based on crowdedness
		[self changeMarkerColor:[markerArray objectAtIndex:i]];
		
		// Put the markers onto the map
		[[markerArray objectAtIndex:i] setMap:mapView];
		
	}
	
}

/*
 * Change marker color based on crowdedness
 */
- (void) changeMarkerColor:(GMSMarker *)marker {
	
	long index = [markerArray indexOfObject:marker];
	NSInteger total_avail = [[totalAvailArray objectAtIndex:index] integerValue];
	NSInteger total_computers = [[totalCompArray objectAtIndex:index] integerValue];
	
	if (total_avail < total_computers / 3)
		[marker setIcon:[UIImage imageNamed:@"computers_red"]];
	else if (total_avail >= total_computers / 3 && total_avail < total_computers * 2 / 3)
		[marker setIcon:[UIImage imageNamed:@"computers_yellow"]];
	else
		[marker setIcon:[UIImage imageNamed:@"computers_green"]];
	
}

# pragma mark - Selector Method

-(void)segmentAction:(UISegmentedControl *)Seg{
	
    switch (Seg.selectedSegmentIndex) {
			
        case 0:
			[mapView setMapType:kGMSTypeNormal];
            break;
			
        case 1:
			[mapView setMapType:kGMSTypeSatellite];
            break;
			
        case 2:
			[mapView setMapType:kGMSTypeHybrid];
            break;
			
        default:
			NSLog(@"Invalid Segment Index!");
			break;
			
    }
	
}

@end
