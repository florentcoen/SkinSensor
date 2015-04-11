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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
        if(cell == nil){
            NSLog(@"digital cell in cellForRow for section= 1 could not be reused new one generated from nib");
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"digitalPinTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.delegate = self;
        cell.testLabel.text = [NSString stringWithFormat:@"Digital Pin %d",(int)indexPath.row+3];
        return cell;
        
    }
    else{
        analogPinTableViewCell *cell = (analogPinTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"analogPin"];
        if(cell == nil){
            NSLog(@"analog cell in cellForRow for section= 0 could not be reused new one generated from nib");
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"analogPinTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.delegate = self;
        cell.testLabel.text = [NSString stringWithFormat:@"Analog Pin %d",(int)indexPath.row];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark Protocol

- (void) digitalModeSegmentedButtonWasTapped:(digitalPinTableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"The digital protocol was executed correctly and this button press has been transmitted");
    NSLog(@"the state of the segmented button is %ld for digital cell at section %ld row %ld",(long)cell.modeControlButton.selectedSegmentIndex,(long)indexPath.section,indexPath.row);
}

- (void) analogModeSegmentedButtonWasTapped:(analogPinTableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"The analog protocol was executed correctly and this button press has been transmitted");
    NSLog(@"the state of the segmented button is %ld for analog cell at section %ld row %ld",(long)cell.modeControlButton.selectedSegmentIndex,(long)indexPath.section,indexPath.row);
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
