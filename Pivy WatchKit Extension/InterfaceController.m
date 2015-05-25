//
//  InterfaceController.m
//  Pivy WatchKit Extension
//
//  Created by Henrique Valcanaia on 4/13/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification{
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    [self handleAction:identifier forNotification:dict];
}

-(void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification{
    
}

-(void)handleAction:(NSString*)identifier forNotification:(NSDictionary*)notification{
    if ([identifier isEqualToString:@"getSinglePivyCategory"]) {
        
    }
}

@end



