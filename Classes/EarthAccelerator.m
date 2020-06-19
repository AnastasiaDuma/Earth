//
//  EarthPosition.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "EarthAccelerator.h"

#define TIME_INTERVAL 0.1
#define ACCELERATION_MAGNITUDE 30

@interface EarthAccelerator ()

@property (nonatomic,retain) NSTimer* iTimer; 
@property (nonatomic, assign, readwrite) CGFloat angle;

@end

NSString* const AcceleratorDidChangeAngleNotification = @"AcceleratorDidChangeAngleNotification";

@implementation EarthAccelerator

@synthesize angle = _angle;
@synthesize iTimer = _iTimer;


#pragma mark -
#pragma mark Alloc/dealloc and setters

- (id)init
{
	self = [super init];
	if (self)
	{
		self.angle = 0;
		_speed = 0;
		_acceleration = 0;
	}
	return self;
}

- (void)dealloc
{
	[_iTimer release];
	[super dealloc];
}


#pragma mark -
#pragma mark Auxiliary Functions 

- (NSInteger)floatSign:(CGFloat)value
{
	return (value > 0 ? 1 : -1);
}


#pragma mark -
#pragma mark Postion Management

/*
 Sets new speed and acceleration values and starts timer. On timer ticks the rotation will
 be slowed down.
 */
- (void)setSpeed:(CGFloat)newSpeed
{
	_speed = newSpeed;
 
	if ([self.iTimer isValid])
	{
		[self.iTimer invalidate];
		self.iTimer = nil;
	}
	if (_speed == 0.0) // we may compare to 0, because it can be represented exactly as float
	{
	    _acceleration = 0.0;
	}
	else
	{
	
	_acceleration = (-1)*[self floatSign:_speed]*ACCELERATION_MAGNITUDE;
	
	NSTimer* timer = [NSTimer timerWithTimeInterval:(NSTimeInterval)TIME_INTERVAL 
											 target:self selector:@selector(modifyPosition:) 
										   userInfo:nil 
											repeats:YES];
	self.iTimer = timer;
	
	[[NSRunLoop currentRunLoop] addTimer:self.iTimer forMode:NSDefaultRunLoopMode]; // start timer, run loop retains the timer
	}
}


- (void)modifyPosition:(NSTimer*)timer
{
	self.angle = _speed * TIME_INTERVAL;
	
	NSNumber* newAngle = [NSNumber numberWithFloat:self.angle];
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:newAngle forKey:@"delta_angle"];
	[[NSNotificationCenter defaultCenter] postNotificationName:AcceleratorDidChangeAngleNotification object:self userInfo:userInfo];
	
	_speed += _acceleration * TIME_INTERVAL;

	// check if we reached zero speed 
	if ([self floatSign:_speed] == [self floatSign:_acceleration])
	{
		// stop moving
		_speed = 0; 
		_acceleration = 0;
		// stop timer
		[timer invalidate]; // the run loop removes and releases the timer
		self.iTimer = nil;
	}
}

@end
