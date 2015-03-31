//
//  PivyDetailViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDetailViewController.h"
#import "Gallery.h"
#import "MBProgressHUD.h"


@interface PivyDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnGetPivy;

@end

@implementation PivyDetailViewController

- (void)viewDidLoad {
    NSLog(@"Entro no didload da detail");
    [super viewDidLoad];
    self.nameLabel.text = self.pivy.name;
    self.countryLabel.text = self.pivy.Country;
    self.descriptionTextView.text = self.pivy.pivyDescription;
    [self checkIfHasPivy];
    
    _btnGetPivy.layer.cornerRadius = 18;
    _btnGetPivy.layer.borderColor = [[UIColor colorWithRed:250/255.0f
                                                     green:211/255.0f
                                                      blue:10.0/255.0f
                                                     alpha:1.0f] CGColor];
    _btnGetPivy.layer.borderWidth = 1;
    
    
    [self setBackgroundForCountryCode:self.pivy.countryCode];
    
    //Add blur effect to background
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [self.backgroundImageView addSubview:effectView];
}


-(void) setBackgroundForCountryCode:(NSString *)countryCode{
    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
    [query fromLocalDatastore];
    NSLog(@"Inicio query de Backgrounds");
    [query whereKey:@"country" equalTo:countryCode];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backgroundImageView.image = [UIImage imageWithData:data];
                    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
                    effectView.frame = self.view.frame;
                    [self.backgroundImageView addSubview:effectView];
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
            if (objects.count != 0)
                self.btnGetPivy.hidden = YES;
            else
                self.btnGetPivy.hidden = NO;
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


@end
