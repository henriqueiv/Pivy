//
//  LoginViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    UIColor *colorPlaceHolder = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.30];
//    UIColor *color = [UIColor lightTextColor];
    //Localized strings
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Username", @"Username from user") attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", @"User's password") attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _usernameField){
        [_passwordField becomeFirstResponder];
    }else if(theTextField ==_passwordField){
        [self loginButton:nil];
    }
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (IBAction)loginButton:(UIButton *)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:_usernameField.text
                                 password:_passwordField.text
                                    block:^(PFUser *user, NSError *error){
                                        [hud hide:YES];
                                        if (user) {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Success" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            [alert show];
                                            [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            [alert show];
                                        }
                                    }];
}

- (IBAction)facebookLogin:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"]
                                    block:^(PFUser *user, NSError *error) {
                                        if (user){
                                            
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login sucess", @"Title of AlertView for login") message:NSLocalizedString(@"You are logged, enjoy", @"Message of AlertView for login") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button from AlertView") otherButtonTitles:nil, nil];
                                            [alert show];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];

                                            [self performSegueWithIdentifier:@"gotoLogged" sender:nil];
                                        }else if (user.isNew){
                                            [self _loadFacebookUserData];
                                        }
                                        else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fail", @"Title of error message") message:[error.userInfo valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button from alertView error") otherButtonTitles:nil, nil];
                                            [alert show];
                                        }
                                    }];
}

- (void)_loadFacebookUserData{
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            PFUser *user = [PFUser currentUser];
            
            NSString *facebookID = userData[@"id"];
            if (facebookID)
                user[@"facebookId"] = facebookID;
            
            NSString *name = userData[@"name"];
            if (name)
                user[@"name"] = name;
            
            NSString *email = userData[@"email"];
            if (email)
                user.email = email;
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded){
                    [hud hide:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login success", @"Title for login in facebook") message:NSLocalizedString(@"You did'n had an account, we made it automatically for you, so enjoy our Pivys!", @"Message for login in facebook sucessfull") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for successfull login") otherButtonTitles:nil, nil];
                    [alert show];
                    
                    [self performSegueWithIdentifier:@"gotoLogged" sender:nil];
                }
            }];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else
            NSLog(@"Some other error: %@", error);
    }];
}

@end
