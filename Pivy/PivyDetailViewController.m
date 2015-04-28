//
//  PivyDetailViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDetailViewController.h"

@interface PivyDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnGetPivy;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation PivyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Localize strings
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.name, @"Pivy's name")];
    self.countryLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.Country, @"Pivy's country")];
    self.descriptionTextView.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.pivyDescription, @"Pivy's description")];
    [self.pivy.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:data];
            [self.view sendSubviewToBack:self.backgroundImageView];
        });
    }];
    
    [self.btnGetPivy setTitle:@"GET PIVY" forState:UIControlStateNormal];
    [self.btnGetPivy setTitle:@"Unable to get pivy" forState:UIControlStateDisabled];
    
    
    self.btnGetPivy.layer.cornerRadius = 18;
    self.btnGetPivy.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.btnGetPivy.layer.borderWidth = 1;
    [self setBackgroundForCountryCode:self.pivy.countryCode];
}
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear: NO];
//
//}

-(void) setBackgroundForCountryCode:(NSString *)countryCode{
    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
    [query fromLocalDatastore];
    [query whereKey:@"country" equalTo:countryCode];
    NSLog(@"Inicio query de Backgrounds");
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backgroundImageView.image = [UIImage imageWithData:data];
                    NSLog(@"Background alterado com sucesso");
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:[error.description valueForKey: @"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
}


-(void)checkIfHasPivy{
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    [query whereKey:@"pivy" equalTo:self.pivy];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (objects.count != 0){
                [self.btnGetPivy setTitle:@"You have this Pivy" forState:UIControlStateDisabled];
                self.btnGetPivy.enabled = NO;
                self.btnGetPivy.alpha = 0.5;
            }else{
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    PFQuery *query = [PFQuery queryWithClassName:[Pivy parseClassName]];
                    [query fromLocalDatastore];
                    query = [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:1];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(object){
                            Pivy *pivy = (Pivy*)object;
                            if([pivy isEqual:self.pivy]){
                                self.btnGetPivy.titleLabel.text = @"GET";
                                self.btnGetPivy.enabled = YES;
                            }else{
                                [self.btnGetPivy setTitle:@"You're too far" forState:UIControlStateDisabled];
                                self.btnGetPivy.enabled = NO;
                                self.btnGetPivy.alpha = 0.5;
                            }
                        }else{
                            self.btnGetPivy.enabled = NO;
                            self.btnGetPivy.alpha = 0.5;
                        }
                    }];
                }];
            }
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
            dispatch_async(dispatch_get_main_queue(), ^{
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


@end
