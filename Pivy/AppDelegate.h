//
//  AppDelegate.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) NSMutableArray *pivys;


@end

