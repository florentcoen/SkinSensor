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
        [self enableDigitalReportingForPort:i];
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
    }
    else{
        digitalPinAtIndexPath.pinMode = cell.modeControlButton.selectedSegmentIndex;
    }
    [self.tableView reloadData];
}

- (void) digitalStateSegmentedButtonWasTapped:(digitalPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    digitalPinAtIndexPath.pinState = cell.stateControlButton.selectedSegmentIndex;
    [self.tableView reloadData];
}

- (void) digitalPwmStepperWasTapped:(digitalPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    digitalPin *digitalPinAtIndexPath = [self.digitalPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    digitalPinAtIndexPath.pinStepperValue = cell.pwmStepper.value;
    [self.tableView reloadData];
}

- (void) analogModeSegmentedButtonWasTapped:(analogPinTableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    analogPin *analogPinAtIndexPath = [self.analogPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The analog protocol was executed correctly and this button press has been transmitted");
    analogPinAtIndexPath.pinMode = cell.modeControlButton.selectedSegmentIndex;
    [self.tableView reloadData];
}

- (void) analogStateSegmentedButtonWasTapped:(analogPinTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    analogPin *analogPinAtIndexPath = [self.analogPinsArray objectAtIndex:indexPath.row];
    
    NSLog(@"The analog protocol was executed correctly and this button press has been transmitted");
    analogPinAtIndexPath.pinState = cell.stateControlButton.selectedSegmentIndex;
    [self.tableView reloadData];
}

#pragma mark - Communication Incoming

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

- (void)processInputData:(uint8_t*)data withLength:(int)length{
    
    //Parse data we received
    
    //each message is 3 bytes long
    for (int i = 0; i < length; i+=3){
        
        //Digital Reporting (per port) pins D0 to D15
        //Port 0 pin D0 to D7 in mode digital read
        if (data[i] == 0x90) {
            uint8_t pinStates = data[i+1];
            pinStates |= data[i+2] << 7;    //use LSB of third byte for pin7
            [self updateForPinStates:pinStates port:0];
            return;
        }
        
        //Port 1 pins D8 to D15 in mode digital read => D14 & D15 connected to crystal
        else if (data[i] == 0x91){
            uint8_t pinStates = data[i+1];
            pinStates |= (data[i+2] << 7);  //pins 14 & 15
            [self updateForPinStates:pinStates port:1];
            NSLog(@"got info about port 1");
            return;
        }
        
        //Port 2 pins A0 to A7 in mode digital read
        else if (data[i] == 0x92) {
            uint8_t pinStates = data[i+1];
            [self updateForPinStates:pinStates port:2];
            NSLog(@"got info about port 2");
            return;
        }
        
        //Analog Reporting (per pin) pins A0 to A5 in mode analog read
        else if ((data[i] >= 0xe0) && (data[i] <= 0xe5)){
            
            int pinIndex = data[i] - 0xe0;
            int newAnalogvalue = data[i+1] + (data[i+2]<<7);
            
            if (pinIndex < self.analogPinsArray.count) {
                
                analogPin * updatedAnalogPin= [self.analogPinsArray objectAtIndex:pinIndex];
                
                if(updatedAnalogPin.pinMode == pinModeAnalogRead){
                    
                    updatedAnalogPin.pinAnalogValue = newAnalogvalue;
                }
            }
        }
    }
}

- (void)updateForPinStates:(int)pinStates port:(uint8_t)port{
    
    //Update pin table with new pin values received

    //extract and update digital state of pin D3 to D7
    if (port == 0) {
        
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
    
    //extract and update digital state of pin D8
    else if(port == 1){
        
        uint8_t state = pinStates;
        uint8_t mask = 1;
        state = state & mask;
        //isolate the bit representing the pin value and placing it at LSB position
        
        digitalPin *updatedDigitalPin = [self.digitalPinsArray objectAtIndex:5]; //pin D8 is stored at index 5 in digitalPinArray
        if (updatedDigitalPin.pinMode == pinModeDigitalRead) {
            updatedDigitalPin.pinState = state;
            NSLog(@"updated state for port 1: %d",updatedDigitalPin.pinState);
        }
    }
    
    //extract and update digital state of pin A0 to A5
    else if(port ==2){
        
        for (int i = 0; i<=5; i++) {
            
            uint8_t state = pinStates;
            uint8_t mask = 1 << i;
            state = state & mask;
            state = state >> i; //isolate the bit representing the pin value and placing it at LSB position
            
            analogPin *updatedAnalogPin = [self.analogPinsArray objectAtIndex:i];
            if (updatedAnalogPin.pinMode == pinModeDigitalRead) {
                updatedAnalogPin.pinState = state;
                NSLog(@"update state for port 2");
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Communication Outgoing
/*
- (void)enableDigitalReportingForDigitalPin: (digitalPin *) targetedDigitalPin enabled:(BOOL)enabled{
    
    //Enable digital read mode for a digital pin
    
    uint8_t port;
    uint8_t pin;
    
    NSInteger indexOfTargetedDigitalPin = [self.digitalPinsArray indexOfObject:targetedDigitalPin];
    
    if (indexOfTargetedDigitalPin <= 4) { //port 0, pin D3 to D7
        port = 0;
        pin = indexOfTargetedDigitalPin + 3; //pin D3 is stored at index 0 in digitalPinsArray
    }
    
    else if (indexOfTargetedDigitalPin == 5){
        port = 1;
        pin = indexOfTargetedDigitalPin + 3;
    }
    
    if (enabled) {
        targetedDigitalPin.pinMode = pinModeDigitalRead;
    }
    else
    uint8_t data0 = 0xd0 + port;
    uint8_t data1 = [self genererateByteForMode:pinModeDigitalRead forPort:port];
    
}*/

- (void) enableDigitalReportingForPort: (int) port{
    
    uint8_t data0 = 0xD0+port;
    uint8_t data1 = 0x01; //0x000: disable digital reporting for an entire port, anything >0x00 enable digital reporting for an entire port
    uint8_t bytes[2] = {data0, data1};
    NSData *enabledPins = [[NSData alloc] initWithBytes:bytes length:2];
    NSLog(@"enableDigitalReporting was called. it sent %@",enabledPins);
    [self.delegate transferDataFromSubviewToMainMenu: enabledPins];
    
    if (port == 2) {
        for (int i = 0; i<=5; i++) {
            data0 = 0xc0 + i;
            data1 = 0x01;
            bytes[0] = data0;
            bytes[1] = data1;
            NSData *enabledAnalogPins = [[NSData alloc] initWithBytes:bytes length:2];
            [self.delegate transferDataFromSubviewToMainMenu:enabledAnalogPins];
        }
    }
}

- (uint8_t) genererateByteForMode: (PinMode) desiredMode forPort: (uint8_t) port{
    
    uint8_t modeByte = 0x00;
    
    if (port == 0) { //digital pin D0 to D7. representing byte: D7 D6 D5 D4 D3 D2 D1 D0
        
        for (int i = 0; i<=4; i++) {
            digitalPin *scannedDigitalPin = [self.digitalPinsArray objectAtIndex:i];
            if (scannedDigitalPin.pinMode == desiredMode) {
                modeByte |= (1<<(i+3)); //set bit i+3 to 1 as D3 is stored at index 0
            }
        }
    }
    
    else if (port == 1) { //digital pin D8 to D15 representing byte: D15 D14 D13 D12 D11 D10 D09 D08
        
        digitalPin *scannedDigitalPin = [self.digitalPinsArray objectAtIndex:5];
        if (scannedDigitalPin.pinMode == desiredMode) {
            modeByte |= 1; //set bit 0 to 1 as D8 is stored at index 5
        }
    }
    
    else if(port ==2) { //analog pin A0 to A5 representing byte: 0 0 A5 A4 A3 A2 A1 A0
        
        for (int i = 0; i<=5; i++) {
            analogPin *scannedAnalogPin = [self.analogPinsArray objectAtIndex:i];
            if (scannedAnalogPin.pinMode == desiredMode) {
                modeByte |= (1<<i);
            }
        }
        
    }
    
    return modeByte;
    
}

#pragma mark Debug Function
- (IBAction)debugButtonTapped:(id)sender {
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        digitalPin *readPin = [self.digitalPinsArray objectAtIndex:i];
        NSLog(@"%@: mode %d state %d slider %d",readPin.pinName,readPin.pinMode,readPin.pinState,readPin.pinStepperValue);
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
