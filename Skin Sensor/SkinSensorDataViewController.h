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

@interface SkinSensorDataViewController : UIViewController<mainMenuViewControllerDelegate>

@property (strong, nonatomic) id<subviewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *testButton;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@end
