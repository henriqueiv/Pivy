//
//  ViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "Pivy.h"
#import "PivyDataManager.h"
#import "GalleryDataManager.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self placeViewFromStoryboardOnTabBar];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [self queryAndPinClassInBackground:@"Pivy"];
    
}

-(void)queryAndPinClassInBackground:(NSString *)class{
    MBProgressHUD *hud;

    [hud showAnimated:YES whileExecutingBlock:^{
    PFQuery *query = [PFQuery queryWithClassName:class];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *array = objects;
        [PFObject pinAllInBackground:array block:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                NSLog(@"****** %@ Pinado na MAIN ******", class);
                if ([class isEqualToString:@"Background"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
                        NSLog(@"%@", countryCode);
                        PFQuery *query = [PFQuery queryWithClassName:@"Background"];
                        [query fromLocalDatastore];
                        NSLog(@"Inicio query de Backgrounds");
                        [query whereKey:@"country" equalTo:countryCode];
                        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if(!error){
                                _backgroundImageView.image = [UIImage imageWithData:[object[@"image"] getData]];
                                NSLog(@"Background alterado com sucesso");
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
                    });
                    
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Pining Error", class]
                                                                message:[error.description valueForKey: @"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];
    }];
    }];
}

-(void)placeViewFromStoryboardOnTabBar{
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

//- (void)reverseGeocode:(CLLocation *)location {
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (!error) {
//            CLPlacemark *placemark = [placemarks lastObject];
//                        NSLog(@"Country with placemark: %@", placemark);
//        } else
//            NSLog(@"Error %@", error.description);
//    }];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    [self reverseGeocode:newLocation];
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
