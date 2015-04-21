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
            cell.pinValueLabel.text = [NSString stringWithFormat:@"%f",analogPinAtIndexPath.pinAnalogValue];
        }
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark Protocol

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

#pragma mark Debug Function
- (IBAction)debugButtonTapped:(id)sender {
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        digitalPin *readPin = [self.digitalPinsArray objectAtIndex:i];
        NSLog(@"%@: mode %d state %d slider %d",readPin.pinName,readPin.pinMode,readPin.pinState,readPin.pinStepperValue);
    };
    NSLog(@"                                    ");
    for (int i = 0; i <NUMBER_OF_DIGITAL_PINS; i++) {
        analogPin *readPin = [self.analogPinsArray objectAtIndex:i];
        NSLog(@"%@: mode %d state %d value %f",readPin.pinName,readPin.pinMode,readPin.pinState,readPin.pinAnalogValue);
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
