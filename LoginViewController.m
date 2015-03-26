//
//  LoginViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButton:(UIButton *)sender {
    
    [PFUser logInWithUsernameInBackground:_usernameField.text password:_passwordField.text
                                    block:^(PFUser *user, NSError *error)
     {
         if (user) {
             [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
     }];
}
- (IBAction)facebookLogin:(id)sender {
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else if (user.isNew) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup sucess" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
        } else {
            NSLog(@"%@", user);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login success" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
        }
    }];
}

@end
