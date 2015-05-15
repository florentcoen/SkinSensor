//
//  subviewControllerDelegate.h
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 15/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol subviewControllerDelegate <NSObject>

- (void)transferDataFromSubviewToMainMenu:(NSData*)newData;

@end
