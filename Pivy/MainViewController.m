//
//  ViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MainViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface MainViewController ()

@property (weak, nonatomic) Pivy *pivy;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *pivyDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPivy;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) NSMutableArray *array;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    [self placeViewFromStoryboardOnTabBar];
    
    [self.btnGetPivy setTitle:@"GET" forState:UIControlStateNormal];
    [self.btnGetPivy setTitle:@"You have this Pivy" forState:UIControlStateDisabled];
    _btnGetPivy.layer.cornerRadius = 18;
    _btnGetPivy.layer.borderColor = [[UIColor colorWithRed:250/255.0f
                                                     green:211/255.0f
                                                      blue:10.0/255.0f
                                                     alpha:1.0f] CGColor];
    _btnGetPivy.layer.borderWidth = 1;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    //    locationManager.distanceFilter = kDistanceFilter; The default distanceFilter for startMonitoringSignificantLocationChanges is 500 meters.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startMonitoringSignificantLocationChanges];
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
    PFQuery *query = [PFQuery queryWithClassName:[Background parseClassName]];
    [query fromLocalDatastore];
    [query whereKey:@"country" equalTo:countryCode];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backgroundImageView.image = [UIImage imageWithData:data];
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
                                    self.backgroundImageView.image = [UIImage imageWithData:data];
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

-(void)sendPush:(Pivy*) pivy{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.category = @"myCategory";
    notification.fireDate = [NSDate date];
    notification.alertBody = [NSString stringWithFormat:@"Hey, you're near to %@ Pivy! Gotta catch'em all!", pivy.name];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    NSLog(@"nextBadgeNumber: %d", nextBadgeNumber);
//    notification.applicationIconBadgeNumber = nextBadgeNumber;
}

-(NSArray *)getPivysWithinKilometers:(int)km{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:[Pivy parseClassName]];
        [query fromLocalDatastore];
        query = [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:km];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            Pivy *p = (Pivy *)object;
            self.pivy = p;
            self.pivyDescription.text = p.pivyDescription;
            self.image.image = [[UIImage alloc] initWithData:[p.image getData]];
            self.nameLabel.text = p.name;
            [self sendPush:p];
        }];
        
    }];
    return nil;
}

-(void)checkIfHasPivy{
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    [query whereKey:@"pivy" equalTo:self.pivy];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (objects.count != 0){
                self.btnGetPivy.enabled = NO;
                self.btnGetPivy.alpha = 0.5;
            }
            else
                self.btnGetPivy.enabled = YES;
        });
    }];
}

- (IBAction)getPivy:(UIButton *)sender {
    if ([PFUser currentUser]) {
        Gallery *g = [[Gallery alloc] init];
        g.pivy = self.pivy;
        g.from = [PFUser currentUser];
        g.to = [PFUser currentUser];
        
        [g pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"PINOU");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SAVOU");
                if (succeeded) {
                    [g saveEventually];
                    [self checkIfHasPivy];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:self.pivy];
                }
            });
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Please" message:@"You are note logged, please go to more tab and login or sign up" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self getPivysWithinKilometers:1];
}

@end
