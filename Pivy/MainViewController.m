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
#import "MainTableViewCell.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *pivyDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPivy;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) NSMutableArray *array;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    [self placeViewFromStoryboardOnTabBar];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.btnGetPivy setTitle:@"GET" forState:UIControlStateNormal];
    [self.btnGetPivy setTitle:@"Pivy not available" forState:UIControlStateDisabled];
    _btnGetPivy.layer.cornerRadius = 18;
    _btnGetPivy.layer.borderColor = [[UIColor colorWithRed:250/255.0f
                                                     green:211/255.0f
                                                      blue:10.0/255.0f
                                                     alpha:1.0f] CGColor];
    _btnGetPivy.layer.borderWidth = 1;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self getPivysWithinKilometers:1];
    
    [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:YES];
    dispatch_async(kBgQueue, ^{
        [DataManager updateLocalDatastore:[Background parseClassName] inBackground:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBackground];
        });
    });
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)setBackground{
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

- (void)queryAndPinClassInBackground:(NSString *)class{
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

- (void)placeViewFromStoryboardOnTabBar{
    
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

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks lastObject];
                        NSLog(@"Country with placemark: %@", placemark);
        } else
            NSLog(@"Error %@", error.description);
    }];
}

-(NSArray *)getPivysWithinKilometers:(int)km{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        PFQuery *query = [PFQuery queryWithClassName:[Pivy parseClassName]];
        [query fromLocalDatastore];
        query = [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:km];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            Pivy *p = (Pivy *)object;
            self.pivyDescription.text = p.pivyDescription;
            self.image.image = [[UIImage alloc] initWithData:[p.image getData]];
            self.nameLabel.text = p.name;
        }];
        
        
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            for (Pivy *pivy in objects) {
//                NSLog(@"%@", objects);
//                _array = [NSMutableArray arrayWithArray:objects];
//                [self.tableView reloadData];
//                UILabel *tx = [[UILabel  alloc] init];
//                tx.frame = CGRectMake(0, 0, 100, 100);
//                tx.text = pivy.pivyDescription;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.view addSubview:tx];
//                });
//            }
//        }];
        
        
    }];
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MainTableViewCell *cell = [[MainTableViewCell alloc] init];
//    Pivy *pivy = (Pivy *)[_array objectAtIndex:indexPath.row];
    cell.nameLabel.text = @"Fuck the system";
    return cell;
}
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    [self reverseGeocode:newLocation];
//        NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
//}
@end
