//
//  AppDelegate.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AppDelegate.h"
#define kNotificationCall @"notificationCall"
#define kGlanceCall @"glanceCall"

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
    
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.br.Pivy"];
    
    
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
    [self getPivyFromNotification:userInfo];
    completionHandler();
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    [self getPivyFromNotification:notification.userInfo];
    completionHandler();
}

-(void)getPivyFromNotification:(NSDictionary*)dict{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSinglePivyFromWatch" object:[dict objectForKey:@"objectId"]];
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    NSString *call = userInfo[@"pfquery_request"];
    if ([call isEqualToString:kNotificationCall]) {
        NSLog(@"Starting PFQuery"); // won't print out to console since you're running the watch extension
        
        // 1. Run the PFQuery
        // 2. Write the data into MMWormhole (done in PFQuery completion block)
        // 3. Send the reply back to the extension as success (done in PFQuery completion block)
        PFQuery *q = [Pivy query];
        [q fromLocalDatastore];
        NSString *objId = [userInfo objectForKey:@"pivyObjectId"];
        [q whereKey:@"objectId" equalTo:objId];
        NSError *error;
        PFObject *obj = [q getFirstObject:&error];
        if (!error) {
            NSData *data = [[obj objectForKey:@"image"] getData];
            if (data) {
//                NSLog(@"foi satã");
                reply(@{@"success": @(YES),
                        @"name": [obj objectForKey:@"name"],
                        @"imageData": data
                        });
            } else{
                NSLog(@"Error getting data");
                reply(@{@"success": @(NO),
                        @"error": error.localizedDescription});
            }
        }else{
            NSLog(@"Error getting first obj in bg: %@", error);
            reply(@{@"success": @(NO),
                    @"error": error.localizedDescription});
        }
    }else if ([call isEqualToString:kGlanceCall]) {
        PFQuery *query = [Gallery query];
        [query fromLocalDatastore];
        [query includeKey:@"pivy"];
        [query orderByDescending:@"createdAt"];
        NSError *errorGetFirstObj;
        Gallery *gallery = (Gallery*) [query getFirstObject:&errorGetFirstObj];
        if (!errorGetFirstObj) {
            Pivy *pivy = gallery.pivy;
            NSError *errorGetData;
            NSData *data = [pivy.image getData:&errorGetData];
            if (!errorGetData) {
                NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
                [dfm setDateFormat:@"yyyy-mm-dd HH:mm"];
                reply(@{@"success": @(YES),
                        @"date": [dfm stringFromDate:gallery.createdAt],
                        @"name": pivy.name,
                        @"imageData": data,
                        @"objectId": pivy.objectId
                        });
            }else{
                NSLog(@"Error getting data: %@", errorGetData);
                reply(@{@"success": @(NO),
                        @"error get data": errorGetData.localizedDescription
                        });
            }
            
        }else{
            NSLog(@"Error getting first obj: %@", errorGetFirstObj);
            reply(@{@"success": @(NO),
                    @"error get first obj": errorGetFirstObj.localizedDescription
                    });
        }
    }else{
        reply(@{@"success": @(NO),
                @"error": @"Invalid call"});
    }
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler{
    UIWindow *win = self.window;
    UIViewController *vc = win.rootViewController;
    [vc restoreUserActivityState:userActivity];
    return YES;
}

@end
