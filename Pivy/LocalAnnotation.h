//
//  LocalAnnotation.h
//  iVolunteer
//
//  Created by Pietro Degrazia on 3/9/15.
//  Copyright (c) 2015 Marcus Vinicius Kuquert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface LocalAnnotation : NSObject <MKAnnotation>



@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;



-(id)initWithTitle: (NSString*)newTitle Location:(CLLocationCoordinate2D)location;

@end
