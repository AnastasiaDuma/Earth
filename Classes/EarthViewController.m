//
//  EarthViewController.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "EarthViewController.h"

@implementation EarthViewController

@synthesize earthView = _earthView;

- (void)loadView 
{
    EarthView *view = [[EarthView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	self.view = view;
	self.earthView = view;
	
    [view release];
	
	_accelerator = [[EarthAccelerator alloc] init];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateEarth:) name:TouchMovedNotification object:self.view];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateEarth:) name:TouchEndedNotification object:self.view];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopEarth:) name:TouchBeganNotification object:self.view];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inertialRotationDidEnd:) name:AcceleratorDidChangeAngleNotification object:_accelerator];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return YES;
//}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_accelerator release];
    [super dealloc];
}


- (void)rotateEarth:(NSNotification*)notification
{
	if ([[notification name] isEqualToString:TouchMovedNotification])
	{
		NSNumber* angle = [[notification userInfo] valueForKey:@"delta_angle"];
		[self.earthView addRotationAngle:angle];
		
		[self.view setNeedsDisplay];
	}
	else if ([[notification name] isEqualToString:TouchEndedNotification])
	{
		NSNumber* speed = [[notification userInfo] valueForKey:@"speed"];
		
		[_accelerator setSpeed:[speed floatValue]];
	}
}

- (void)stopEarth:(NSNotification*)notification
{
	[_accelerator setSpeed:0];
}

- (void)inertialRotationDidEnd:(NSNotification*)notification
{
	NSNumber* dAngle = [[notification userInfo] valueForKey:@"delta_angle"];
	[self.earthView addRotationAngle:dAngle];
	[self.view setNeedsDisplay];
}

@end
