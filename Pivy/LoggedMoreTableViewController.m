//
//  LoggedMoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoggedMoreTableViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoggedMoreTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;

@end

@implementation LoggedMoreTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _nameLabel.text = [[PFUser currentUser]valueForKey:@"username"];
    _mailLabel.text = [[PFUser currentUser]valueForKey:@"email"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
//         [[PFFacebookUtils session] close];
        [PFUser logOut];
    }
}

@end
