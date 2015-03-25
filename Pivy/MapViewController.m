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
#import "PivyDetailViewController.h"
#import "AppDelegate.h"

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
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapViewModeSelector;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self populateWorld];
    
    [self.mapViewModeSelector addTarget:self
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
    LocalAnnotation *la = (LocalAnnotation*) view.annotation;
    NSLog(@"%@", la);
    //    [self performSegueWithIdentifier:@"gotoPivyDetail" sender:view.annotation];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"gotoPivyDetail"]) {
        LocalAnnotation *a = (LocalAnnotation*) sender;
        PivyDetailViewController *pdvc = (PivyDetailViewController*) segue.destinationViewController;
    }
}

-(void)changeViewModeMap{
    switch (self.mapViewModeSelector.selectedSegmentIndex) {
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
            NSLog(@"ViewMode não esperado!");
            break;
        }
    }
}


@end