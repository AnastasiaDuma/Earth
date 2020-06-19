//
//  EarthViewController.h
//  Earth
//
//  Created by Asya on 25.04.2011.
//  Copyright 2011 A.Miropolskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EarthView.h"
#import "EarthAccelerator.h"

@interface EarthViewController : UIViewController
{
	EarthView* _earthView;
	EarthAccelerator* _accelerator;
}

@property (nonatomic, assign) EarthView* earthView;

@end

