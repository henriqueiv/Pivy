//
//  Background.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "Objeto.h"
#import <Parse/Parse.h>

@interface Background : PFObject<PFSubclassing>

@property NSString *country;
@property PFFile *image;

+ (NSString *)parseClassName;

@end
