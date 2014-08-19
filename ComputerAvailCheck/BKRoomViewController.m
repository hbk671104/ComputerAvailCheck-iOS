//
//  BKRoomViewController.m
//  ComputerAvailCheck
//
//  Created by BK on 4/15/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "BKRoomViewController.h"
#import "TSMessage.h"

@interface BKRoomViewController ()

@end

@implementation BKRoomViewController

static NSMutableArray *total_room = nil;
static NSMutableArray *avail_win = nil;
static NSMutableArray *avail_mac = nil;
static NSMutableArray *avail_linux = nil;
static NSMutableArray *room_number = nil;
static NSString *opp_code = nil;
static NSMutableArray *opp_code_array = nil;

+ (void)setTotalRoom:(NSMutableArray *)total {total_room = total;}
+ (void)setAvailWin:(NSMutableArray *)win {avail_win = win;}
+ (void)setAvailMac:(NSMutableArray *)mac {avail_mac = mac;}
+ (void)setAvailLinux:(NSMutableArray *)linux {avail_linux = linux;}
+ (void)setRoomNumber:(NSMutableArray *)number {room_number = number;}
+ (void)setOppCode:(NSString *)opp {opp_code = opp;}
+ (void)setOppCodeArray:(NSMutableArray *)opp_array {opp_code_array = opp_array;}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Register the reusable cell identifier
	[self.tableView registerClass:[UITableViewCell class]
		   forCellReuseIdentifier:@"UITableViewCell"];
	
	// Setup navigation bar
	[self setupNavigationBar];
	
	// Instantiate the section header height
	section_header_height = [[UIScreen mainScreen] bounds].size.height / 12;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
}

# pragma mark - GUI Setup

- (void)setupNavigationBar {
	
	// Instantiate the back bar
	//UIBarButtonItem *back_button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousViewController)];
	
	UIBarButtonItem *refresh_button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadRoomData)];
	
	// Attach it to the navigation bar
	//self.navigationItem.leftBarButtonItem = back_button;
	self.navigationItem.rightBarButtonItem = refresh_button;
	
	// Set bar tint color
	[self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
	
	// Customize the title text
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																	 [UIColor whiteColor], NSForegroundColorAttributeName,
																	 [UIFont fontWithName:@"ArialMT"
																					 size:20.0], NSFontAttributeName,
																	 nil]];
	
}

# pragma mark - Selector Method

// Dismiss the current view controller
- (void) backToPreviousViewController {
	
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
	
		// Release memory when completed
		avail_win = nil;
		avail_mac = nil;
		avail_linux = nil;
		room_number = nil;
		opp_code = nil;
		total_room = nil;
		opp_code_array = nil;
		
	}];
	
}
									   
// Refresh table view room data
- (void) reloadRoomData {
	
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
							 
							 // Reload the data
							 [self.tableView reloadData];
							 [TSMessage showNotificationInViewController:self title:@"Success:)" subtitle:nil type:TSMessageNotificationTypeSuccess duration:1.0];						
							 
						 });
						 
					 });
					 
				 } failWithError:nil];
	
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
	avail_win = [[NSMutableArray alloc] init];
	avail_mac = [[NSMutableArray alloc] init];
	avail_linux = [[NSMutableArray alloc] init];
	
	// For those building that has only one room that has available computers
	// The xml callbackr return room list as an array
	// so we have to manually add it to each array
	if ([[total_room objectAtIndex:[opp_code_array indexOfObject:opp_code]] isEqual: @"1"]) {
		
		[room_number addObject:[room_array valueForKey:@"Room"]];
		[avail_win addObject:[room_array valueForKey:@"nWindows"]];
		[avail_mac addObject:[room_array valueForKey:@"nMacintosh"]];
		[avail_linux addObject:[room_array valueForKey:@"nLinux"]];
		
	} else {
		
		room_number = [room_array valueForKey:@"Room"];
		avail_win = [room_array valueForKey:@"nWindows"];
		avail_mac = [room_array valueForKey:@"nMacintosh"];
		avail_linux = [room_array valueForKey:@"nLinux"];
		
	}
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    // Return the number of sections.
    return 3;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// Return the number of rows in each section.
	return [room_number count] + 1;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return section_header_height;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Dequeue reusable cell
	NSString *cellIdentifier = [NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	// If old one is not usable, instantiate a new one
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	// Set the cell background color
	cell.backgroundColor = [UIColor clearColor];
	// Cell not clickable
	cell.userInteractionEnabled = NO;
	
	// Instantiate the left label and the right label
	UILabel *left_label = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, cell.frame.size.width / 2, 20)];
	UILabel *right_label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 - 20, 13, cell.frame.size.width / 2, 20)];
	
	// Align the left label to the left, right label to the right
	left_label.textAlignment = NSTextAlignmentLeft;
	right_label.textAlignment = NSTextAlignmentRight;
	
	// Set the label color to white
	left_label.textColor = [UIColor whiteColor];
	right_label.textColor = [UIColor yellowColor];
	
	// Set the text to each label based on section number
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				left_label.text = @"Room Number";
				right_label.text = @"Available";
			} else {
				left_label.text = [room_number objectAtIndex:indexPath.row - 1],
				right_label.text = [avail_win objectAtIndex:indexPath.row - 1];
			}
			break;
			
		case 1:
			if (indexPath.row == 0) {
				left_label.text = @"Room Number";
				right_label.text = @"Available";
			} else {
				left_label.text = [room_number objectAtIndex:indexPath.row - 1],
				right_label.text = [avail_mac objectAtIndex:indexPath.row - 1];
			}
			break;
			
		case 2:
			if (indexPath.row == 0) {
				left_label.text = @"Room Number";
				right_label.text = @"Available";
			} else {
				left_label.text = [room_number objectAtIndex:indexPath.row - 1],
				right_label.text = [avail_linux objectAtIndex:indexPath.row - 1];
			}
			break;
			
		default:
			NSLog(@"Error!");
			break;
			
	}
	
	// Let the left and right label auto resize
	left_label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	right_label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	
	// Set two labels to the cell as two subviews
	[cell.contentView addSubview:left_label];
	[cell.contentView addSubview:right_label];
		
    return cell;
	
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	// Instantiate the view container first
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, section_header_height)];
	
	// Set view's background color
	[view setBackgroundColor:[UIColor clearColor]];
	
	// Instantiate three icons
	UIImageView *windows_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows"]];
	UIImageView *apple_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple"]];
	UIImageView *linux_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linux"]];
	
	// Set them to the center of the view
	windows_icon.center = view.center;
	apple_icon.center = view.center;
	linux_icon.center = view.center;
	
	// Add icons to different sections
	if (section == 0)
		[view addSubview:windows_icon];
	else if (section == 1)
		[view addSubview:apple_icon];
	else
		[view addSubview:linux_icon];
	
	return view;
	 
}

@end
