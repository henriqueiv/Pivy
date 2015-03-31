//
//  MapViewController.h
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#define DEBUG 1
#define kLatitudeDeltaNearby 2
#define kLatitudeDeltaWorld 180
#define kLongitudeDeltaNearby 2
#define kLongitudeDeltaWorld 180
#define kViewModeNearby 0
#define kViewModeWorld 1
#import "LocalAnnotation.h"
#import "PivyDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>

@end
