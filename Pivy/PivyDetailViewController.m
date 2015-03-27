//
//  PivyDetailViewController.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "PivyDetailViewController.h"

@interface PivyDetailViewController ()

@end

@implementation PivyDetailViewController

//-(id)initWithPivy:(Pivy *)pivy{
//    self = [super init];
//    if(self){
//        self.nameLabel.text = pivy.name;
//        self.countryLabel.text = pivy.Country;
//        self.locationLabel.text = @"LOL";
//        self.descriptionTextView.text = pivy.Description;
//    }
//    return self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD");
    NSLog(@"%@", self.pivy.name);
    self.nameLabel.text = self.pivy.name;
    self.countryLabel.text = self.pivy.Country;
    self.locationLabel.text = @"LOL";
    self.descriptionTextView.text = self.pivy.Description;
    
}
@end
