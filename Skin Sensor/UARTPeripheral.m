//
//  UARTPeripheral.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 24/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "UARTPeripheral.h"

#pragma mark - UUIDs

@implementation UARTPeripheral

+ (CBUUID *)uartServiceUUID{
    
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID*)deviceInformationServiceUUID{
    //2bytes long UUID
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID*)txCharacteristicUUID{
    
    return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
}


+ (CBUUID*)rxCharacteristicUUID{
    
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID*)hardwareRevisionUUID{
    
    return [CBUUID UUIDWithString:@"2A27"];
}

#pragma mark - Utility methods

- (UARTPeripheral*)initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate{
    
    if (self = [super init]){
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.delegate = delegate;
    }
    return self;
}

- (void) didConnect{
    
    if(self.peripheral.services){
        NSLog(@"Skipping service discovery for %@",self.peripheral.name);
        [self peripheral:self.peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
        return;
    }
    NSLog(@"Starting service discovery for %@",self.peripheral.name);
    [self.peripheral discoverServices:@[[[self class] uartServiceUUID], [[self class] deviceInformationServiceUUID]]];
}


#pragma mark - CBPeripheral Delegate methods


- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error{
    
    //Respond to finding a new service on peripheral
    
    NSLog(@"Did discover services");
    
    if (!error) {
        
        for (CBService *s in peripheral.services){
            
            NSLog(@"service being inspected UUID %@",s.UUID.UUIDString);
            
            if (s.characteristics){
                
                NSLog(@"Skipping characteristics discovery for %@",self.peripheral.name);
                [self peripheral:peripheral didDiscoverCharacteristicsForService:s error:nil]; //already discovered characteristic before, DO NOT do it again
            }
            
            else if ([s.UUID isEqual:[[self class] uartServiceUUID]]){
                
                NSLog(@"Found uart service (UUID %@)",s.UUID.UUIDString);
                [self.peripheral discoverCharacteristics:@[[[self class] txCharacteristicUUID], [[self class] rxCharacteristicUUID]] forService:s];
            }
            
            else if ([s.UUID isEqual:[[self class] deviceInformationServiceUUID]]){
                
                NSLog(@"Found info service (UUID %@)",s.UUID.UUIDString);
                [self.peripheral discoverCharacteristics:@[[[self class] hardwareRevisionUUID]] forService:s];
            }
        }
    }
    
    else{
        
        NSLog(@"Error while discovering services %@",error.description);
        
        [self.delegate uartDidEncounterError:@"Error discovering services"];
        return;
    }
    
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error{
    
    //Respond to finding a new characteristic on service
    
    if (!error){
        NSLog(@"did discoverCharacteristicsForService %@",service.UUID.UUIDString);
        if([service.UUID isEqual:[[self class] deviceInformationServiceUUID]]){
            
            //last service discovered
            NSLog(@"Found all characteristics");
            [self setupPeripheralForUse:peripheral];
        }
    }
    
    else{
        
        NSLog(@"Error while discovering characteristics %@",error.description);
        [self.delegate uartDidEncounterError:@"Error discovering characteristics"];
        return;
    }
    
}

- (void)setupPeripheralForUse:(CBPeripheral*)peripheral{
    
    NSLog(@"Set up peripheral for user");
    
    for (CBService *s in peripheral.services) {
        
        for (CBCharacteristic *c in s.characteristics){
            
            if ([c.UUID isEqual:[[self class] rxCharacteristicUUID]]){
                
                NSLog(@"setupPeripheralForUse: found rxCharacteristic");
                [self.peripheral setNotifyValue:YES forCharacteristic:c];
            }
            
            else if ([c.UUID isEqual:[[self class] txCharacteristicUUID]]){
                
                NSLog(@"setupPeripheralForUse: found txCharacteristic");
            }
            
            else if ([c.UUID isEqual:[[self class] hardwareRevisionUUID]]){
                
                NSLog(@"setupPeripheralForUse: found hardwareRevision");
                [self.peripheral readValueForCharacteristic:c];
                
                //Once hardware revision string is read connection will be complete …
                
            }
            
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error{
    
    //Respond to value change on peripheral
    NSLog(@"Received: %@", characteristic.value);
    if (!error){
        if ([characteristic.UUID isEqual:[UARTPeripheral rxCharacteristicUUID]]){
            
            NSLog(@"Received: %@", characteristic.value);
            
            [self.delegate transferDataFromUARTPeripheralToMainMenu:characteristic.value];
        }
        
        else if ([characteristic.UUID isEqual:[UARTPeripheral hardwareRevisionUUID]]){
            
            NSString *hwRevision = @"";
            const uint8_t *bytes = characteristic.value.bytes;
            for (int i = 0; i < characteristic.value.length; i++){
                
                hwRevision = [hwRevision stringByAppendingFormat:@"0x%x, ", bytes[i]];
            }
            NSLog(@"Read hardware revision string %@ treated %@",characteristic.value,hwRevision);
            [self.delegate didReadHardwareRevisionString:[hwRevision substringToIndex:hwRevision.length-2]];
        }
    }
    
    else{
        
        NSLog(@"Error receiving notification for characteristic %@, msg: %@", characteristic.UUID.UUIDString, error.description);
        [self.delegate uartDidEncounterError:@"Error receiving notification for characteristic"];
        
        return;
    }
    
}

#pragma mark - mainMenuViewControllerDelegate protocol - Outgoing Communication

- (void)transferDataFromMainMenuToSubcontroller:(NSData*)data{
    NSLog(@"writeRawData in UARTPeripheral was called");
    //Send data to peripheral
    //compare the 0xXX hexa number representing the state of the properties of txCharac to see if writewithoutresponse is enabled
    for (CBService *s in self.peripheral.services) {
        
        for (CBCharacteristic *c in s.characteristics){
            
            if ([c.UUID isEqual:[[self class] txCharacteristicUUID]]){
                
                if ((c.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0){
                    
                    [self.peripheral writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
                }
                else if ((c.properties & CBCharacteristicPropertyWrite) != 0){
                    [self.peripheral writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
                }
                else{
                    NSLog(@"No write property on TX characteristic, %d.", (int)c.properties);
                }
            }
            
        }
        
    }
    
}

@end
