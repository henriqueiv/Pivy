//
//  AppDelegate.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse];
    [self configureTabBar];
    [self configureNavigationBar];
    
    UILocalNotification *launchNote = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNote){
        [self renumberBadgesOfPendingNotifications];
    }
    
    [self registerForLocalNotification];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"userid"] = [PFUser currentUser].objectId;
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

-(void)registerForLocalNotification{
    // Create a mutable set to store the category definitions.
    NSMutableSet* categories = [NSMutableSet set];
    
    // Define the actions for a meeting invite notification.
    UIMutableUserNotificationAction* acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.title = NSLocalizedString(@"Get Pivy", @"Title for get Pivy notif");
    acceptAction.identifier = @"getSinglePivyAction";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground; //UIUserNotificationActivationModeBackground if no need in foreground.
    acceptAction.authenticationRequired = NO;
    
    // Create the category object and add it to the set.
    UIMutableUserNotificationCategory* getSinglePivyCategory = [[UIMutableUserNotificationCategory alloc] init];
    [getSinglePivyCategory setActions:@[acceptAction]
                    forContext:UIUserNotificationActionContextDefault];
    getSinglePivyCategory.identifier = @"getSinglePivyCategory";
    
    [categories addObject:getSinglePivyCategory];
    
    // Configure other actions and categories and add them to the set...
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:
                                            (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)
                                                                             categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

-(void)configureNavigationBar{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:250/255.0f
//                                                        green:211/255.0f
//                                                         blue:10.0/255.0f
//                                                        alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

-(void)configureParse{
    [Gallery registerSubclass];
    [Pivy registerSubclass];
    [Background registerSubclass];
    
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
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [DataManager updateLocalDatastore:[Background parseClassName] inBackground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if (notification.alertBody) {
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pivy"
                                                            message:notification.alertBody
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    [self renumberBadgesOfPendingNotifications];
}

- (void)renumberBadgesOfPendingNotifications{
    // clear the badge on the icon
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
    NSArray *pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // if there are any pending notifications -> adjust their badge number
    if (pendingNotifications.count != 0) {
        // clear all pending notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // the for loop will 'restore' the pending notifications, but with corrected badge numbers
        // note : a more advanced method could 'sort' the notifications first !!!
        NSUInteger badgeNbr = 1;
        
        for (UILocalNotification *notification in pendingNotifications){
            // modify the badgeNumber
            notification.applicationIconBadgeNumber = badgeNbr++;
            
            // schedule 'again'
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    // Pivy é incluido no UserDefatults ao lançar a notificação na detail
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSinglePivyFromWatch" object:nil];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    // Pivy é incluido no UserDefatults ao lançar a notificação na detail
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSinglePivyFromWatch" object:nil];
}

-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
    NSLog(@"aiuh");
}

@end
