//
//  Galery.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/26/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Parse/Parse.h>
#import "Pivy.h"

@interface Gallery : PFObject<PFSubclassing>

@property PFUser *from;
@property PFUser *to;
@property Pivy *pivy;

+(NSString *)parseClassName;

@end
