//
//  PivyDetailViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDetailViewController.h"
#import "RoundedImageView.h"
#define kRangeInKm 10000

@interface PivyDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet RoundedImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *botaoManeiroGetPivy;

@end

@implementation PivyDetailViewController

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Localize strings
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.name, @"Pivy's name")];
    self.descriptionTextView.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.pivyDescription, @"Pivy's description")];
    [self.pivy.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:data];
            [self.view sendSubviewToBack:self.backgroundImageView];
        });
    }];
    
    [self.botaoManeiroGetPivy setTitle:@"GET PIVY" forState:UIControlStateNormal];
    [self.botaoManeiroGetPivy setTitle:@"Unable to get pivy" forState:UIControlStateDisabled];
    [self checkIfHasPivy];
    
    self.botaoManeiroGetPivy.layer.cornerRadius = self.botaoManeiroGetPivy.frame.size.height/4;
    self.botaoManeiroGetPivy.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.botaoManeiroGetPivy.layer.borderWidth = 1;
    [self setBackgroundForCountryCode:self.pivy.countryCode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetPivyNotification:)
                                                 name:@"GetPivyNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pegarPivy:)
                                                 name:@"getSinglePivyFromWatch"
                                               object:@"watch"];
}

-(void)handleGetPivyNotification:(Pivy*) pivy{
    [self checkIfHasPivy];
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

-(void) checkIfHasPivy{
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    [query whereKey:@"pivy" equalTo:self.pivy];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (objects.count != 0){
                [self.botaoManeiroGetPivy setTitle:@"You have this Pivy" forState:UIControlStateDisabled];
                self.botaoManeiroGetPivy.enabled = NO;
                self.botaoManeiroGetPivy.alpha = 0.5;
            }else{
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if ([geoPoint distanceInKilometersTo:self.pivy.location] <= kRangeInKm) {
                        self.botaoManeiroGetPivy.titleLabel.text = @"GET PIVY";
                        self.botaoManeiroGetPivy.enabled = YES;
                    }else{
                        [self.botaoManeiroGetPivy setTitle:@"You're too far" forState:UIControlStateDisabled];
                        self.botaoManeiroGetPivy.enabled = NO;
                        self.botaoManeiroGetPivy.alpha = 0.5;
                    }
                }];
            }
        });
    }];
}

- (IBAction)pegarPivy:(id)sender {
    if ([PFUser currentUser]) {
        Gallery *g = [[Gallery alloc] init];
        if ([(NSString*)sender isEqualToString:@"watch"]) {
            g.pivy = (Pivy*)[[NSUserDefaults standardUserDefaults] objectForKey:@"getSinglePivyFromWatch"];
        }else{
            g.pivy = self.pivy;
        }
        g.from = [PFUser currentUser];
        g.to = [PFUser currentUser];
        [g pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (succeeded) {
                    [g saveEventually];
                    [self checkIfHasPivy];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:g.pivy];
                }
            });
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Please" message:@"You are note logged, please go to more tab and login or sign up" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
