//
//  LoginViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "RegisterViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MBProgressHUD.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end
@implementation RegisterViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (IBAction)facebookSignup:(id)sender {

}
- (IBAction)confirmButton:(id)sender {
    
    if ([_passwordField.text isEqualToString:_confirmPasswordField.text]) {
        PFUser *newUser = [PFUser user];
        newUser.username = _usernameField.text;
        newUser.email = _emailField.text;
        newUser.password = _passwordField.text;
        newUser[@"name"] = _nameField.text;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading...";
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Success on register" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [hud hide:YES];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [hud hide:YES];
            }
        }];
    }
    
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password does not match" message:@"Check your password and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
