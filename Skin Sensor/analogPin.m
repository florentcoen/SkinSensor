//
//  analogPin.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 21/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "analogPin.h"

@implementation analogPin

- (id)init {
    
    self = [super init];
    
    if(self){
        self.pinMode = pinModeDigitalRead;
        self.pinName = @"Analog Pin Default";
        self.pinState = pinStateLow;
        self.pinAnalogValue = 0;
    }
    
    return self;
}

@end
