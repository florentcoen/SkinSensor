//
//  skinSensorValues.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 18/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface skinSensorValues : NSObject

@property double bodyTemperature;
@property double thermistorA0Temperature;
@property double thermistorA1Temperature;

@property double sensorF0Humdity;
@property double sensorF0Temperature;
@property double sensorF1Humidity;
@property double sensorF1Temperature;

@property (strong, nonatomic) NSString* timeStamp;

@end
