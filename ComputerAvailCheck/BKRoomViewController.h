//
//  BKRoomViewController.h
//  ComputerAvailCheck
//
//  Created by BK on 4/15/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKRoomViewController : UITableViewController {
	
	CGFloat section_header_height;
	
}

+ (void)setAvailWin:(NSMutableArray *)win;
+ (void)setAvailMac:(NSMutableArray *)mac;
+ (void)setAvailLinux:(NSMutableArray *)linux;
+ (void)setRoomNumber:(NSMutableArray *)number;

- (void)setupNavigationBar;

@end
