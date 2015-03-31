//
//  AppDelegate.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#define PARSE_APPLICATION_ID @"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
#define PARSE_CLIENT_KEY @"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"
#import "Background.h"
#import "DataManager.h"
#import "Gallery.h"
#import "MBProgressHUD.h"
#import "Pivy.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

