//
//  ViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    PFQuery *backgrounds = [PFQuery queryWithClassName:@"Background"];
    
    NSArray *backgroundsArray = [backgrounds findObjects];
    [PFObject pinAllInBackground:backgroundsArray block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"DEu tudo certo no pinning do parse");
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:[error.description valueForKey: @"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
}
- (IBAction)countryButton:(UIButton *)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
    [query fromLocalDatastore];
    [query whereKey:@"country" equalTo:[sender.currentTitle lowercaseString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if(!error){
            _backgroundImageView.image = [UIImage imageWithData:[object[@"image"] getData]];
            NSLog(@"Nao deu erro!!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:[error.description valueForKey: @"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSLog(@"Country: %@", placemark);
        } else
            NSLog(@"Error %@", error.description);
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self reverseGeocode:newLocation];
    //    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    //    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

@end
