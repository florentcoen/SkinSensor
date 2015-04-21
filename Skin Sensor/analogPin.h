//
//  analogPin.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 21/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pinValues.h"

@interface analogPin : NSObject

@property (nonatomic, strong) NSString *pinName;
@property (nonatomic, assign) PinMode pinMode;
@property (nonatomic, assign) PinState pinState;
@property (nonatomic, assign) double pinAnalogValue;

@end
