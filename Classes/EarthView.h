//
//  EarthView.h
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

/*
View class, that draws Earth and manages touches.
*/

#import <Foundation/Foundation.h>
#import "Sphere.h"

typedef struct PointOnSphere
{
	CGFloat lo;
	CGFloat la;
	BOOL isWithin;
} PointOnSphere;

@interface EarthView : UIView
{
@private
	Sphere* _sphere;

	PointOnSphere** _cachedSpherePoints;
	
	NSDate* _moveStartTime;
	CGFloat _moveStartLo;
	
	CGContextRef _bitmapContext;
	unsigned char * _bitmapData;
	
	NSInteger _R;
	NSInteger _D;
}

@property (nonatomic,retain) Sphere* sphere;

- (void)addRotationAngle:(NSNumber*)dAngle;

extern NSString* const TouchMovedNotification;
extern NSString* const TouchEndedNotification;
extern NSString* const TouchBeganNotification;

@end
