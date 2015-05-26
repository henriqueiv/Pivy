//
//  NotificationController.m
//  Pivy WatchKit Extension
//
//  Created by Henrique Valcanaia on 4/13/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "NotificationController.h"


@interface NotificationController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;

@end

@implementation NotificationController

// Só roda fora do simulador
- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    NSLog(@"localNotification Dictionary %@", localNotification);
    self.textLabel.text = localNotification.alertBody;
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}


// No simulador sempre cai aqui
- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    // Enable data sharing in app extensions.
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.br.Pivy"
                                     containingApplication:@"br.Pivy"];
    // Setup Parse
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
    
    PFQuery *q = [PFQuery queryWithClassName:@"Pivy"];
    NSArray *obj = [q findObjects];
    NSLog(@"%@", [obj firstObject]);

    
    NSLog(@"remoteNotification Dictionary %@", remoteNotification);
    self.textLabel.text = [remoteNotification objectForKey:@"customKey"];
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification{
    NSLog(@"identifier: %@", identifier);
    NSLog(@"localNotification: %@", localNotification);
}

-(void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification{
    NSLog(@"iaeuhae");
    NSDictionary *dict = @{@"key1" : @"value1", @"key2" : @"value2", @"key3" : @"value3"};
    [WKInterfaceController openParentApplication:dict reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"iaueh");
    }];
}



@end



