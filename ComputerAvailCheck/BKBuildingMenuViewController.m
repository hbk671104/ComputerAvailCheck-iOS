//
//  BKBuildingMenuViewController.m
//  ComputerAvailCheck
//
//  Created by BK on 4/12/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "BKBuildingMenuViewController.h"
#import "BKMapViewController.h"
#import "BKAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@interface BKBuildingMenuViewController ()

@end

@implementation BKBuildingMenuViewController

static NSMutableArray *building_array = nil;
static NSMutableArray *marker_array = nil;
static GMSMapView *google_map = nil;

+ (void)setBuildingArray:(NSMutableArray *)array {building_array = array; }
+ (void)setMarkerArray:(NSMutableArray *)array {marker_array = array;}
+ (void)setMapView:(GMSMapView *)map {google_map = map;}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	[self.tableView registerClass:[UITableViewCell class]
		   forCellReuseIdentifier:@"UITableViewCell"];
	
	// Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    // Return the number of sections.
    return 1;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    // Return the number of rows in the section.
    return [building_array count];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
															forIndexPath:indexPath];
	
    // Configure the cell font
	cell.textLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0];
	// Set the background color
	cell.backgroundColor = [UIColor clearColor];
	// Set the text color
	cell.textLabel.textColor = [UIColor whiteColor];
	
	// Set the cell text
    cell.textLabel.text = [building_array objectAtIndex:indexPath.row];
	
    return cell;
	
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Instantiate a new marker object for each cell
	GMSMarker *marker = [marker_array objectAtIndex:indexPath.row];
	
	[[BKAppDelegate globalDelegate].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
		
		GMSMapView *mapView = [BKAppDelegate globalDelegate].mapViewController.mapView;
		[mapView animateToLocation:marker.position];
		[mapView setSelectedMarker:marker];
		
	}];
	
}

- (void) viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void) viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

@end
