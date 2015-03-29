//
//  PivyDetailViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDetailViewController.h"
#import "Gallery.h"

@interface PivyDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnGetPivy;

@end

@implementation PivyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = self.pivy.name;
    self.countryLabel.text = self.pivy.Country;
    self.locationLabel.text = @"LOL";
    self.descriptionTextView.text = self.pivy.Description;
    [self checkIfHasPivy];
}

-(void)checkIfHasPivy{
    
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    [query whereKey:@"pivy" equalTo:self.pivy];
    NSLog(@"1");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"2");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnGetPivy.enabled = (objects.count == 0);
            NSLog(@"3");
            //            if (objects.count == 0){
            //                self.btnGetPivy.enabled = YES;
            //            }else{
            //                self.btnGetPivy.enabled = NO;
            //                Gallery *g = (Gallery*) objects[0];
            //                NSLog(@"%@", g);
            //            }
        });
        NSLog(@"4");
    }];
    NSLog(@"5");
    
}

- (IBAction)getPivy:(id)sender {
    Gallery *g = [[Gallery alloc] init];
    g.pivy = self.pivy;
    g.from = [PFUser currentUser];
    g.to = [PFUser currentUser];
    [g pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeeded) {
                [g saveEventually];
                [self checkIfHasPivy];
            }
        });
    }];
}


@end
