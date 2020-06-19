//
//  EarthView.m
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import "EarthView.h"

@interface EarthView (Private)

- (void)cacheSpherePoints;
- (void)setBitmapDataAndContext;

@end

#define PROFILE_DRAWING

NSString* const TouchMovedNotification = @"TouchMovedNotification";
NSString* const TouchEndedNotification = @"TouchEndedNotification";
NSString* const TouchBeganNotification = @"TouchBeganNotification";

@implementation EarthView

@synthesize sphere = _sphere;

#pragma mark -
#pragma mark view parameters


- (NSInteger) dW
{
	return ([self bounds].size.width - _D) / 2;
}

- (NSInteger) dH
{
	return ([self bounds].size.height - _D) / 2;
}


#pragma mark -
#pragma mark init

- (id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self)
	{
		_sphere = [[Sphere alloc] init];
		
		_R = fminf([self bounds].size.height, [self bounds].size.width) / 2;
		//if (_R >= 384) // make spaces for iPad
		{
			_R = _R - 10;//344;
		}
		
		_D = 2 * _R;
		
		_cachedSpherePoints = (PointOnSphere**)malloc(_D * sizeof (PointOnSphere*));
		for (int i = 0; i < _D; i++) 
			_cachedSpherePoints[i] = (PointOnSphere*)malloc(_D * sizeof(PointOnSphere));
		
		[self cacheSpherePoints];
				
		// create create a bitmap data and bitmap context
		[self setBitmapDataAndContext];
	}
	return self;
}


#pragma mark -
#pragma mark used when init

- (void)convertX:(CGFloat)x Y:(CGFloat)y toLongitude:(CGFloat*)lo Latitude:(CGFloat*)la success:(BOOL*)cachedResult
{
	float x_3d = x - _D / 2; 
	float z_3d = -(y - _D / 2);
	float d = _R*_R - x_3d * x_3d - z_3d * z_3d;
	if (d < 0)
	{
		*lo = -1.0;
		*la = -1.0;
		*cachedResult = NO;
	}
	else
	{
		float y_3d = sqrt(d); 
		*la = acos(z_3d / _R);
		*lo = atan2( x_3d, y_3d );
		*cachedResult = YES;	
	}
}

- (void)cacheSpherePoints // caching the geometric calculations in order to accelerate the inner drawing loop
{
	for (int x = 0; x < _D; x++) // longitude
		for (int y = 0; y < _D; y++) // latitude
		{ 
			CGFloat lo;
			CGFloat la;
			BOOL cachedResult;
			[self convertX:x Y:y toLongitude:&lo Latitude:&la success:&cachedResult];
			
			PointOnSphere spherePoint;
			spherePoint.lo = lo;
			spherePoint.la = la;
			spherePoint.isWithin = cachedResult;
			
			_cachedSpherePoints[x][y] = spherePoint;
		}
}

- (void)setBitmapDataAndContext
{
	int bitmapByteCount;
	int bitmapBytesPerRow;
	
	size_t pixelsWide = _D;
	size_t pixelsHigh = _D;
	
	bitmapBytesPerRow = (pixelsWide * 4);
	bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
	
	_bitmapData = malloc( bitmapByteCount );
	
	CGColorSpaceRef colorSpace;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	_bitmapContext = CGBitmapContextCreate(_bitmapData, 
													pixelsWide,
													pixelsHigh,
													8, //bits per component
													bitmapBytesPerRow,
													colorSpace,
													kCGImageAlphaPremultipliedFirst);
	
	CGColorSpaceRelease(colorSpace);
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc 
{
	[_sphere release];
	
	for (int i = 0; i < _D; i++) 
		free(_cachedSpherePoints[i]);
	free(_cachedSpherePoints);
	
	
	//_moveStartTime releases when touchesEnded:

	free(_bitmapData);
	CGContextRelease(_bitmapContext);
	
    [super dealloc];
}


#pragma mark -
#pragma mark drawing

- (CGImageRef)createBitmapContextImage
{
	for (int y = _D - 1; y >= 0; y--) 
	{
		int invertedY = _D - 1 - y; // we need inverted Y for drawing, because CGImage's coorinates are upside down
		for (int x = _D - 1; x >= 0; x--) 
		{
			if (_cachedSpherePoints[x][y].isWithin)
			{ 
				CGFloat lo = _cachedSpherePoints[x][y].lo;
				CGFloat la = _cachedSpherePoints[x][y].la;
				
				ColorInfo tmpColor = [self.sphere colorOfPointWithLongitude:(lo + self.sphere.rotationAngle) latitude:la];
				
				int offset = 4 * ((_D * invertedY) + x);
				_bitmapData[offset] = 1.0;
				_bitmapData[offset+1] = tmpColor.r;
				_bitmapData[offset+2] = tmpColor.g;
				_bitmapData[offset+3] = tmpColor.b;

			}
			else // black color
			{
				int offset = 4 * ((_D * invertedY) + x);
				_bitmapData[offset] = 1;
				_bitmapData[offset+1] = 1;
				_bitmapData[offset+2] = 1;
				_bitmapData[offset+3] = 1;
				
			}
		}
	}
	
	CGImageRef newImage = CGBitmapContextCreateImage(_bitmapContext);
	
	return newImage;
}

- (void)drawRect:(CGRect)rect
{
#ifdef PROFILE_DRAWING
	NSDate* db = [NSDate date];
#endif
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGImageRef newImage = [self createBitmapContextImage];
	
	CGRect imageRect = {{[self dW], [self dH]}, {_D, _D}};
	CGContextDrawImage(context, imageRect, newImage);
	
	CGImageRelease(newImage);
	
#ifdef PROFILE_DRAWING
	NSDate* de = [NSDate date];
	NSLog(@"drawing time: %f", [de timeIntervalSinceDate:db]);
#endif
}


#pragma mark -
#pragma mark touches

/* 
 Normalizing the Y-coordinate in order to counter too fast movement
 when touching at the pole. For now, just shift the point to Earth's equator
 */
- (NSInteger)normalizeY:(CGFloat)float_y
{	
	return _R;
}

/*
 Detect if a screen point is outside our Earth image
 */
- (BOOL)isScreenPointOnEarth:(CGPoint)point
{
	int x0 = [self dW] + _R; // x-coordinate of center
	int y0 = [self dH] + _R; // y-coordinate of center
	if ( (point.x-x0) * (point.x-x0) + (point.y-y0) * (point.y-y0) < _R * _R )
		return YES;
	else
		return NO;
}

/*
 On the first touch stop Earth's rotation, initiated by previous touches
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint pointInView = [[touches anyObject] locationInView:self];
	if ([self isScreenPointOnEarth:pointInView])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:TouchBeganNotification object:self];
	}
}

- (CGFloat)getLongitudeForScreenPointInEarth:(CGPoint)point
{
	int x = (int)point.x - [self dW];
    int y = point.y - [self dH];
    y = [self normalizeY:y];
	
    // the point is guaranteed to be in view, therefore the array indices are acceptable
	CGFloat lo = _cachedSpherePoints[x][y].lo;
	return lo;
}

/*
 Calculate the initial speed of inertial movement and send it to observer (in our case ViewController)
 The end point must be in the Earth.
 */
- (void)startAccelerationWithEndPoint:(CGPoint)endPoint
{
	CGFloat lo_end = [self getLongitudeForScreenPointInEarth:endPoint];
	
	NSDate* moveEndTime = [NSDate date];
	NSTimeInterval dTime = [moveEndTime timeIntervalSinceDate:_moveStartTime];
	CGFloat dAngle = _moveStartLo - lo_end;
	CGFloat speed = dAngle / dTime;
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:speed] forKey:@"speed"];
	[[NSNotificationCenter defaultCenter] postNotificationName:TouchEndedNotification object:self userInfo:userInfo];
	
	[_moveStartTime release];
	_moveStartTime = nil;		
}

/*
 Simple rotation (one move-touch = one rotation angle change)
 or rotation with acceleration (decreasing speed) if pan-gesture went out of Earth
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint pointInView = [[touches anyObject] locationInView:self];
	CGPoint prevPointInView = [[touches anyObject] previousLocationInView:self];
	
	if ([self isScreenPointOnEarth:pointInView] && [self isScreenPointOnEarth:prevPointInView])
	{		
		CGFloat lo_new = [self getLongitudeForScreenPointInEarth:pointInView];		
		
		if (!_moveStartTime)
		{
			_moveStartTime = [[NSDate date] retain];
			_moveStartLo = lo_new;
		}
		
		CGPoint prevPointInView = [[touches anyObject] previousLocationInView:self];
		
		CGFloat lo_old = [self getLongitudeForScreenPointInEarth:prevPointInView];
		
		CGFloat delta_angle = lo_old - lo_new;
		
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delta_angle] forKey:@"delta_angle"];
		[[NSNotificationCenter defaultCenter] postNotificationName:TouchMovedNotification object:self userInfo:userInfo];
	}
	else 
	{
		if (_moveStartTime != nil)
		{
			CGPoint lastPointInView = [[touches anyObject] previousLocationInView:self];

			[self startAccelerationWithEndPoint:lastPointInView];
		}
		return;		
	}
}

/*
 Initiates the inertial movement if current or previous touch location lies inside Earth
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{		
	if (_moveStartTime != nil)
	{
		CGPoint pointInView = [[touches anyObject] locationInView:self];
				
		if ([self isScreenPointOnEarth:pointInView])
		{
			[self startAccelerationWithEndPoint:pointInView];	
		}
		else
		{
			CGPoint prevPointInView = [[touches anyObject] previousLocationInView:self];
			
			if ([self isScreenPointOnEarth:prevPointInView])
			{
				[self startAccelerationWithEndPoint:prevPointInView];
			}
			else
			{
				[_moveStartTime release];
				_moveStartTime = nil;	
				return;
			}			
		}	
	}
}

#pragma mark -
#pragma mark message from Controller

- (void)addRotationAngle:(NSNumber*)dAngle
{
	self.sphere.rotationAngle += [dAngle floatValue];
}

@end
