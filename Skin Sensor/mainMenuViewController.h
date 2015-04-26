//
//  mainMenuViewController.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UARTPeripheral.h"
#import "PinIOTableViewController.h"

@interface mainMenuViewController : UIViewController <CBCentralManagerDelegate, UARTPeripheralDelegate, PinIOViewControllerDelegate>

typedef enum {
    connectionStatusDisconnected = 0,
    connectionStatusScanning,
    connectionStatusConnecting,
    connectionStatusConnected
} connectionStatus;

typedef enum {
    connectionModeNone = 0,
    connectionModePinIO
} connectionMode;

@property (nonatomic, assign) connectionStatus connectionStatus;
@property (nonatomic, assign) connectionMode connectionMode;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) UARTPeripheral *currentPeripheral;

@property (nonatomic, strong) PinIOTableViewController *pinIOViewController;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *connectionStatusButton;

-(IBAction)unwindToMainMenu:(UIStoryboardSegue *) segue;

@end
