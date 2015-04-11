//
//  analogPinTableViewCell.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class analogPinTableViewCell; //forward declaration tell the compiler this class exists, don't worry about it
@protocol analogPinCellDelegate <NSObject>

- (void) analogModeSegmentedButtonWasTapped:(analogPinTableViewCell *) cell;

@end


@interface analogPinTableViewCell : UITableViewCell
@property (weak,nonatomic) id<analogPinCellDelegate> delegate; //delegate is any object that adopt the analogPinCellDelegate protocol
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeControlButton;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@end
