//
//  EarthPosition.h
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

/*
 This is the model class that imitates the inertial movement of Earth.
 It takes initial speed from outside, and reports the changes in Earth position through an event.
 Internally, it starts a timer. In each call of timer function it decelerates the speed
 (towards zero) and sends a new rotation angle to the controller.
 */

#import <Foundation/Foundation.h>
#import "CoreGraphics/CoreGraphics.h"

@interface EarthAccelerator : NSObject 
{
	@private
	CGFloat _angle;   // angle defining the position of sphere
	CGFloat _speed; // speed of rotation in each moment
	CGFloat _acceleration; // initial acceleration
	NSTimer* _iTimer;	
}

@property (nonatomic, assign, readonly)	CGFloat	angle;

- (void)setSpeed:(CGFloat)newSpeed;

extern NSString* const AcceleratorDidChangeAngleNotification;
@end
