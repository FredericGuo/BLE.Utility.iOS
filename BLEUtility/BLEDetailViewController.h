//
//  DetailViewControllerTableViewController.h
//  BLEUtility
//
//  Created by cerise guo on 6/14/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdvertisementData.h"

@interface BLEDetailViewController : UITableViewController

@property (nonatomic,strong) AdvertisementData * bleDataFromParent;

@end
