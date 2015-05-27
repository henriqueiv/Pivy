//
//  NotificationController.m
//  Pivy WatchKit Extension
//
//  Created by Henrique Valcanaia on 4/13/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "NotificationController.h"
#import "Pivy.h"

@interface NotificationController()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *pivyImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group;

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
    [self getPivyFromNotification:localNotification.userInfo];
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
    NSLog(@"remoteNotification Dictionary %@", remoteNotification);
    [self getPivyFromNotification:remoteNotification];
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

-(void)getPivyFromNotification:(NSDictionary *)notification{
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.br.Pivy"
                                     containingApplication:@"br.Pivy"];
    
    [Parse enableLocalDatastore];
    
    // Setup Parse
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
    
    PFQuery *q = [PFQuery queryWithClassName:@"Pivy"];
//    [q fromLocalDatastore];
    NSString *objId = [notification objectForKey:@"pivyObjectId"];
    [q whereKey:@"objectId" equalTo:objId];
    PFObject *obj = [q getFirstObject];
    [self updateUserActivity:@"br.Pivy.handoff.detail"
                    userInfo:@{@"objectId":objId}
                  webpageURL:nil];
    
    NSLog(@"Pivy: %@", obj);
    [self.pivyImage setImageNamed:@"ImgAppleWatchAnimation_"];
    [[obj objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            [self.group setBackgroundImage:[[UIImage alloc] initWithData:data]];
            
            [self.pivyImage startAnimatingWithImagesInRange:NSMakeRange(0, 49)
                                                   duration:1.5
                                                repeatCount:1];
            NSLog(@"foi satã");
        }else{
            NSLog(@"erroo, %@", error);
        }
    }];
    NSLog(@"notification Dictionary: %@", notification);
    self.textLabel.text = [NSString stringWithFormat:@"Hey, you're near to %@ Pivy", [obj objectForKey:@"name"]];
}


@end



