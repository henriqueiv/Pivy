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
#import "Pivy.h"
#import "RWBlurPopover.h"
#import "PivyDataManager.h"
#import "GalleryDataManager.h"

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
            NSLog(@"BACKGROUND Pinning OK");
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
    
    PFQuery *pivy = [PFQuery queryWithClassName:@"Pivy"];
    
    NSArray *pivyArray = [pivy findObjects];
    [PFObject pinAllInBackground:pivyArray block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"PIVY Pinning OK");
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
    
    
    PFQuery *bannerQuery = [PFQuery queryWithClassName:@"Banner"];
    
    NSArray *bannerArray = [bannerQuery findObjects];
    [PFObject pinAllInBackground:bannerArray block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"BANNER Pinning OK");
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
    
    NSLocale *countryLocale = [NSLocale currentLocale];
    NSString *countryCode = [countryLocale objectForKey:NSLocaleCountryCode];
    NSString *country = [countryLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
    NSLog(@"Country Locale:%@  Code:%@ Name:%@", countryLocale, countryCode, country);
    

    //Link with More.storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    NSMutableArray *array = [NSMutableArray   arrayWithArray:[self.tabBarController viewControllers]];
    UIViewController *vc;
    NSLog(@"%@", [PFUser currentUser]);
    if ([PFUser currentUser])
        vc = [sb instantiateViewControllerWithIdentifier:@"logged"];
    else
        vc = [sb instantiateViewControllerWithIdentifier:@"more"];
    
    [vc setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:4]];
    [array addObject:vc];
    [self.tabBarController setViewControllers:array];
    
}

-(IBAction)blur:(id)sender{
    ViewController *vc = [[ViewController alloc] initWithNibName:nil bundle:nil];
    [RWBlurPopover showContentViewController:vc insideViewController:self];
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

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks lastObject];
            //            NSLog(@"Country: %@", placemark);
        } else
            NSLog(@"Error %@", error.description);
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self reverseGeocode:newLocation];
    //    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    //    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (IBAction)clearPivys:(id)sender {
    PivyDataManager *pdm = [[PivyDataManager alloc] init];
    [pdm clearLocalDB];
}

- (IBAction)downloadGalleries:(id)sender {
    GalleryDataManager *gdm = [[GalleryDataManager alloc] init];
    [gdm downloadGalleries];
}

- (IBAction)clearGalleries:(id)sender {
    GalleryDataManager *gdm = [[GalleryDataManager alloc] init];
    [gdm clearLocalDB];
}

- (IBAction)downloadPivys:(id)sender {
    PivyDataManager *pdm = [[PivyDataManager alloc] init];
    [pdm downloadPivys];
}

@end
