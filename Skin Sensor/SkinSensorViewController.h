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

@interface SkinSensorViewController : UIViewController<mainMenuViewControllerDelegate,MFMailComposeViewControllerDelegate,CPTPlotDataSource,UITextFieldDelegate>

@property (strong, nonatomic) id<subviewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *skinSensorHistory;
@property (strong, nonatomic) skinSensorValues *currentSkinSensorValues;
@property (nonatomic) double ambiantTemperature;
@property (nonatomic) int timerPeriod;
@property (strong, nonatomic) UITextField *activeField;
@property (nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostViewTemperature;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostViewHumidity;

@property (strong, nonatomic) IBOutlet UITextField *timerPeriodTextField;
@property (strong, nonatomic) IBOutlet UITextField *ambiantTemperatureTextField;

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