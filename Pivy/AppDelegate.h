//
//  AppDelegate.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//


#import "Banner.h"
#import "Gallery.h"
#import "GalleryDataManager.h"
#import "MBProgressHUD.h"
#import "Pivy.h"
#import "PivyDataManager.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

