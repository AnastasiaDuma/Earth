//
//  Sphere.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "Sphere.h"

@implementation Sphere

@synthesize rotationAngle = _rotationAngle;

- (id)init
{
	self = [super init];
	if (self)
	{
		[[SphereProvider sharedProvider] fillPixelsArray:&_points[0][0] dimX:LONGITUDE_RESOLUTION dimY:LATITUDE_RESOLUTION];
	}
	
	self.rotationAngle = 0.0;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

/*
 The default behavior of fmodf is not suitable, as it returns negative result for
 negaitive numerator. We need always positive result, as in Gaussian mod.
Eg. 
 fmodf(-8, 5) returns -3
 gaussian_fmod(-8, 5) returns 2
*/
CGFloat gaussian_fmod(CGFloat x, CGFloat y) 
{
	if (y == 0)
		return x;
	else 
		return x - y * floor(x/y);
}

- (ColorInfo)colorOfPointWithLongitude:(CGFloat)lo latitude:(CGFloat)la
{
	/* 
	 Need to reduce la:[0;pi], lo:[0; 2*pi].
	 Use own fmod-function because of incorrect behavior of fmodf (from math.h) with negative x-parameter.
	 */
	CGFloat red_lo = gaussian_fmod(lo, 2*M_PI);
	CGFloat red_la = gaussian_fmod(la, M_PI);
	
	int i = LONGITUDE_RESOLUTION/(2*M_PI)*red_lo;
	int j = LATITUDE_RESOLUTION/M_PI*red_la;
	
	ColorInfo color = _points[i][j];
	
	return color;
}

@end
