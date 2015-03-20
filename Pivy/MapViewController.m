//
//  MapViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//
#import "MapViewController.h"

@interface MapViewController ()
@property NSString *titleAuxiliar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    NSLog(@"\n\nCOMECEI");
}

@end