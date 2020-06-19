//
//  SphereProvider.h
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

/*
 This class provides the color information for Earth, reading it from a supplied image.
 
 Indeed, this is not only way to provide colors. We could include a ready file with color values into the bundle instead.
 In this case application bundle will take less space, and the application would run somewhat faster.
 */

#import <Foundation/Foundation.h>

typedef struct ColorInfo
{
	unsigned char r; 
	unsigned char g;
	unsigned char b;
} ColorInfo; 

@interface SphereProvider : NSObject 
{

}

+ (SphereProvider*)sharedProvider;
- (void)fillPixelsArray:(ColorInfo*)points dimX:(NSInteger)dimX dimY:(NSInteger)dimY;

@end
