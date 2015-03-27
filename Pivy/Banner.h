//
//  Banner.h
//  Pivy
//
//  Created by Pietro Degrazia on 3/27/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Parse/Parse.h>

@interface Banner : PFObject<PFSubclassing>
@property NSString *country;
@property PFFile *image;
+ (NSString *)parseClassName;

@end
