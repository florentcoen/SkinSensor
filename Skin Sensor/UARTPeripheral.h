//
//  UARTPeripheral.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 24/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol UARTPeripheralDelegate

- (void) uartDidEncounterError:(NSString*) error;
- (void) didReadHardwareRevisionString:(NSString*) string;
- (void) transferDataFromUARTPeripheralToMainMenu:(NSData*)newData;

@end

@interface UARTPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,weak) id<UARTPeripheralDelegate> delegate;

+ (CBUUID *)uartServiceUUID;
+ (CBUUID*)rxCharacteristicUUID;
- (UARTPeripheral*)initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate;
- (void) didConnect;
- (void) transferDataFromMainMenuToUARTPeripheral:(NSData*)data;
@end
