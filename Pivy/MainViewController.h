//
//  ViewController.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "Background.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "Pivy.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    Reachability *internetReachable;
}

@end