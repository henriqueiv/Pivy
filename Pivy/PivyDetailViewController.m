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

@end

@implementation PivyDetailViewController

- (void)viewDidLoad {
    //    NSLog(@"Entro no didload da detail");
    [super viewDidLoad];
    
    //Localize strings
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.name, @"Pivy's name")];
    self.countryLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.Country, @"Pivy's country")];
    self.descriptionTextView.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.pivyDescription, @"Pivy's description")];
    [self.pivy.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:data];
        });
    }];
    [self checkIfHasPivy];
    
    [self.btnGetPivy setTitle:@"GET" forState:UIControlStateNormal];
    [self.btnGetPivy setTitle:@"You have this Pivy" forState:UIControlStateDisabled];
    _btnGetPivy.layer.cornerRadius = 18;
    _btnGetPivy.layer.borderColor = [[UIColor colorWithRed:250/255.0f
                                                     green:211/255.0f
                                                      blue:10.0/255.0f
                                                     alpha:1.0f] CGColor];
    _btnGetPivy.layer.borderWidth = 1;
    [self setBackgroundForCountryCode:self.pivy.countryCode];
}


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
            else{
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    PFQuery *query = [PFQuery queryWithClassName:[Pivy parseClassName]];
                    [query fromLocalDatastore];
                    query = [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:1];
                    query = [query whereKey:@"pivy" equalTo:self.pivy];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(object){
                            self.btnGetPivy.enabled = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:self.pivy];                       }
                        else{
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
//            NSLog(@"PINOU");
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"SAVOU");
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
