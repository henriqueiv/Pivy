//
//  Pivy.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "Pivy.h"

@implementation Pivy

@dynamic name;
@dynamic location;
@dynamic Country;
@dynamic image;
@dynamic pivyDescription;
@dynamic countryCode;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
