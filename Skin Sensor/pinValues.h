//
//  pinValues.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 20/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#ifndef Skin_Sensor_pinValues_h
#define Skin_Sensor_pinValues_h
typedef enum {
    pinModeUnknown = -1,
    pinModeDigitalRead,
    pinModeDigitalWrite,
    pinModeAnalogRead,
    pinModeDigitalPwm,
} PinMode;

typedef enum {
    pinStateUnknown = -1,
    pinStateLow,
    pinStateHigh,
} PinState;

typedef enum {
    bundleD7D6D5D5D4D3D2D1D0,
    bundleA1A0D13D12D11D10D9D8,
    bundleA5A4A3A2
} PinsBundle;

#endif
