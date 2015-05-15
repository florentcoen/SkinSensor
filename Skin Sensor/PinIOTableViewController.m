//
//  PinIOTableViewController.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 10/04/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "PinIOTableViewController.h"

#define SECTION_COUNT 2
#define ROW_HEIGHT 132
#define DIGIAL_PINS_SECTION 0
#define ANALOG_PINS_SECTION 1
#define NUMBER_OF_DIGITAL_PINS 6
#define NUMBER_OF_ANALOG_PINS 6
#define NUMBER_OF_PORTS 3 //port D = port 0 (pins D0-D7), port B = port 1 (pins D8-D15), port C = port 2 (pins A0 to A7)


@interface PinIOTableViewController ()

@end

@implementation PinIOTableViewController

- (void) loadInitialData{
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        digitalPin *pin = [[digitalPin alloc] init];
        pin.pinName = [NSString stringWithFormat:@"Digital Pin %d",i+3];
        [self.digitalPinsArray addObject:pin];
    }
    
    for (int i = 0; i<NUMBER_OF_ANALOG_PINS; i++) {
        analogPin *pin = [[analogPin alloc] init];
        pin.pinName = [NSString stringWithFormat:@"Analog Pin %d",i];
        [self.analogPinsArray addObject:pin];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UINib *digitalPinNib = [UINib nibWithNibName:@"digitalPinTableViewCell" bundle:nil];
    [[self tableView] registerNib:digitalPinNib forCellReuseIdentifier:@"digitalPin"];
    UINib *analogPinNib = [UINib nibWithNibName:@"analogPinTableViewCell" bundle:nil];
    [[self tableView] registerNib:analogPinNib forCellReuseIdentifier:@"analogPin"];
    
    self.digitalPinsArray = [[NSMutableArray alloc] init];
    self.analogPinsArray = [[NSMutableArray alloc] init];
    [self loadInitialData];
    
    [self.tableView reloadData];
    for (int i = 0; i<NUMBER_OF_PORTS; i++) {
        [self setDigitalReportingForPort:i enabled:YES];
    }
    for (int i = 0; i<NUMBER_OF_ANALOG_PINS; i++) {
        [self setPinMode: pinModeDigitalRead forAnalogPin:[self.analogPinsArray objectAtIndex:i]];
    }
    for (int i = 0; i<NUMBER_OF_DIGITAL_PINS; i++) {
        [self setPinMode: pinModeDigitalRead forDigitalPin:[self.digitalPinsArray objectAtIndex:i]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == DIGIAL_PINS_SECTION) {
        return @"Digital Pins";
    }
    else{
        return @"Analog Pins";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == DIGIAL_PINS_SECTION) {
        return NUMBER_OF_DIGITAL_PINS;
    }
    else{
        return NUMBER_OF_ANALOG_PINS;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == DIGIAL_PINS_SECTION){
        digitalPinTableViewCell *cell = (digitalPinTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"digitalPin"];
        digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
        
        cell.delegate = self;
        cell.pinNameLabel.text = digitalPinAtIndexPath.pinName;
        if ((indexPath.row == 1) || (indexPath.row == 4) || (indexPath.row == 5)) { //only pins D3,D5,D6 support PWM mode
            [cell.modeControlButton setEnabled:NO forSegmentAtIndex:2];
        }
        else{
            [cell.modeControlButton setEnabled:YES forSegmentAtIndex:2];
        }
        
        if (digitalPinAtIndexPath.pinMode == pinModeDigitalRead) {
            [cell.pwmStepper setHidden:YES];
            [cell.stateControlButton setEnabled:NO];
            [cell.stateControlButton setHidden:NO];
            
            [cell.modeControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinMode];
            [cell.stateControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinState];
            if (digitalPinAtIndexPath.pinState == pinStateLow) {
                cell.pinValueLabel.text = @"Low";
            }
            else{
                cell.pinValueLabel.text = @"High";
            }
        }
        else if(digitalPinAtIndexPath.pinMode == pinModeDigitalWrite){
            [cell.pwmStepper setHidden:YES];
            [cell.stateControlButton setEnabled:YES];
            [cell.stateControlButton setHidden:NO];
            
            [cell.modeControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinMode];
            [cell.stateControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinState];
            if (digitalPinAtIndexPath.pinState == pinStateLow) {
                cell.pinValueLabel.text = @"Low";
            }
            else{
                cell.pinValueLabel.text = @"High";
            }
        }
        else if(digitalPinAtIndexPath.pinMode == pinModeDigitalPwm){
            [cell.pwmStepper setHidden:NO];
            [cell.stateControlButton setHidden:YES];
            
            [cell.modeControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinMode-1];
            [cell.stateControlButton setSelectedSegmentIndex:digitalPinAtIndexPath.pinState];
            cell.pinValueLabel.text = [NSString stringWithFormat:@"%d",digitalPinAtIndexPath.pinStepperValue];
        }

        return cell;
        
    }
    else{
        
        analogPinTableViewCell *cell = (analogPinTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"analogPin"];
        analogPin *analogPinAtIndexPath = [self.analogPinsArray objectAtIndex:indexPath.row];
        
        cell.delegate = self;
        cell.pinNameLabel.text = analogPinAtIndexPath.pinName;
        [cell.modeControlButton setSelectedSegmentIndex:analogPinAtIndexPath.pinMode];
        
        if (analogPinAtIndexPath.pinMode == pinModeDigitalRead) {
            [cell.stateControlButton setEnabled:NO];
            
            [cell.stateControlButton setSelectedSegmentIndex:analogPinAtIndexPath.pinState];
            if (analogPinAtIndexPath.pinState == pinStateLow) {
                cell.pinValueLabel.text = @"Low";
            }
            else{
                cell.pinValueLabel.text = @"High";
            }
        }
        else if (analogPinAtIndexPath.pinMode == pinModeDigitalWrite){
            [cell.stateControlButton setEnabled:YES];
            
            [cell.stateControlButton setSelectedSegmentIndex:analogPinAtIndexPath.pinState];
            if (analogPinAtIndexPath.pinState == pinStateLow) {
                cell.pinValueLabel.text = @"Low";
            }
            else{
                cell.pinValueLabel.text = @"High";
            }
        }
        else if(analogPinAtIndexPath.pinMode == pinModeAnalogRead){
            [cell.stateControlButton setEnabled:NO];
            
            [cell.stateControlButton setSelectedSegmentIndex:analogPinAtIndexPath.pinState];
            cell.pinValueLabel.text = [NSString stringWithFormat:@"%d",analogPinAtIndexPath.pinAnalogValue];
        }
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - Table Cell Protocol

- (void) digitalModeSegmentedButtonWasTapped:(digitalPinTableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    if (cell.modeControlButton.selectedSegmentIndex == 2) {
        digitalPinAtIndexPath.pinMode = pinModeDigitalPwm; //pinModeDigitalPvm = 3 while the button = 2 => correction required
        [self setPinMode: pinModeDigitalPwm forDigitalPin: digitalPinAtIndexPath];
    }
    else{
        digitalPinAtIndexPath.pinMode = cell.modeControlButton.selectedSegmentIndex;
        [self setPinMode: digitalPinAtIndexPath.pinMode forDigitalPin: digitalPinAtIndexPath];
    }
    [self.tableView reloadData];
}

- (void) digitalStateSegmentedButtonWasTapped:(digitalPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    digitalPinAtIndexPath.pinState = cell.stateControlButton.selectedSegmentIndex;
    [self setPinStateforDigitalPin: digitalPinAtIndexPath];
    [self.tableView reloadData];
}

- (void) digitalPwmStepperWasTapped:(digitalPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    digitalPinAtIndexPath.pinStepperValue = cell.pwmStepper.value;
    [self setPWMValue:digitalPinAtIndexPath.pinStepperValue forDigitalPin:digitalPinAtIndexPath];
    [self.tableView reloadData];
}

- (void) analogModeSegmentedButtonWasTapped:(analogPinTableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    analogPin *analogPinAtIndexPath = [self.analogPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The analog protocol was executed correctly and this button press has been transmitted");
    analogPinAtIndexPath.pinMode = cell.modeControlButton.selectedSegmentIndex;
    [self setPinMode:analogPinAtIndexPath.pinMode forAnalogPin:analogPinAtIndexPath];
    [self.tableView reloadData];
}

- (void) analogStateSegmentedButtonWasTapped:(analogPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    analogPin *analogPinAtIndexPath = [self.analogPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The analog protocol was executed correctly and this button press has been transmitted");
    analogPinAtIndexPath.pinState = cell.stateControlButton.selectedSegmentIndex;
    [self setPinStateforAnalogPin:analogPinAtIndexPath];
    [self.tableView reloadData];
}

#pragma mark - mainMenuViewControllerDelegate Protocol

- (void) transferDataFromMainMenuToSubview:(NSData *)newData{
    
    NSLog(@"Data received in PinIO: %@", newData);
    //Respond to incoming data from MainMenuViewController
    uint8_t data[20];
    static uint8_t buf[512];
    static int length = 0;
    int dataLength = (int)newData.length;
    
    [newData getBytes:&data length:dataLength]; //copy incoming new data into buffer data
    
    if (dataLength < 20){ //newData smaller than 20 bytes are directly processed and length is reset
        
        memcpy(&buf[length], data, dataLength);
        length += dataLength;
        
        [self processInputData:buf withLength:length];
        length = 0;
    }
    
    else if (dataLength == 20){ //new Data of 20 bytes are stored inside buf and send by packet of 64 bytes or more
        
        memcpy(&buf[length], data, 20);
        length += dataLength;
        
        if (length >= 64){
            
            [self processInputData:buf withLength:length];
            length = 0;
        }
    }
    
}

#pragma mark - Communication Incoming Data

- (void)processInputData:(uint8_t*)data withLength:(int)length{
    
    //Parse data we received
    
    //each message is 3 bytes long
    for (int i = 0; i < length; i+=3){
        
        //Pin D0 to D7 in mode digital read
        if (data[i] == 0x90) {
            uint8_t pinStates = data[i+1];
            pinStates |= data[i+2] << 7;    //use LSB of third byte for pin7
            [self updatePinsBundle: bundleD7D6D5D5D4D3D2D1D0 withPinsStates: pinStates];
            return;
        }
        
        //Pins A1 A0 D13 D12 D11 D10 D9 D8 in mode digital read => D14 & D15 connected to crystal
        else if (data[i] == 0x91){
            uint8_t pinStates = data[i+1];
            pinStates |= (data[i+2] << 7);  //pins A0 & A1
            [self updatePinsBundle: bundleA1A0D13D12D11D10D9D8 withPinsStates: pinStates];
            return;
        }
        
        //Pins A2 to A5 in mode digital read
        else if (data[i] == 0x92) {
            uint8_t pinStates = data[i+1];
            [self updatePinsBundle: bundleA5A4A3A2 withPinsStates: pinStates];
            return;
        }
        
        //Analog Reporting (per pin) pins A0 to A5 in mode analog read
        else if ((data[i] >= 0xe0) && (data[i] <= 0xe5)){
            
            int pinIndex = data[i] - 0xe0;
            int newAnalogvalue = data[i+1] + (data[i+2]<<7);
            NSLog(@"pin %d has received info to be updated with value %d",pinIndex,newAnalogvalue);
            if (pinIndex < self.analogPinsArray.count) {
                
                analogPin * updatedAnalogPin= [self.analogPinsArray objectAtIndex:pinIndex];
                
                if(updatedAnalogPin.pinMode == pinModeAnalogRead){
                    
                    updatedAnalogPin.pinAnalogValue = newAnalogvalue;
                    [self.tableView reloadData];
                }
            }
        }
    }
}

- (void)updatePinsBundle:(PinsBundle) pinsBundle withPinsStates: (uint8_t)pinStates{
    
    //Update pin table with new pin values received in the bundle

    if (pinsBundle == bundleD7D6D5D5D4D3D2D1D0) {
        
        for (int i = 3; i<=7; i++) {
            
            uint8_t state = pinStates;
            uint8_t mask = 1 << i;
            state = state & mask;
            state = state >> i; //isolate the bit representing the pin value and placing it at LSB position
            
            digitalPin *updatedDigitalPin = [self.digitalPinsArray objectAtIndex:i-3]; //pin D3 is stored at index 0 in digitalPinArray
            if (updatedDigitalPin.pinMode == pinModeDigitalRead) {
                updatedDigitalPin.pinState = state;
            }
        }
    }
    
    else if(pinsBundle == bundleA1A0D13D12D11D10D9D8){
        
        //take care of D8
        uint8_t state = pinStates;
        uint8_t mask = 1;
        state = state & mask; //isolate the bit representing the pin value and placing it at LSB position
        
        digitalPin *updatedDigitalPin = [self.digitalPinsArray objectAtIndex:5]; //pin D8 is stored at index 5 in digitalPinArray
        if (updatedDigitalPin.pinMode == pinModeDigitalRead) {
            updatedDigitalPin.pinState = state;
        }
        
        //take care of A0 and A1
        for (int i = 6; i <=7; i++) {
            state = pinStates;
            mask = 1 << i;
            state = state & mask;
            state = state >> i;
            
            analogPin *updatedAnalogPin = [self.analogPinsArray objectAtIndex:i-6]; //since A0 is stored at index 0 in analogPinsArray
            if (updatedAnalogPin.pinMode == pinModeDigitalRead) {
                updatedAnalogPin.pinState = state;
            }
            
        }
    }
    
    else if(pinsBundle == bundleA5A4A3A2){
        
        for (int i = 0; i<=3; i++) {
            
            uint8_t state = pinStates;
            uint8_t mask = 1 << i;
            state = state & mask;
            state = state >> i; //isolate the bit representing the pin value and placing it at LSB position
            
            analogPin *updatedAnalogPin = [self.analogPinsArray objectAtIndex:i+2]; //since first bit corresponds to A2
            if (updatedAnalogPin.pinMode == pinModeDigitalRead) {
                updatedAnalogPin.pinState = state;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Communication Outgoing Data

//enable Digital Read and Write mode for all the pins of a given port
- (void) setDigitalReportingForPort: (int) port enabled: (BOOL) state{
    
    uint8_t data0 = 0xD0+port;
    uint8_t data1;
    if (state) {
         data1 = 0x01; // anything different from 0x00 enable digital reporting for the entire port
    }
    else{
        data1 = 0x00;
    }
    uint8_t bytes[2] = {data0, data1};
    NSData *enabledPortMessage = [[NSData alloc] initWithBytes:bytes length:2];
    NSLog(@"enableDigitalReporting was called. it sent %@",enabledPortMessage);
    [self.delegate transferDataFromSubviewToMainMenu: enabledPortMessage];
}

//enable Analog Read mode for a given pin
- (void) setAnalogReportingForPin: (analogPin*) analogPin enabled: (BOOL) state{
    
    int pinIndex = [self.analogPinsArray indexOfObject:analogPin];
    uint8_t data0 = 0xC0 + pinIndex;
    uint8_t data1 = 0x00;
    if (state == YES) {
        data1 = 0x01;
    }
    uint8_t bytes[2] = {data0, data1};
    NSData *enabledAnalogPinMessage = [[NSData alloc] initWithBytes:bytes length:2];
    
    [self.delegate transferDataFromSubviewToMainMenu:enabledAnalogPinMessage];
}

- (void) setPinMode: (PinMode) mode forDigitalPin: (digitalPin *) digitalPin{
    
    int pinIndex = [self.digitalPinsArray indexOfObject:digitalPin]+3; //pin D3 is stored at index 0 in digitalPinsArray
    uint8_t data0 = 0xF4;
    uint8_t data1 = pinIndex;
    uint8_t data2 = mode;
    uint8_t bytes[3] = {data0,data1,data2};
    NSData* newModeForPinMessage = [[NSData alloc] initWithBytes:bytes length:3];
    
    [self.delegate transferDataFromSubviewToMainMenu:newModeForPinMessage];
    [self setPinStateforDigitalPin:digitalPin]; //update to insure the actual pin state on arduino corresponds to the pin state of the app data
}

- (void) setPinMode: (PinMode) mode forAnalogPin: (analogPin *) analogPin{
    
    int pinIndex = [self.analogPinsArray indexOfObject:analogPin]+14; //pin A0 is number 14 on microcontroller
    PinMode previousMode = analogPin.pinMode;
    uint8_t data0 = 0xF4;
    uint8_t data1 = pinIndex;
    uint8_t data2 = mode;
    uint8_t bytes[3] = {data0,data1,data2};
    NSData* newModeForPinMessage = [[NSData alloc] initWithBytes:bytes length:3];
    
    [self.delegate transferDataFromSubviewToMainMenu:newModeForPinMessage];
    
    [self setPinStateforAnalogPin:analogPin]; //update to insure the actual pin state on the arduino corresponds to the pin state of the app data
    
    if (mode == pinModeAnalogRead) { //manage analog value reporting
        [self setAnalogReportingForPin:analogPin enabled:YES];
    }
    else if (previousMode == pinModeAnalogRead){
        [self setAnalogReportingForPin:analogPin enabled:NO];
    }
}

- (void) setPinStateforDigitalPin: (digitalPin *) digitalPin{
    
    int pinIndex = [self.digitalPinsArray indexOfObject:digitalPin]+3; //pin D3 is stored at index 0 in digitalPinsArray
    PinsBundle bundleToUpdate;
    if (pinIndex == 8) { //except for D8 all available digital pins are part of the same bundle
        bundleToUpdate = bundleA1A0D13D12D11D10D9D8;
    }
    else{
        bundleToUpdate = bundleD7D6D5D5D4D3D2D1D0;
    }
    
    NSData* newStatesForBundleMessage = [self genererateBytesForBundule:bundleToUpdate];
    
    [self.delegate transferDataFromSubviewToMainMenu:newStatesForBundleMessage];
}

- (void) setPinStateforAnalogPin: (analogPin *) analogPin{
    NSLog(@"Called setPinStateForAnalogPin");
    int pinIndex = [self.analogPinsArray indexOfObject:analogPin]; //pin A0 is stored at index 0 in analogPinsArray
    PinsBundle bundleToUpdate;
    if (pinIndex < 2) { //A0 and A1 are part of a separate bundle
        bundleToUpdate = bundleA1A0D13D12D11D10D9D8;
    }
    else{
        bundleToUpdate = bundleA5A4A3A2;
    }
    
    NSData* newStatesForBundleMessage = [self genererateBytesForBundule:bundleToUpdate];
    
    [self.delegate transferDataFromSubviewToMainMenu:newStatesForBundleMessage];
}

- (NSData*) genererateBytesForBundule: (PinsBundle) pinsBundle{
    
    uint8_t data0 = 0x00, data1 = 0x00, data2 = 0x00;
    
    if (pinsBundle == bundleD7D6D5D5D4D3D2D1D0) { //digital pin D0 to D7. representing 3 bytes: 0X90 - EMPTY D6 D5 D4 D3 D2 D1 D0 - D7
        NSLog(@"Update bundle d7 to d0");
        data0 = 0x90;
        
        for (int i = 0; i<4; i++) { //fill byte data1 with EMPTY D6 D5 D4 D3 D2 D1 D0. D2 D1 D0 always at 0
            digitalPin *scannedDigitalPin = [self.digitalPinsArray objectAtIndex:i];
            if (scannedDigitalPin.pinState == pinStateHigh) {
                data1 |= (1<<(i+3)); //set bit i+3 to 1 in message as D3 is stored at index 0
            }
        }
        
        data2 = [[self.digitalPinsArray objectAtIndex:4] pinState]; //fill data2 with D7
    }
    
    else if (pinsBundle == bundleA1A0D13D12D11D10D9D8) { //digital pin D8 to D13, A0 to A1. representing 3 bytes: 0x91 - EMPTY A0 D13 D12 D11 D10 D09 D08 - A1
        NSLog(@"Update bundle a1 to d8");
        data0 = 0x91;
        
        //fill by data1 with EMPTY A0 D13 D12 D11 D10 D09 D08. D13 D12 D11 D10 D09 always at 0
        PinState stateOfPinD8 = [[self.digitalPinsArray objectAtIndex:5] pinState];
        if (stateOfPinD8 == pinStateHigh) {
            data1 |= 1;
        }
        
        PinState stateOfPinA0 = [[self.analogPinsArray objectAtIndex:0] pinState];
        if (stateOfPinA0 == pinStateHigh) {
            data1 |= (1<<6);
        }
        
        data2 = [[self.analogPinsArray objectAtIndex:1] pinState]; //fill data2 with A1
    }
    
    else if(pinsBundle == bundleA5A4A3A2) { //analog pin A2 to A5 representing 3 bytes: 0x92 - EMPTY EMPTY EMPT EMPTY A5 A4 A3 A2 - EMPTY
        NSLog(@"Update bundle a5 to a2");
        data0 = 0x92;
        
        for (int i = 2; i<6; i++) {
            analogPin *scannedAnalogPin = [self.analogPinsArray objectAtIndex:i];
            if (scannedAnalogPin.pinState == pinStateHigh) {
                data1 |= (1<<(i-2)); //set bit i-2 to 1 in message as A2 is stored at index 2
            }
        }
        
    }
    NSLog(@"data 1 contains %d", data1);
    uint8_t bytes[3] = {data0,data1,data2};
    NSData* newStatesForBundleMessage = [[NSData alloc] initWithBytes:bytes length:3];
    
    return newStatesForBundleMessage;
    
}

- (void) setPWMValue:(uint8_t) newValue forDigitalPin: (digitalPin*) digitalPin{
    
    int pinIndex = [self.digitalPinsArray indexOfObject:digitalPin]+3; //pin D3 is stored at index 0 in digitalPinsArray
    uint8_t data0 = 0xE0+pinIndex;
    uint8_t data1 = newValue & 0X7F; //first 7 bits of newValue stored in data1. MSB of data1 left at 0
    uint8_t data2 = newValue >> 7; //MSB of newValue put in data2
    uint8_t bytes[3] = {data0,data1,data2};
    NSData* newPWMValueForPinMessage = [[NSData alloc] initWithBytes:bytes length:3];
    
    [self.delegate transferDataFromSubviewToMainMenu:newPWMValueForPinMessage];
}

#pragma mark Debug Function
- (IBAction)debugButtonTapped:(id)sender {
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        digitalPin *readPin = [self.digitalPinsArray objectAtIndex:i];
        NSLog(@"%@: mode %d state %d stepper %d",readPin.pinName,readPin.pinMode,readPin.pinState,readPin.pinStepperValue);
    };
    NSLog(@"                                    ");
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        analogPin *readPin = [self.analogPinsArray objectAtIndex:i];
        NSLog(@"%@: mode %d state %d value %d",readPin.pinName,readPin.pinMode,readPin.pinState,readPin.pinAnalogValue);
    };
    NSLog(@"                                    ");
    NSLog(@"                                    ");
    NSLog(@"                                    ");
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
