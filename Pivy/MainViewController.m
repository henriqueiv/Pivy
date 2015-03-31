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
#import "Background.h"
#import "GalleryDataManager.h"
#import "DataManager.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    [self placeViewFromStoryboardOnTabBar];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:YES];
    dispatch_async(kBgQueue, ^{
        [DataManager updateLocalDatastore:[Background parseClassName] inBackground:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBackground];
        });
    });
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void) setBackground{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
//    NSLog(@"Country code: %@", countryCode);
    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
    [query fromLocalDatastore];
//    NSLog(@"Inicio query de Backgrounds");
    [query whereKey:@"country" equalTo:countryCode];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backgroundImageView.image = [UIImage imageWithData:data];
                    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
                    effectView.alpha = 0.8;
                    effectView.frame = self.view.frame;
                    [self.backgroundImageView addSubview:effectView];
//                    NSLog(@"Background alterado com sucesso");
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
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

-(void)queryAndPinClassInBackground:(NSString *)class{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:class];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            if(succeeded){
//                NSLog(@"****** %@ Pinado na MAIN ******", class);
                if ([class isEqualToString:@"Background"]) {
                    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
//                    NSLog(@"Country code: %@", countryCode);
                    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
                    [query fromLocalDatastore];
//                    NSLog(@"Inicio query de Backgrounds");
                    [query whereKey:@"country" equalTo:countryCode];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error){
                            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _backgroundImageView.image = [UIImage imageWithData:data];
//                                    NSLog(@"Background alterado com sucesso");
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                });
                            }];
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
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Pining Error", class]
                                                                message:[error.description valueForKey: @"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    }];
}

-(void)placeViewFromStoryboardOnTabBar{
    
    //Link with More.storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    NSMutableArray *array = [NSMutableArray   arrayWithArray:[self.tabBarController viewControllers]];
    UIViewController *vc;
//    NSLog(@"%@", [PFUser currentUser]);
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
    //    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitud);
}
@end
