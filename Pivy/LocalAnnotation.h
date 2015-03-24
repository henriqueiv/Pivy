//
//  LocalAnnotation.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/9/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Pivy.h"

@interface LocalAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Pivy *pivy;

-(id)initWithPivy:(Pivy*)pivy;

@end
