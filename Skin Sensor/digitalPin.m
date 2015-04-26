//
//  digitalPin.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 20/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "digitalPin.h"

@implementation digitalPin

- (id)init {
    
    self = [super init];
    
    if(self){
        self.digitalReportingEnabled = NO;
        self.pinMode = pinModeDigitalRead;
        self.pinName = @"Digital Pin Default";
        self.pinState = pinStateLow;
        self.pinStepperValue = 0;
    }
    
    return self;
}

@end
