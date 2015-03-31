//
//  AppDelegate.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AppDelegate.h"

#define PARSE_APPLICATION_ID @"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
#define PARSE_CLIENT_KEY @"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse];
    [self configureTabBar];
    [self configureNavigationBar];
    return YES;
}

-(void)configureNavigationBar{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:250/255.0f
                                                        green:211/255.0f
                                                         blue:10.0/255.0f
                                                        alpha:1.0f]];
}

-(void)configureParse{
    [Gallery registerSubclass];
    [Pivy registerSubclass];
    
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
    [self downloadData];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

-(void)downloadData{
    [self downloadAppData];
    [self downloadUserData];
}

-(void)downloadAppData{
    [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:NO];
}

-(void)downloadUserData{
    [DataManager updateLocalDatastore:[Gallery parseClassName] inBackground:NO];
}

@end
