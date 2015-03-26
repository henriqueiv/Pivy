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
    
    NSLocale *countryLocale = [NSLocale currentLocale];
    NSString *countryCode = [countryLocale objectForKey:NSLocaleCountryCode];
    NSString *country = [countryLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
    NSLog(@"Country Locale:%@  Code:%@ Name:%@", countryLocale, countryCode, country);
    
    [self testInternetConnection];
    
    

    //Link with More.storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    NSMutableArray *array = [NSMutableArray   arrayWithArray:[self.tabBarController viewControllers]];
    UIViewController *vc;
    NSLog(@"%@", [PFUser currentUser]);
    if ([PFUser currentUser])
        vc = [sb instantiateViewControllerWithIdentifier:@"more"];
    else
        vc = [sb instantiateViewControllerWithIdentifier:@"more"];
    
    [vc setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:4]];
    [array addObject:vc];
    [self.tabBarController setViewControllers:array];
    
}

-(void)downloadPivys{
    PFQuery *query = [Pivy query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *pivys = [[NSMutableArray alloc] initWithArray:objects];
        [PFObject pinAllInBackground:pivys
                               block:^(BOOL succeeded, NSError *error) {
                                   if (succeeded) {
                                       NSLog(@"Pivys pinados com sucesso!!!!!!");
                                   }else{
                                       NSLog(@"Sem sucesso");
                                   }
                                   if(error){
                                       NSLog(@"Erroooo: %@", error);
                                   }else{
                                       NSLog(@"Não deu erro");
                                   }
                               }];
    }];
}

- (void)testInternetConnection{
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach){
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            [self downloadPivys];
            //hide view blocking everything else
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach){
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            //show view blocking everything else
        });
    };
    
    [internetReachable startNotifier];
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

@end
