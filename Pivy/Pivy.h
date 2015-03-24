//
//  Pivy.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "Objeto.h"
#import <Parse/Parse.h>

@interface Pivy : PFObject<PFSubclassing>

@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *Description;
@property (nonatomic, strong) NSString *Country;
@property (nonatomic, strong) PFFile *image;

+ (NSString *)parseClassName;

@end
