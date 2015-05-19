//
//  SkinSensorDataViewController.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 15/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainMenuViewControllerDelegate.h"
#import "subviewControllerDelegate.h"
#import "skinSensorValues.h"
#import <MessageUI/MessageUI.h>
#import "CorePlot-CocoaTouch.h"

@interface SkinSensorViewController : UIViewController<mainMenuViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id<subviewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *skinSensorHistory;
@property (strong, nonatomic) skinSensorValues *currentSkinSensorValues;

@property (strong, nonatomic) IBOutlet UILabel *bodyTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *thermistorA0TemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *thermistorA1TemperatureLabel;

@property (strong, nonatomic) IBOutlet UILabel *sensorF0HumidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *sensorF0TemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *sensorF1HumidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *sensorF1TemperatureLabel;

@property (strong, nonatomic) IBOutlet UILabel *thermistorA0MessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *thermistorA1MessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *sensorF0MessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *sensorF1MessageLabel;

@end