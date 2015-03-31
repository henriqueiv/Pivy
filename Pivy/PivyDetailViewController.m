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
    [super viewDidLoad];
    //self.nameLabel.text = self.pivy.name;
    //self.countryLabel.text = self.pivy.Country;
    //self.descriptionTextView.text = self.pivy.pivyDescription;
    
    //Localize strings
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.name, @"Pivy's name")];
    self.countryLabel.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.Country, @"Pivy's country")];
    self.descriptionTextView.text = [NSString stringWithFormat:NSLocalizedString(self.pivy.pivyDescription, @"Pivy's description")];
    
    [self checkIfHasPivy];

    PFQuery *query = [PFQuery queryWithClassName:@"Background"];
    [query fromLocalDatastore];
    NSLog(@"Inicio query de Backgrounds");
    [query whereKey:@"country" equalTo:self.pivy.countryCode];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            _backgroundImageView.image = [UIImage imageWithData:[object[@"image"] getData]];
            NSLog(@"Background alterado com sucesso");
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BAckground setting error"
                                                            message:[error.description valueForKey: @"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
    
    //add blur effect to background
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [self.backgroundImageView addSubview:effectView];
}

-(void)checkIfHasPivy{
    
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    [query whereKey:@"pivy" equalTo:self.pivy];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnGetPivy.enabled = (objects.count == 0);
        });
    }];
}

- (IBAction)getPivy:(UIButton *)sender {
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
            }
        });
    }];
}


@end
