//
//  Sphere.h
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

/*
 This is a part of view. Stores the color of Earth location indexed by longitude and latitide.
 */

#import <Foundation/Foundation.h>
#import "SphereProvider.h"

#define LATITUDE_RESOLUTION 1000
#define LONGITUDE_RESOLUTION 1363

@interface Sphere : NSObject
{
	CGFloat _rotationAngle;
@private
	ColorInfo _points[LONGITUDE_RESOLUTION][LATITUDE_RESOLUTION];
}

- (ColorInfo)colorOfPointWithLongitude:(CGFloat)lo latitude:(CGFloat)la;

@property (nonatomic, assign) CGFloat rotationAngle;

@end
