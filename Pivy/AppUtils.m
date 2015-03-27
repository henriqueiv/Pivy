//
//  AppUtils.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/27/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AppUtils.h"
#import "Reachability.h"

@implementation AppUtils

+ (BOOL)hasInternetConnection{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
