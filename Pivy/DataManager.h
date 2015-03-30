//
//  DataManager.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/30/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "AppUtils.h"
#import "Gallery.h"

@interface DataManager : NSObject

+ (void) updateLocalDatastore:(NSString*) className;
+ (void) updateLocalDatastore:(NSString*) className inBackground:(BOOL)inBackground;

+ (void) deleteAll:(NSString*) className;
+ (void) deleteAll:(NSString*) className inBackground:(BOOL)inBackground;


@end
