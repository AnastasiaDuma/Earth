//
//  EarthAppDelegate.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "EarthIPhoneAppDelegate.h"
#import "EarthViewController.h"

@implementation EarthIPhoneAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
