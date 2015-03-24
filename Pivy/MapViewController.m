//
//  MapViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "LocalAnnotation.h"
#import <CoreLocation/CoreLocation.h>

#define kViewModeNearby 0
#define kViewModeWorld 1
#define kDistanceViewModeWorldLatitude 2000000
#define kDistanceViewModeWorldLongitude 2000000
#define kDistanceViewModeNearbyLatitude 30000
#define kDistanceViewModeNearbyLongitude 30000

@interface MapViewController ()
@property NSString *titleAuxiliar;
@property NSString *descriptionAuxiliar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSelector;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self populateWorld];
    self.mapView.mapType = MKMapTypeStandard;
    
    [self.mapTypeSelector addTarget:self
                             action:@selector(changeViewModeMap)
                   forControlEvents:UIControlEventValueChanged];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)populateWorld{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        NSLog(@"\n\nSOU O ERRO:%@", error);
        PFQuery *query = [PFQuery queryWithClassName:@"Pivy"];
        
        CLLocationCoordinate2D userCoord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userCoord, 6000, 6000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            NSLog(@"\n\nNUMERO IGUAL A \n %li", objects.count);
            for (PFObject *local in objects) {
//                NSLog(@"%@", local);
                PFGeoPoint *geoPoint= local[@"location"];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                
                LocalAnnotation *localAnnotation = [[LocalAnnotation alloc]initWithTitle:local[@"name"] Location:coord];
                
                [self.mapView addAnnotation:localAnnotation];
            }
        }];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[LocalAnnotation class]]){
        // Try to dequeue an existing pin view first.
        MKAnnotationView*    pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView){
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            
            UIImage *pinImage =[UIImage imageNamed:@"customPin.jpg"];
            
            pinView.image = pinImage;
            pinView.centerOffset = CGPointMake(0, -(pinImage.size.height)/2);
            pinView.canShowCallout = YES;
            
            // If appropriate, customize the callout by adding accessory views (code not shown).
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
            
            UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customPin.png"]];
            
            pinView.leftCalloutAccessoryView = myCustomImage;
        }else{
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    _titleAuxiliar = view.annotation.title;
    _descriptionAuxiliar = @"OIOIOI";
    
    [self performSegueWithIdentifier:@"gotoDetail" sender:view];
}

-(void)changeViewModeMap{
//    NSLog(@"%ld", (long)self.mapTypeSelector.selectedSegmentIndex);
    switch (self.mapTypeSelector.selectedSegmentIndex) {
        case kViewModeNearby:{
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.region.center, kDistanceViewModeNearbyLatitude, kDistanceViewModeNearbyLongitude);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
            self.mapView.showsUserLocation = YES;
            
            break;
        }
            
        case kViewModeWorld:{
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.region.center, kDistanceViewModeWorldLatitude, kDistanceViewModeWorldLongitude);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
            self.mapView.showsUserLocation = YES;
            
            break;
        }
            
        default:{
//            NSLog(@"ViewMode não esperado!");
            break;
        }
    }
}


@end