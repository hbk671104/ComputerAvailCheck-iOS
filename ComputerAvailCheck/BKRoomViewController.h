//
//  BKRoomViewController.h
//  ComputerAvailCheck
//
//  Created by BK on 4/15/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SOAPEngine64/SOAPEngine.h>

@interface BKRoomViewController : UITableViewController {
	
	CGFloat sectionHeaderHeight;
	SOAPEngine *soapRoom;
	
}

+ (void)setTotalRoom:(NSMutableArray *)total;
+ (void)setAvailWin:(NSMutableArray *)win;
+ (void)setAvailMac:(NSMutableArray *)mac;
+ (void)setAvailLinux:(NSMutableArray *)linux;
+ (void)setRoomNumber:(NSMutableArray *)number;
+ (void)setOppCode:(NSString *)opp;
+ (void)setOppCodeArray:(NSMutableArray *)opp_array;

- (void)setupNavigationBar;

@end
