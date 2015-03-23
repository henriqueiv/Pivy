//
//  LocalAnnotation.m
//  iVolunteer
//
//  Created by Pietro Degrazia on 3/9/15.
//  Copyright (c) 2015 Marcus Vinicius Kuquert. All rights reserved.
//

#import "LocalAnnotation.h"

@implementation LocalAnnotation

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location{
    
    self = [super init];
    
    if(self){
        
        _title = newTitle;
        
        _coordinate = location;
        
    }
    
    return self;
    
}

@end
