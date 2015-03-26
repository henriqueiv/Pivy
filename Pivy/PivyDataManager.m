//
//  PivyDataManager.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/26/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDataManager.h"
#import "Pivy.h"
#import <Parse/Parse.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation PivyDataManager

-(void)downloadPivys{
    if ([self hasInternetConnection]) {
        PFQuery *query = [Pivy query];
        [[[query fromLocalDatastore] orderByDescending:@"createdAt"] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
//                NSLog(@"\nPivys já baixados: %@", objects);
                NSDate *date;
                Pivy *pivy = (Pivy*) objects[0];
                if (objects.count > 0) {
//                    NSLog(@"Pivy 0: %@", pivy.createdAt);
                    date = pivy.createdAt;
                }else{
                    date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
                }
                // Manda de volta pra main thread
                [self performSelectorOnMainThread:@selector(downloadAfterBackgroundWithDate:)
                                       withObject:date
                                    waitUntilDone:NO];
            }
        }];
        
    }
}

-(void)downloadAfterBackgroundWithDate: (NSDate *)date{
    PFQuery *query = [Pivy query];
//    NSLog(@"Maior data: %@", date);
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
//            NSLog(@"\nPivys baixados AGORA: %@", objects);
            NSMutableArray *pivys = [[NSMutableArray alloc] initWithArray:objects];
            [PFObject pinAllInBackground:pivys
                                   block:^(BOOL succeeded, NSError *error) {
                                       if (succeeded) {
                                           NSLog(@"Pivys pinados com sucesso!!!!!!");
                                       }else{
                                           NSLog(@"Sem sucesso");
                                       }
                                       if(error){
                                           NSLog(@"Erroooo: %@", error);
                                       }else{
                                           NSLog(@"Não deu erro");
                                       }
                                   }];
        }
    }];
}


- (BOOL)hasInternetConnection{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
