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
#import "Gallery.h"
#import "Banner.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#define PARSE_APPLICATION_ID @"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
#define PARSE_CLIENT_KEY @"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse];
    [self configureTabBar];
    return YES;
}

-(void)configureParse{
    [Gallery registerSubclass];
    [Pivy registerSubclass];
    [Banner registerSubclass];
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    [PFFacebookUtils initializeFacebook];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

-(void)configureTabBar{
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:250/255.0f
                                                        green:211/255.0f
                                                         blue:10.0/255.0f
                                                        alpha:1.0f]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setAlpha:0.9f];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}
@end
