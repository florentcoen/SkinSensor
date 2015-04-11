//
//  analogPinTableViewCell.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface analogPinTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeControlButton;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@end
