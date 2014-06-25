//
//  BKRoomViewController.m
//  ComputerAvailCheck
//
//  Created by BK on 4/15/14.
//  Copyright (c) 2014 Penn State. All rights reserved.
//

#import "BKRoomViewController.h"

@interface BKRoomViewController ()

@end

@implementation BKRoomViewController

static NSMutableArray *avail_win = nil;
static NSMutableArray *avail_mac = nil;
static NSMutableArray *avail_linux = nil;
static NSMutableArray *room_number = nil;

+ (void)setAvailWin:(NSMutableArray *)win {avail_win = win;}
+ (void)setAvailMac:(NSMutableArray *)mac {avail_mac = mac;}
+ (void)setAvailLinux:(NSMutableArray *)linux {avail_linux = linux;}
+ (void)setRoomNumber:(NSMutableArray *)number {room_number = number;};

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

- (void)setupNavigationBar {
	
	// Instantiate the back bar
	UIBarButtonItem *back_button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousViewController)];
	
	// Attach it to the navigation bar
	self.navigationItem.leftBarButtonItem = back_button;
	
	// Set bar tint color
	[self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
	
	// Customize the title text
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																	 [UIColor whiteColor], NSForegroundColorAttributeName,
																	 [UIFont fontWithName:@"ArialMT"
																					 size:20.0], NSFontAttributeName,
																	 nil]];
	
}

// Dismiss the current view controller
- (void)backToPreviousViewController {
	
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
	
		// Release memory when completed
		avail_win = nil;
		avail_mac = nil;
		avail_linux = nil;
		room_number = nil;
		
	}];
	
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

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return section_header_height;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Instantiate a cell
	/*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
															forIndexPath:indexPath];
	*/
	
	// Instantiate a cell
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												   reuseIdentifier:@"UITableViewCell"];
	
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

	/*
	// Clear all the subview in a cell before drawing new content 
	for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
	*/
	
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
