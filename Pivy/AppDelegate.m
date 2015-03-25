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

@property MBProgressHUD *HUD;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse];
//    [self getPivys];
    [self myProgressTask];
    //    [[UITabBar appearance] setSelectedImageTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    return YES;
}

-(void)configureParse{
    //    NSArray *parseClassesToRegister = [[NSArray alloc] initWithArray:[Pivy class]];
    //    for (int i = 0; i < parseClassesToRegister.count; i++) {
    //        PFObject<PFSubclassing> *obj = (PFObject<PFSubclassing>*)NSClassFromString([parseClassesToRegister[i] parseClassName]);
    //        [obj ];
    //    }
//    [Objeto registerSubclass];
    [Pivy registerSubclass];
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
                  clientKey:@"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"];
}

-(void)getPivys{
    _HUD = [[MBProgressHUD alloc] initWithView:_window];
    _HUD.mode = MBProgressHUDModeDeterminate;
    [_window addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading";;
    [_HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    [_window makeKeyAndVisible];
}

-(void)myProgressTask{
    PFQuery *query = [Pivy query];
//    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _pivys = [[NSMutableArray alloc] initWithArray:objects];
        [PFObject pinAllInBackground:_pivys
                               block:^(BOOL succeeded, NSError *error) {
                                   if(error){
                                       NSLog(@"%@", error);
                                   }
                               }];
        //[hud hide:YES];
//        NSLog(@"pivys: %@", _pivys);
    }];
}


@end
