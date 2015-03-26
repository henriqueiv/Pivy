//
//  LocalAnnotation.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/9/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LocalAnnotation.h"

@implementation LocalAnnotation

-(id)initWithPivy:(Pivy *)pivy{
    self = [super init];
    if(self){
        _title = pivy.name;
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(pivy.location.latitude, pivy.location.longitude);
        _coordinate = coord;
        _pivy = pivy;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"Title: %@,\nCoordinate: %f : %f,\nPivy: %@", _title, _coordinate.latitude, _coordinate.longitude, _pivy];
}


@end
