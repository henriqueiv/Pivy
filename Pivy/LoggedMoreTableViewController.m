//
//  LoggedMoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoggedMoreTableViewController.h"

#define kRowLogout  2
#define kRowName 1

@interface LoggedMoreTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;

@end

@implementation LoggedMoreTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    _nameLabel.text = [[PFUser currentUser]valueForKey:@"name"];
    _mailLabel.text = [[PFUser currentUser]valueForKey:@"email"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case  (kRowLogout):{
            [[PFFacebookUtils session] close];
            [PFUser logOut];
            [self performSegueWithIdentifier:@"gotoMore" sender:nil];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        }
        case (kRowName):{
            FBRequest* friendsRequest = [FBRequest requestForMyFriends];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                          NSDictionary* result,
                                                          NSError *error) {
                NSArray* friends = [result objectForKey:@"data"];
                NSLog(@"Found: %lu friends", (unsigned long)friends.count);
                for (NSDictionary<FBGraphUser>* friend in friends) {
                    NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
                }
            }];
            break;
        }
        default:
            break;
    }
}

@end
