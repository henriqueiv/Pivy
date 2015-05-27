//
//  GlanceInterfaceController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 5/26/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "GlanceInterfaceController.h"
#import <Parse/Parse.h>
#define PARSE_APPLICATION_ID @"rCoHIuogBuDRydKFZVPeMr5fyquq8tMpUsQJ1Cyx"
#define PARSE_CLIENT_KEY @"2uvNt4S4yykRQiCzwdY6UvkEGOxY6cSaVsE9qvnL"

@interface GlanceInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pivyNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryDate;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *pivyImage;

@end

@implementation GlanceInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.br.Pivy"
                                     containingApplication:@"br.Pivy"];
    [Parse enableLocalDatastore];
    // Setup Parse
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Gallery"];
//    [[query fromLocalDatastore] includeKey:@"pivy"];
    [query includeKey:@"pivy"];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error){
        [self updateUserActivity:@"br.Pivy.handoff.detail"
                        userInfo:@{@"objectId":[obj objectForKey:@"objectId"]}
                      webpageURL:nil];
        if (!error) {
            NSLog(@"obj: %@", obj);
            self.pivyNameLabel.text = [[obj objectForKey:@"pivy"]objectForKey:@"name"];
            NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
            [dfm setDateFormat:@"yyyy-mm-dd HH:mm:ss"];
            self.galleryDate.text = [dfm stringFromDate:[obj objectForKey:@"createdAt"]];
            [[obj objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    [self.pivyImage setImage:[[UIImage alloc] initWithData:data]];
                    NSLog(@"foi satã");
                }else{
                    NSLog(@"erroo, %@", error);
                }
            }];
        }else{
            NSLog(@"error: %@", error);
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



