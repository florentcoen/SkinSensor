//
//  SkinSensorDataViewController.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 15/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "SkinSensorViewController.h"

const double ARDUINO_AD_RESOLUTION = 1024;

const double P1 = 0.0023932036;
const double P2 = -0.1146469555;
const double P3 = 2.090311091;
const double P4 = -19.60117928;
const double P5 = 102.9477066;

const double VS = 4.967;

const double RREF = 10;

const double RBIAS_A0 = 0;
const double RBIAS_A1 = 0.03;

@implementation SkinSensorViewController


- (void) transferDataFromMainMenuToSubcontroller:(NSData *)newData{
    NSLog(@"RECEIVED DATA");
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    
    NSUInteger          dataLength  = newData.length;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 4)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
    NSLog(@"%@",[NSString stringWithString:hexString]);
    
    [self processLastBLEMessage:newData];
    [self updateUIForCurrentValues];
    [self updateLastBleMessageInterface:newData];
}

- (void) viewDidLoad{
    
    [super viewDidLoad];
    self.currentSkinSensorValues = [[skinSensorValues alloc] init];
    self.skinSensorHistory = [[NSMutableArray alloc] init];
    
}


- (void) processLastBLEMessage: (NSData *) newData{
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    uint16_t pinA0Value = [self make16BitsUnsignedFromByte:dataBuffer[1] and:dataBuffer[2]];
    uint16_t pinA1Value = [self make16BitsUnsignedFromByte:dataBuffer[4] and:dataBuffer[5]];
    [self computeResistorValuesForPinA0: pinA0Value andPinA1:pinA1Value];
    
    uint16_t sensorF0HumidityData = [self make16BitsUnsignedFromByte:dataBuffer[7] and:dataBuffer[8]];
    uint16_t sensorF0TemperatureData = [self make16BitsUnsignedFromByte:dataBuffer[9] and:dataBuffer[10]];
    self.currentSkinSensorValues.sensorF0Humdity = [self computeHumidityValueOfHDC1000From:sensorF0HumidityData];
    self.currentSkinSensorValues.sensorF0Temperature = [self computeTemperatureValueOfHDC1000From:sensorF0TemperatureData];
    
    uint16_t sensorF1HumidityData = [self make16BitsUnsignedFromByte:dataBuffer[12] and:dataBuffer[13]];
    uint16_t sensorF1TemperatureData = [self make16BitsUnsignedFromByte:dataBuffer[14] and:dataBuffer[15]];
    self.currentSkinSensorValues.sensorF1Humidity = [self computeHumidityValueOfHDC1000From:sensorF1HumidityData];
    self.currentSkinSensorValues.sensorF1Temperature = [self computeTemperatureValueOfHDC1000From:sensorF1TemperatureData];
    
    NSString *date = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterMediumStyle];
    self.currentSkinSensorValues.timeStamp = date;
    
    skinSensorValues *newSkinSensorValues = [[skinSensorValues alloc] init];
    newSkinSensorValues = self.currentSkinSensorValues;
    [self.skinSensorHistory addObject:newSkinSensorValues];
    
    NSLog(@"SIZE OF HISTORY %d",[self.skinSensorHistory count]);
}

- (uint16_t) make16BitsUnsignedFromByte: (uint8_t) higherByte and: (uint8_t) lowerByte{
    uint16_t valueOn16Bits = lowerByte;
    valueOn16Bits = higherByte;
    valueOn16Bits = (valueOn16Bits << 8) | lowerByte;
    return valueOn16Bits;
    
}

- (void) computeResistorValuesForPinA0: (uint16_t) pinA0Value andPinA1: (uint16_t) pinA1Value{
    
    double voltageA0 = (double) pinA0Value / ARDUINO_AD_RESOLUTION * VS;
    double voltageA1 = (double) pinA1Value / ARDUINO_AD_RESOLUTION * VS;
    NSLog(@"voltage a0 %lf voltage a1 %lf",voltageA0,voltageA1);
    double resistorA0 = RREF *(VS/voltageA0 -1) + RBIAS_A0;
    double resistorA1 = RREF *(VS/voltageA1 -1) + RBIAS_A1;
    NSLog(@"resistor a0 %lf resistors a1 %lf",resistorA0,resistorA1);
    [self applyHeatFlowModelFromResistorA0:resistorA0 andResistorA1:resistorA1];
    
}

- (void) applyHeatFlowModelFromResistorA0: (double) resistorA0 andResistorA1: (double) resistorA1 {
    self.currentSkinSensorValues.thermistorA0Temperature = (P1*pow(resistorA0, 4) + P2*pow(resistorA0, 3) + P3*pow(resistorA0, 2) + P4*resistorA0 + P5) / 20;
    self.currentSkinSensorValues.thermistorA1Temperature = (P1*pow(resistorA1, 4) + P2*pow(resistorA1, 3) + P3*pow(resistorA1, 2) + P4*resistorA1 + P5) / 20;
    NSLog(@"temperature a0 %lf",self.currentSkinSensorValues.thermistorA0Temperature);
    NSLog(@"temperature a1 %lf",self.currentSkinSensorValues.thermistorA1Temperature);
    self.currentSkinSensorValues.bodyTemperature = 0;
}

- (double) computeTemperatureValueOfHDC1000From: (uint16_t) temperatureData{
    
    return (double) temperatureData / (double) 65536 + 165 -40;
}

- (double) computeHumidityValueOfHDC1000From: (uint16_t) humidityData{
    
    return (double) humidityData / (double) 65536 * (double) 100;
}

- (void) updateUIForCurrentValues{
    
    self.bodyTemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.bodyTemperature];
    self.thermistorA0TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.thermistorA0Temperature];
    self.thermistorA1TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.thermistorA1Temperature];
    
    self.sensorF0TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.sensorF0Temperature];
    self.sensorF0HumidityLabel.text = [NSString stringWithFormat:@"%.02f %%",self.currentSkinSensorValues.sensorF0Humdity];
    self.sensorF1TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.sensorF1Temperature];
    self.sensorF1HumidityLabel.text = [NSString stringWithFormat:@"%.02f %%",self.currentSkinSensorValues.sensorF1Humidity ];
}
- (void) updateLastBleMessageInterface: (NSData*) newData{
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    NSUInteger          dataLength  = newData.length;
    
    if (dataLength == 16) {
        NSMutableString     *hexStringThermistorA0 = [[NSMutableString alloc] init];
        for (int i = 0; i < 3; i++) {
            [hexStringThermistorA0 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.thermistorA0MessageLabel.text = [NSString stringWithString:hexStringThermistorA0];
        
        NSMutableString     *hexStringThermistorA1 = [[NSMutableString alloc] init];
        for (int i = 3; i < 6; i++) {
            [hexStringThermistorA1 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.thermistorA1MessageLabel.text = hexStringThermistorA1;
        
        NSMutableString     *hexStringSensorF0 = [[NSMutableString alloc] init];
        for (int i = 6; i < 11; i++) {
            [hexStringSensorF0 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.sensorF0MessageLabel.text = hexStringSensorF0;
        
        NSMutableString     *hexStringSensorF1 = [[NSMutableString alloc] init];
        for (int i = 11; i < 16; i++) {
            [hexStringSensorF1 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.sensorF1MessageLabel.text = hexStringSensorF1;
    }
}

- (IBAction)pressedMailButton:(id)sender {
    NSLog(@"Mail button pressed");
    NSMutableString *sensorData = [[NSMutableString alloc] init];
    [sensorData appendString:@"Timestamp, Body Temperature, Thermistor A0, Thermistor A1, HDC1000-F0 Humidity, HDC1000-F0 Temperature, HDC1000-F1 Humidity, HDC1000-F1 Temperature\n"];
    for (int i=0; i < self.skinSensorHistory.count; i++) {
        skinSensorValues *scannedValues = [self.skinSensorHistory objectAtIndex:i];
        [sensorData appendFormat:@"%@,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f\n",scannedValues.timeStamp,scannedValues.bodyTemperature,scannedValues.thermistorA0Temperature,scannedValues.thermistorA1Temperature,scannedValues.sensorF0Humdity,scannedValues.sensorF0Temperature,scannedValues.sensorF1Humidity,scannedValues.sensorF1Temperature];
    }
    
    MFMailComposeViewController *mFMCVC = [[MFMailComposeViewController alloc]init];
    if (mFMCVC) {
        if ([MFMailComposeViewController canSendMail]) {
            mFMCVC.mailComposeDelegate = self;
            [mFMCVC setSubject:@"Data from Skin Sensor"];
            [mFMCVC setMessageBody:@"Data from Skin Sensor 1.0" isHTML:NO];
            [self presentViewController:mFMCVC animated:YES completion:nil];
            
            [mFMCVC addAttachmentData:[sensorData dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"Skin_Sensor_Log.csv"];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mail error" message:@"Device has not been set up to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
