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
    
    //Chage placeholder color
    UIColor *color = [UIColor lightTextColor];
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
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
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login success"
                                                                                            message:@"You are logged, enjoy"
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil, nil];
                                            [alert show];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];

                                            [self performSegueWithIdentifier:@"gotoLogged" sender:nil];
                                        }else if (user.isNew){
                                            [self _loadFacebookUserData];
                                        }
                                        else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login success"
                                                                    message: @"You did'n had an account, we made it automatically for you, so enjoy our Pivys!"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
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
