//
//  digitalPinTableViewCell.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pinModeValues.h"

@class digitalPinTableViewCell; //forward declaration. tell the compiler this class exists, don't worry about it it's defined later
@protocol digitalPinCellDelegate <NSObject>

- (void) digitalModeSegmentedButtonWasTapped:(digitalPinTableViewCell *) cell;
- (void) digitalStateSegmentedButtonWasTapped:(digitalPinTableViewCell *) cell;
- (void) digitalPwmSliderWasMoved:(digitalPinTableViewCell *) cell;
@end

@interface digitalPinTableViewCell : UITableViewCell

@property (weak, nonatomic) id<digitalPinCellDelegate> delegate; //delegate is any object that adopt the digitalpinCellDelegate protocol
@property (nonatomic) PinMode pinMode;

@property (strong, nonatomic) IBOutlet UISegmentedControl *modeControlButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *stateControlButton;
@property (strong, nonatomic) IBOutlet UILabel *pinNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *pinValueLabel;
@property (strong, nonatomic) IBOutlet UISlider *pwmSlider;




@end
