//
//  MapViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "MapViewController.h"
#import "LocalAnnotation.h"
#import "PivyDetailViewController.h"

#define kViewModeNearby 0
#define kViewModeWorld 1
#define kLatitudeDeltaNearby 2
#define kLongitudeDeltaNearby 2
#define kLatitudeDeltaWorld 180
#define kLongitudeDeltaWorld 180
#define DEBUG 1

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapViewModeSelector;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self populateWorld];
    
    self.mapViewModeSelector.layer.cornerRadius = 5; // Remove white borders from bounds
    [self.mapViewModeSelector addTarget:self
                                 action:@selector(changeViewModeMap)
                       forControlEvents:UIControlEventValueChanged];
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

-(void)viewWillAppear:(BOOL)animated{
    [self populateWorld];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)populateWorld{
    PFQuery *query = [[Pivy query] fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (Pivy *pivy in objects) {
            LocalAnnotation *localAnnotation = [[LocalAnnotation alloc] initWithPivy:pivy];
            [self.mapView addAnnotation:localAnnotation];
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[LocalAnnotation class]]){
        // Try to dequeue an existing pin view first.
        MKAnnotationView* pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
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
//    LocalAnnotation *la = (LocalAnnotation*) view.annotation;
    [self performSegueWithIdentifier:@"gotoPivyDetailFromMap" sender:view.annotation];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"gotoPivyDetailFromMap"]) {
        LocalAnnotation *a = (LocalAnnotation*) sender;
        PivyDetailViewController *pdvc = (PivyDetailViewController*) segue.destinationViewController;
        pdvc.pivy = a.pivy;
    }
    
}

-(CLLocationCoordinate2D) addressLocation {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                           [@"abc" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSStringEncodingConversionAllowLossy  error:nil];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
        
    }
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    
    return location;
}


-(void)changeViewModeMap{
    switch (self.mapViewModeSelector.selectedSegmentIndex) {
        case kViewModeNearby:{
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            
            span.latitudeDelta = kLatitudeDeltaNearby;
            span.longitudeDelta = kLongitudeDeltaNearby;
            
            region.span = span;
            region.center = self.mapView.region.center;
            
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
            [self.mapView setRegion:adjustedRegion animated:YES];
            self.mapView.showsUserLocation = YES;
            
            break;
        }
            
        case kViewModeWorld:{
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            
            span.latitudeDelta = kLatitudeDeltaWorld;
            span.longitudeDelta = kLongitudeDeltaWorld;
            region.span = span;
            region.center = self.mapView.region.center;
            
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
            [self.mapView setRegion:adjustedRegion animated:YES];
            self.mapView.showsUserLocation = YES;
            
            break;
        }
            
        default:{
            NSLog(@"ViewMode não esperado!");
            break;
        }
    }
}


@end