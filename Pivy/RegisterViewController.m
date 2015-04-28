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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RegisterViewController{
    MBProgressHUD *hud;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _nameField.delegate = self;
    _usernameField.delegate = self;
    _emailField.delegate = self;
    _passwordField.delegate = self;
    _confirmPasswordField.delegate = self;
    
    UIColor *color = [UIColor lightTextColor];
    NSArray *array = [[NSArray alloc] initWithObjects:_nameField, _usernameField, _emailField, _passwordField, _confirmPasswordField, nil];
    for (UITextField *tf in array) {
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(tf.placeholder, @"Placeholder for Register")
                                                                   attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView setUserInteractionEnabled:YES];
    
    
    UIColor *colorPlaceHolder = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.30];
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Username" attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];
   
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Email" attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];
    
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Password" attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];
    
    _confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Confirm password" attributes:@{NSForegroundColorAttributeName: colorPlaceHolder}];
    
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if(theTextField==_nameField){
        [_usernameField becomeFirstResponder];
    }else if (theTextField == _usernameField){
        [_emailField becomeFirstResponder];
    }else if (theTextField == _emailField){
        [_passwordField becomeFirstResponder];
    }else if(theTextField ==_passwordField){
        [_confirmPasswordField becomeFirstResponder];
    }else if (theTextField == _confirmPasswordField){
        [self confirmButton:nil];
    }
    return YES;
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Title for successfull register") message:NSLocalizedString(@"Success on register", @"Message for successfull register") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for successfull register") otherButtonTitles:nil, nil];
                [alert show];
                [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fail", @"Title for error in register") message:[error.userInfo valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for error in register") otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password does not match", @"Title for password not matching") message:NSLocalizedString(@"Check your password and try again", @"Message for password not matching") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for password not matching") otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)facebookSignup:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self _loadFacebookUserData:user];
        } else {
            [hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fail", @"Title message for error in facebook register") message:[error.userInfo valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for error in facebook register") otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)_loadFacebookUserData:(PFUser *)user {
    NSString *message;
    
    if (user.isNew)
        message = [NSString stringWithFormat:NSLocalizedString(@"Enjoy you brand new Pivy account", @"Message for new account created")];
    else
        message = [NSString stringWithFormat:NSLocalizedString(@"You already had an account, so we just updated your info on our servers", @"Message for existing account on Pivy")];
    
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login success", @"Login successfull with FB") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button for successfull login with FB") otherButtonTitles:nil, nil];
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

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.layer.visibleRect.size.height/2;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
