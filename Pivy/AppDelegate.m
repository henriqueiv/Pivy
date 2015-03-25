//
//  AppDelegate.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Pivy.h"
#import "Objeto.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    return YES;
}

-(void)configureParse{
    [Pivy registerSubclass];
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
                  clientKey:@"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"];
}


@end
