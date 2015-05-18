//
//  mainMenuViewController.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "mainMenuViewController.h"

@interface mainMenuViewController ()

@end

@implementation mainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.connectionStatusButton setHidden:YES];
    [self.connectionStatusProgressBar setHidden:YES];
    self.connectionMode = connectionModeNone;
    self.connectionStatus = connectionStatusDisconnected;
    self.delegatedSubview = nil;
    self.currentPeripheral = nil;
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated{
    if ((self.connectionStatus != connectionStatusDisconnected) && (self.currentPeripheral!=nil)) {
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
        self.connectionStatus = connectionStatusDisconnected;
        self.connectionMode = connectionModeNone;
        self.delegatedSubview = nil;
        self.currentPeripheral = nil;
        NSLog(@"PERIPHERAL DISCONNECTED AND INSTANCES RELEASED");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindToMainMenu:(UIStoryboardSegue *) segue{
    NSLog(@"Pressed Done button in Information View");
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"pressedInfoButton"]) {
        NSLog(@"Pressed Info button in Main Menu View");
    }
    else if ([segue.identifier isEqualToString:@"pressedShowPinIOButton"])
    {
        NSLog(@"Pressed Show Pin I/O in Main Menu View");
        [self.connectionStatusButton stopAnimating];
        [self.connectionStatusButton setHidden:YES];
        self.delegatedSubview = segue.destinationViewController; //the subview is the delegate of main menu. as such the subview implements the mainMenuControllerDelegate methods, which allow for the transfer of data from main menu to subview
        
        PinIOTableViewController* pinIOTableViewController = segue.destinationViewController;
        pinIOTableViewController.delegate = self; //main menu is the delegate of the subview. as such main menu implements the subviewControllerDelegate methods, which allow for the transfer of data from subview to main menu
    }
    else if([segue.identifier isEqualToString:@"pressedShowSkinSensorButton"])
    {
        NSLog(@"Pressed Show Skin Sensor in Main Menu View");
        [self.connectionStatusProgressBar setHidden:YES];
        [self.connectionStatusProgressBar setProgress:0.0 animated:NO];
        
        self.delegatedSubview = segue.destinationViewController; //the subview is the delegate of main menu. as such the subview implements the mainMenuControllerDelegate methods, which allow for the transfer of data from main menu to subview
        
        SkinSensorViewController* skinSensorViewController = segue.destinationViewController;
        skinSensorViewController.delegate = self; //main menu is the delegate of the subview. as such main menu implements the subviewControllerDelegate methods, which allow for the transfer of data from subview to main menu

    }
}

- (IBAction)pressedPinIOButton:(id)sender {
    [self.connectionStatusButton setHidden:NO];
    [self.connectionStatusButton startAnimating];
    
    self.connectionMode = connectionModePinIO;
    self.connectionStatus = connectionStatusScanning;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];

}
- (IBAction)pressedSkinSensorButton:(id)sender {
    [self.connectionStatusProgressBar setHidden:NO];
    [self.connectionStatusProgressBar setProgress:0.1 animated:YES];
    
    self.connectionMode = connectionModeSkinSensor;
    self.connectionStatus = connectionStatusScanning;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

#pragma mark - Custom BLE methods

- (void)connectPeripheral:(CBPeripheral*)peripheral{
    
    //Connect Bluetooth LE device
    
    //Clear off any pending connections
    [self.centralManager cancelPeripheralConnection:peripheral];
    
    //Connect
    self.currentPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    self.delegatedUARTPeripheral = self.currentPeripheral;
    
}

#pragma mark - CBCentralManagerDelegate

//called after init of CBCentralManager
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSLog(@"central manager called centralManagerDidUpdateState");
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertController *bluetoothDisabledAlert = [UIAlertController alertControllerWithTitle:@"Bluetooth Disabled!" message:@"Please enable Bluetooth in order to connect with the Skin Sensor" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){NSLog(@"Cancel bluetoothDisabledAlert");}];
        [bluetoothDisabledAlert addAction:dismissAction];
        [self presentViewController:bluetoothDisabledAlert animated:YES completion:nil];
    }
    else{
        [self.centralManager scanForPeripheralsWithServices:@[[UARTPeripheral uartServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
        [self.connectionStatusProgressBar setProgress:0.3 animated:YES];
    }
}

//called after discovery of peripheral
- (void) centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI{
    
    NSLog(@"Did discover peripheral %@", peripheral.name);
    
    [self.centralManager stopScan];
    
    [self connectPeripheral:peripheral];
    
    [self.connectionStatusProgressBar setProgress:0.5 animated:YES];
}

//called after central manager connected to peripheral
- (void) centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral{
    
    if ([self.currentPeripheral.peripheral isEqual:peripheral]){
        
        self.connectionStatus = connectionStatusConnecting;
        if(peripheral.services){
            NSLog(@"Did connect to existing peripheral %@", peripheral.name);
            //[self.currentPeripheral peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
        }
        
        else{
            NSLog(@"Did connect peripheral %@", peripheral.name);
            [self.currentPeripheral didConnect];
            [self.connectionStatusProgressBar setProgress:0.7 animated:YES];
        }
    }
}

#pragma mark - UARTPeripheralDelegate

- (void)uartDidEncounterError:(NSString*)error{
    
    //Display error alert
    NSLog(@"bluetooth Error Method Called");
    UIAlertController *bluetoothErrorAlert = [UIAlertController alertControllerWithTitle:@"Bluetooth Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){NSLog(@"Cancel bluetoothErrorAlert");}];
    [bluetoothErrorAlert addAction:dismissAction];
    [self presentViewController:bluetoothErrorAlert animated:YES completion:nil];
    
}

- (void)didReadHardwareRevisionString:(NSString*)string{
    
    //Once hardware revision string is read, connection to Bluefruit is complete
    
    NSLog(@"From mainMenuViewController HW Revision: %@", string);
    
    //Bail if we aren't in the process of connecting
    if (self.connectionStatus != connectionStatusConnecting){
        return;
    }
    
    self.connectionStatus = connectionStatusConnected;
    
    //Load appropriate view controller …
    
    //Pin I/O mode
    if (self.connectionMode == connectionModePinIO) {
        [self performSegueWithIdentifier:@"pressedShowPinIOButton"sender:self];
    }
    else if(self.connectionMode == connectionModeSkinSensor){
        [self performSegueWithIdentifier:@"pressedShowSkinSensorButton"sender:self];
        [self.connectionStatusProgressBar setProgress:1.0 animated:YES];
    }
}

- (void)transferDataFromUARTPeripheralToMainMenu:(NSData*)newData{
    
    //Data incoming from UART peripheral, forward to the appropriate view controller
    
    //Debug
    //    NSString *hexString = [newData hexRepresentationWithSpaces:YES];
    //    NSLog(@"Received: %@", newData);
    NSLog(@"WE RECEIVED DATA FROM UARTPERIPHERAL IN MAIN MENU");
    if (self.connectionStatus == connectionStatusConnected || self.connectionStatus == connectionStatusScanning) {

        //Pin I/O
        if (_connectionMode == connectionModePinIO && self.delegatedSubview != nil){
            //send data to PIN IO Controller
            [self.delegatedSubview transferDataFromMainMenuToSubcontroller:newData];
            NSLog(@"THE DELEGATE METHOD FOR PIN I/0 WAS CALLED");
        }
        
        //Skin Sensor 1.0
        if (_connectionMode == connectionModeSkinSensor && self.delegatedSubview != nil){
            //send data to PIN IO Controller
            [self.delegatedSubview transferDataFromMainMenuToSubcontroller:newData];
            NSLog(@"THE DELEGATE METHOD FOR SKIN SENSOR WAS CALLED");
        }
    }
}

#pragma mark - subviewControllerDelegate

- (void) transferDataFromSubviewToMainMenu:(NSData *)newData{
    
    //Output data to UART peripheral
    
    NSLog(@"sendData in mainMenu called sending: %@", newData);
    
    [self.delegatedUARTPeripheral transferDataFromMainMenuToSubcontroller:newData];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
