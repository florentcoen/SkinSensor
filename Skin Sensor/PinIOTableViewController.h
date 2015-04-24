//
//  PinIOTableViewController.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "analogPinTableViewCell.h"
#import "digitalPinTableViewCell.h"
#import "digitalPin.h"
#import "analogPin.h"

@interface PinIOTableViewController : UITableViewController <digitalPinCellDelegate,analogPinCellDelegate>
@property (nonatomic,strong) NSMutableArray *digitalPinsArray;
@property (nonatomic,strong) NSMutableArray *analogPinsArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *debugButton;

- (void) transferDataFromMainMenuToSubview:(NSData*)newData;
@end
