//
//  pinModeValues.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 20/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#ifndef Skin_Sensor_pinModeValues_h
#define Skin_Sensor_pinModeValues_h

typedef enum {
    pinModeUnknown = -1,
    pinModeDigitalRead,
    pinModeDigitalWrite,
    pinModeAnalogRead,
    pinModeDigitalPwm,
} PinMode;

#endif
