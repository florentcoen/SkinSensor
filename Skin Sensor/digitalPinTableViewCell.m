//
//  digitalPinTableViewCell.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "digitalPinTableViewCell.h"

@implementation digitalPinTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)modeSegmentedButtonTappedInDigitalPinCell:(id)sender {
    NSLog(@"the IBAction mode in the digital cell was called");
    [self.delegate digitalModeSegmentedButtonWasTapped:self];
}

- (IBAction)stateSegmentedButtonTappedInDigitalPinCell:(id)sender {
    NSLog(@"the IBAction state in the digital cell was called");
    [self.delegate digitalStateSegmentedButtonWasTapped:self];
}

- (IBAction)pvmSliderModifiedInDigitalPinCell:(id)sender {
    NSLog(@"the IBAction sliderin the digital cell was called");
    [self.delegate digitalPwmSliderWasMoved:self];
}

@end
