//
//  LoginViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "RegisterViewController.h"


@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation RegisterViewController{
    MBProgressHUD *hud;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _usernameField.delegate = self;
    _emailField.delegate = self;
    _passwordField.delegate = self;
    _confirmPasswordField.delegate = self;
    
    UIColor *color = [UIColor lightTextColor];
    NSArray *array = [[NSArray alloc] initWithObjects:_usernameField, _emailField, _passwordField, _confirmPasswordField, nil];
    for (UITextField *tf in array) {
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(tf.placeholder, @"Placeholder for Register")
                                                                   attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView setUserInteractionEnabled:YES];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSArray *array = [[NSArray alloc] initWithObjects:_usernameField, _emailField, _passwordField, _confirmPasswordField, nil];
    for (int i = 0; i < array.count; i++) {
        if (theTextField == array[i]) {
            if (i < array.count-1) {
                [(UITextField*) array[i+1] becomeFirstResponder];
            }else{
                [self confirmButton:nil];
            }
        }
    }

//    if(theTextField == _nameField){
//        [_emailField becomeFirstResponder];
//    }else if (theTextField == _usernameField){
//        [_emailField becomeFirstResponder];
//    }else if (theTextField == _emailField){
//        [_passwordField becomeFirstResponder];
//    }else if(theTextField ==_passwordField){
//        [_confirmPasswordField becomeFirstResponder];
//    }else if (theTextField == _confirmPasswordField){
//        [self confirmButton:nil];
//    }
    return YES;
}

- (BOOL)validateFields{
    NSArray *array = [[NSArray alloc] initWithObjects:_nameField, _usernameField, _emailField, _passwordField, _confirmPasswordField, nil];
    for (UITextField *tf in array) {
        if ([tf.text isEqual:@""]) {
            [tf becomeFirstResponder];
            [tf selectAll:nil]; // if sender is nil then just select the text, if !=nil then select and show the menu
            return false;
        }
    }
    
    if (![_passwordField.text isEqualToString:_confirmPasswordField.text]) {
        [_confirmPasswordField becomeFirstResponder];
        [_confirmPasswordField selectAll:nil];
        return false;
    }
    
    return true;
}

- (IBAction)confirmButton:(id)sender {
    if ([self validateFields]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        PFUser *newUser = [PFUser user];
        newUser.username = _usernameField.text;
        newUser.email = _emailField.text;
        newUser.password = _passwordField.text;
        [newUser setObject:_nameField.text forKey:@"name"];
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                if (!error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Title for successfull register")
                                                                    message:NSLocalizedString(@"Success on register", @"Message for successfull register")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Button for successfull register")
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    [self performSegueWithIdentifier:@"gotoLogged" sender:sender];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fail", @"Title for error in register")
                                                                    message:[error.userInfo valueForKey:@"error"]
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Button for error in register")
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            });
        }];
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
    if ([UIImagePickerController availableCaptureModesForCameraDevice:(UIImagePickerControllerCameraDeviceRear)]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }else{
        [self noCamera];
    }
}

- (void)noCamera{
#warning TODO Create localizable
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"No rear camera available message", @"There is no rear camera available in this device. Message for UIAlertView")];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No rear camera available title", @"There is no rear camera available in this device. Title for UIAlertView")
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Button for successfull login with FB")
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.layer.visibleRect.size.height/2;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
