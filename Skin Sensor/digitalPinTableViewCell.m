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

- (IBAction)segmentedButtonTappedInDigitalPinCell:(id)sender {
    NSLog(@"the IBAction in the digital cell was called");
    [self.delegate digitalModeSegmentedButtonWasTapped:self];
}


@end
