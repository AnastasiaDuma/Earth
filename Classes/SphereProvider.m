//
//  SphereProvider.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "SphereProvider.h"

@implementation SphereProvider

# pragma mark -
# pragma mark Singleton implementation

static SphereProvider* _sharedProvider = nil;

+ (SphereProvider*)sharedProvider
{
	@synchronized(self)
	{
		if (_sharedProvider == nil)
			[[self alloc] init];
		
		return _sharedProvider;
	}
	
	return nil;
}

+ (id)allocWithZone:(NSZone*)zone
{
	@synchronized(self)
	{
		NSAssert(_sharedProvider == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedProvider = [super allocWithZone:zone];
		return _sharedProvider;
	}
	
	return _sharedProvider;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;
}

- (void)release
{

}

- (id)autorelease
{
	return self;
}

# pragma mark -
# pragma mark Functionality implementation

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage
{	
	CGContextRef context = nil;
	CGColorSpaceRef colorSpace;
	void * bitmapData;
	int bitmapByteCount;
	int bitmapBytesPerRow;
	
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// 4 bytes per point: 8 bits to alpha, 8 bits to Red, 8 bits to Green, 8 bits to Blue
	bitmapBytesPerRow = (pixelsWide * 4);
	bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	bitmapData = malloc(bitmapByteCount);
	
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8, // bit per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == nil)
	{
		free (bitmapData);
	}
	
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

- (void)fillPixelsArray:(ColorInfo*)points dimX:(NSInteger)dimX dimY:(NSInteger)dimY
{	
	UIImage* image = [UIImage imageNamed:@"Miller-projection1000.jpg"];
	
	CGImageRef cgImage = image.CGImage;
	
	CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
	
	if (context == nil)
	{ 
		return;
	}
	
	size_t w = CGImageGetWidth(cgImage);
	size_t h = CGImageGetHeight(cgImage);
	CGRect rect = {{0,0},{w,h}};
	
	CGContextDrawImage(context, rect, cgImage);
	
	// fills here
	unsigned char* data = CGBitmapContextGetData (context);
	
	if (data == nil)
		return;
	
	/*
	 // since the map is encoded as Miller cylindrical projection, 
	 // we need to remap the value of y, using the formula (2) 
	 // from http://mathworld.wolfram.com/MillerCylindricalProjection.html
	 */
	
	float ymin = log(tan(M_PI/20));
	float ymax = log(tan(9*M_PI/20));
	float yrange = ymax - ymin;
	for (int x = 0; x < dimX; x++)
		for (int y = 0; y < dimY; y++)
		{
			float phi = ((float)y/dimY)*M_PI - M_PI/2; // [-PI/2; PI/2)
			int y1 = (log(tan(M_PI/4 + 2*phi/5)) - ymin) / yrange * dimY; // [0..dimY)
			int offset = 4 * ((w * y1) + x);
			// int alpha = data[offset]; // commented to avoid warning
			int red = data[offset + 1];
			int green = data[offset + 2];
			int blue = data[offset + 3];
			
			ColorInfo newColor;
			newColor.r = red;
			newColor.g = green;
			newColor.b = blue;
			
			points[x * dimY + y] = newColor;		
		}
	
	CGContextRelease(context);
	
	free(data);
}

@end
