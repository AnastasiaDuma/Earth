//
//  EarthIPhoneAppDelegate.h
//  EarthIPhone
//
//  Created by Asya on 9.05.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EarthViewController;

@interface EarthIPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EarthViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EarthViewController *viewController;

@end

