//
//  LoginViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "RegisterViewController.h"


@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end

@implementation RegisterViewController{
    MBProgressHUD *hud;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIColor *color = [UIColor lightTextColor];
    NSArray *array = [[NSArray alloc] initWithObjects:_nameField, _usernameField, _emailField, _passwordField, _confirmPasswordField, nil];
    for (UITextField *tf in array) {
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tf.placeholder
                                                                   attributes:@{NSForegroundColorAttributeName: color}];
        
    }
}

- (IBAction)confirmButton:(id)sender {
    if ([_passwordField.text isEqualToString:_confirmPasswordField.text]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        PFUser *newUser = [PFUser user];
        newUser.username = _usernameField.text;
        newUser.email = _emailField.text;
        newUser.password = _passwordField.text;
        newUser[@"name"] = _nameField.text;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Success on register" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password does not match" message:@"Check your password and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)facebookSignup:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self _loadFacebookUserData:user];
        } else {
            [hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error.userInfo valueForKey:@"error"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)_loadFacebookUserData:(PFUser *)user {
    NSString *message;
    
    if (user.isNew)
        message = @"Enjoy you brand new Pivy account";
    else
        message = @"You already had an account, so we just updated your info on our servers";
    
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
                [hud hide:YES];
                if (succeeded){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login success"
                                                                    message:message
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
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}
@end
