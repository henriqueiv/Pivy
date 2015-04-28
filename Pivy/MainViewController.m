//
//  ViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MainViewController.h"
#import "PivyDetailViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define kRangeInKm 10

@interface MainViewController ()

@property (strong, nonatomic) NSMutableArray *pivyArray;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) Pivy *pivy;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = true;
    
    [self placeViewFromStoryboardOnTabBar];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startMonitoringSignificantLocationChanges];
    
    [self getPivysWithinKilometers:kRangeInKm];
    
    [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)placeViewFromStoryboardOnTabBar{
    
    //Link with More.storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    NSMutableArray *array = [NSMutableArray   arrayWithArray:[self.tabBarController viewControllers]];
    UIViewController *vc;
    
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

- (void)sendPush:(NSArray *) pivys{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.category = @"myCategory";
    notification.fireDate = [NSDate date];
    if (pivys.count == 1) {
        Pivy *p = (Pivy *)pivys.firstObject;
        notification.alertBody = [NSString stringWithFormat:@"Hey, you're near to %@ Pivy! Gotta catch'em all!", p.name];
    }
    else{
        notification.alertBody = [NSString stringWithFormat:@"Hey, you're near to %d Pivys! Gotta catch'em all!", (int)pivys.count];
    }
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    NSLog(@"nextBadgeNumber: %d", (int)nextBadgeNumber);
}

- (NSArray *)getPivysWithinKilometers:(int )km{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:[Pivy parseClassName]];
        [query fromLocalDatastore];
        query = [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:km];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                NSMutableArray *a = [[NSMutableArray alloc] initWithArray:objects];
                self.pivyArray = a;
                if(self.pivyArray.count > 0)
                    [self sendPush:self.pivyArray];
            }
        }];
    }];
    return nil;
}

- (IBAction)getPivy:(UIButton *)sender {
    if (self.pivyArray.count > 0){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        for(int i =0; i < self.pivyArray.count; i++){
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
            PivyDetailViewController *detail = (PivyDetailViewController *)vc;
            detail.pivy = (Pivy *)self.pivyArray[i];
            
            detail.view.frame = CGRectMake(self.scrollView.frame.size.width*i, 0, detail.view.frame.size.width, detail.view.frame.size.height);
            [self.scrollView addSubview:detail.view];
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * self.pivyArray.count, self.scrollView.frame.size.height)];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self getPivysWithinKilometers:kRangeInKm];
}

@end
