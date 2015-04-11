//
//  analogPinTableViewCell.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "analogPinTableViewCell.h"

@implementation analogPinTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSLog(@"%@",[NSString stringWithFormat:@"the current value for isSeleced %d",self.selected]);
    // Configure the view for the selected state
}

@end
