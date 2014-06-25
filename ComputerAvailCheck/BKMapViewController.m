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

@implementation BKMapViewController

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
		NSLog(@"Hello");
		
		// Add map to the view
		[self addGoogleMap];
		
		// Instantiate all the markers
		[self initializeMarkers];

		// Show progress bar until all the markers have been finalized
		[MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
	
		// Instantiate a soap engine for building
		soap_building = [[SOAPEngine alloc] init];
		soap_building.actionNamespaceSlash = YES;
		soap_building.version = VERSION_1_1;
		soap_building.delegate = self;
		
		// Add the parameter to the soap request and make a request
		[soap_building setValue:@"UP" forKey:@"Campus"];
		[soap_building requestURL:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx"
					   soapAction:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Buildings"];
	
		NSLog(@"Map View Loaded Successfully!");
		
	}
	
}
 
/*
 * When the map view is about to disappear, cut out useless the references
 * in order to release memory
 */
- (void) viewWillDisappear:(BOOL)animated {
	
	room_number = nil;
	room_avail_win = nil;
	room_avail_mac = nil;
	room_avail_linux = nil;
	
	NSLog(@"Released!");
	
}

#pragma mark - SOAPEngine Delegate

/*
 * Callback when getting responses
 */
- (void) soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
	
	// After getting the response, parse building data in a separate thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		NSLog(@"SOAP Building Response Received!");
		
		// Parse and put all the building data into their corresponding array
		[self queryBuildingData];
		
		// After all the array has been fully loaded, update UI back in the
		// main thread
		dispatch_async(dispatch_get_main_queue(), ^{
			
			// Send those data to Building Menu View controller
			[BKBuildingMenuViewController setBuildingArray:building_name_array];
			[BKBuildingMenuViewController setMarkerArray:marker_array];
			[BKBuildingMenuViewController setMapView:map_view];
		
			// Add building data to each correponding marker
			[self finalizeMarkers];
			
			// Dismiss the progress bar
			[MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
			
		});
		
	});
	
}

/*
 * Callback when the request failed
 */
- (void) soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
	
	NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    NSLog(@"%@", msg);
	
}

/*
 * Callback when it receives response code
 */
- (BOOL) soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode {
	
    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
		
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        NSLog(@"%@", msg);
        
        return NO;
		
    }
    
    return YES;
	
}

# pragma mark - GMSMapView Delegate

/*
 * Callback when info window has been tapped
 */
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
	
	// Get the opp code first
	NSString *opp_code = [opp_code_array objectAtIndex:[marker_array indexOfObject:marker]];
	
	// Instantiate a soap engine
	soap_room = [[SOAPEngine alloc] init];
	soap_room.actionNamespaceSlash = YES;
	soap_room.version = VERSION_1_1;
	soap_room.delegate = self;
	
	// Add the parameter to the soap request and make a request
	[soap_room setValue:opp_code forKey:@"OppCode"];
	[soap_room requestURL:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Service.asmx"
			   soapAction:@"https://clc.its.psu.edu/ComputerAvailabilityWS/Rooms"
				complete:^(NSInteger statusCode, NSString *stringXML) {
					
					// After getting the response, parse building data in a separate thread
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
						
						NSLog(@"SOAP Room Response Received!");
						
						// Parse and put all the building data into their corresponding array
						[self queryRoomData:opp_code];
						
						// After all the array has been fully loaded, update UI back in the
						// main thread
						dispatch_async(dispatch_get_main_queue(), ^{
							
							BKRoomViewController *room_view_c = [[BKRoomViewController alloc] init];
							UINavigationController *navi_c = [[UINavigationController alloc] initWithRootViewController:room_view_c];
							
							// Set the title
							room_view_c.navigationItem.title = [building_name_array objectAtIndex:[marker_array indexOfObject:marker]];
							
							// Pass the data to the room view controller
							[BKRoomViewController setAvailWin:room_avail_win];
							[BKRoomViewController setAvailMac:room_avail_mac];
							[BKRoomViewController setAvailLinux:room_avail_linux];
							[BKRoomViewController setRoomNumber:room_number];
							
							// Push it to the Room view controller
							[self presentViewController:navi_c animated:YES completion:nil];
							
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
	map_view = [GMSMapView mapWithFrame:frame camera:camera];
	
	// Enable users' location
	map_view.myLocationEnabled = YES;
	map_view.settings.myLocationButton = YES;
	
	// Enable compass button
	map_view.settings.compassButton = YES;
	
	// Set the delegate to itself
	map_view.delegate = self;
	
	// Add the map view as a subview
	[self.view addSubview:map_view];
		
}

/*
 * Add building markers
 */
- (void) initializeMarkers {
	
	// Initialized the marker array and populate it
	marker_array = [[NSMutableArray alloc] init];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.803636, -77.863764)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799342, -77.861819)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.809053, -77.855428)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.803926, -77.865199)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799135, -77.868380)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798325, -77.867731)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798116, -77.862798)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794266, -77.865405)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.804889, -77.856182)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.792146, -77.870880)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801011, -77.863638)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.806479, -77.862265)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.799691, -77.869528)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.80483,  -77.863994)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.793742, -77.862985)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796982, -77.861375)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796544, -77.859884)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794668, -77.865838)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798136, -77.861272)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.793673, -77.868112)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.807461, -77.866494)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798144, -77.870666)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.800934, -77.861492)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798623, -77.870312)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798607, -77.862223)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798493, -77.865452)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.800239, -77.864937)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801129, -77.858510)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.798233, -77.868628)]];
	//[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795435, -77.868651)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.794757, -77.862641)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.796962, -77.865757)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.801108, -77.866744)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.79323,  -77.866857)]];
	//[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795715, -77.867405)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.80294,  -77.866079)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.797546, -77.866610)]];
	[marker_array addObject:[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(40.795967, -77.864255)]];
	
}

/*
 * Query building result
 */
- (void) queryBuildingData {
	
	// Convert the raw xml result into NSDictionary
	NSDictionary *dic_result = [soap_building dictionaryValue];
	
	// Get down the hierarchy to the building array
	NSMutableArray *building_array = [[[dic_result valueForKey:@"diffgram"]
								valueForKey:@"DocumentElement"]
							   valueForKey:@"Buildings"];
	
	// Instantiate each array
	opp_code_array = [[NSMutableArray alloc] init];
	building_name_array = [[NSMutableArray alloc] init];
	total_room_array = [[NSMutableArray alloc] init];
	total_comp_array = [[NSMutableArray alloc] init];
	total_avail_array = [[NSMutableArray alloc] init];
	avail_win_array = [[NSMutableArray alloc] init];
	avail_mac_array = [[NSMutableArray alloc] init];
	avail_linux_array = [[NSMutableArray alloc] init];
	
	// Populate each array
	opp_code_array = [building_array valueForKey:@"OppCode"];
	building_name_array = [building_array valueForKey:@"Building"];
	total_room_array = [building_array valueForKey:@"nRooms"];
	total_comp_array = [building_array valueForKey:@"nComputers"];
	total_avail_array = [building_array valueForKey:@"nAvailable"];
	avail_win_array = [building_array valueForKey:@"nWindows"];
	avail_mac_array = [building_array valueForKey:@"nMacintosh"];
	avail_linux_array = [building_array valueForKey:@"nLinux"];
	 
}

/*
 * Query room result
 */
- (void) queryRoomData:(NSString *)opp_code {
	
	// Convert the raw xml result into NSDictionary
	NSDictionary *dic_result = [soap_room dictionaryValue];

	// Get down the hierarchy to the room array
	NSMutableArray *room_array = [[[dic_result valueForKey:@"diffgram"]
								   valueForKey:@"DocumentElement"]
								  valueForKey:@"Rooms"];
	
	// Instantiate the available arrays
	room_number = [[NSMutableArray alloc] init];
	room_avail_win = [[NSMutableArray alloc] init];
	room_avail_mac = [[NSMutableArray alloc] init];
	room_avail_linux = [[NSMutableArray alloc] init];
	
	// For those building that has only one room that has available computers
	// The xml callbackr return room list as an array
	// so we have to manually add it to each array
	if ([[total_room_array objectAtIndex:[opp_code_array indexOfObject:opp_code]] isEqual: @"1"]) {
		
		[room_number addObject:[room_array valueForKey:@"Room"]];
		[room_avail_win addObject:[room_array valueForKey:@"nWindows"]];
		[room_avail_mac addObject:[room_array valueForKey:@"nMacintosh"]];
		[room_avail_linux addObject:[room_array valueForKey:@"nLinux"]];
		
	} else {
	
		room_number = [room_array valueForKey:@"Room"];
		room_avail_win = [room_array valueForKey:@"nWindows"];
		room_avail_mac = [room_array valueForKey:@"nMacintosh"];
		room_avail_linux = [room_array valueForKey:@"nLinux"];
	
	}
	
}

/*
 * Finalize all the markers by adding building info to each marker 
 * and eventually put each of them onto the map
 */
- (void) finalizeMarkers {
	
	for (int i = 0; i < [marker_array count]; i++) {
		
		// Make the marker snippet display computer avail info for each building
		[[marker_array objectAtIndex:i] setTitle:[building_name_array objectAtIndex:i]];
		[[marker_array objectAtIndex:i] setSnippet:[NSString stringWithFormat:@"Win:%@ Mac:%@ Linux:%@",
													[avail_win_array objectAtIndex:i],
													[avail_mac_array objectAtIndex:i],
													[avail_linux_array objectAtIndex:i]]];
		
		// Change the color of the marker based on crowdedness
		[self changeMarkerColor:[marker_array objectAtIndex:i]];
		
		// Put the markers onto the map
		[[marker_array objectAtIndex:i] setMap:map_view];
		
	}
	
}

/*
 * Change marker color based on crowdedness
 */
- (void) changeMarkerColor:(GMSMarker *)marker {
	
	long index = [marker_array indexOfObject:marker];
	NSInteger total_avail = [[total_avail_array objectAtIndex:index] integerValue];
	NSInteger total_computers = [[total_comp_array objectAtIndex:index] integerValue];
	
	if (total_avail < total_computers / 3)
		[marker setIcon:[UIImage imageNamed:@"computers_red"]];
	else if (total_avail >= total_computers / 3 && total_avail < total_computers * 2 / 3)
		[marker setIcon:[UIImage imageNamed:@"computers_yellow"]];
	else
		[marker setIcon:[UIImage imageNamed:@"computers_green"]];
	
}

@end
