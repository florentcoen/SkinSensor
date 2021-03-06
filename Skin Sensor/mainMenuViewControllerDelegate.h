//
//  mainMenuViewControllerDelegate.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 15/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol mainMenuViewControllerDelegate <NSObject>

- (void) transferDataFromMainMenuToSubcontroller:(NSData*)newData;

@end
