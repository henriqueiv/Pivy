//
//  LoggedMoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoggedMoreTableViewController.h"

@interface LoggedMoreTableViewController () <UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;

@end

@implementation LoggedMoreTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
    self.nameLabel.text = [[PFUser currentUser]valueForKey:@"name"];
    self.mailLabel.text = [[PFUser currentUser]valueForKey:@"email"];
    [self.tabBarController setDelegate:self];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG-Purple.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case kSectionLogin:{
            switch (indexPath.row) {
                case (kRowName):{
//                    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//                    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                                  NSDictionary* result,
//                                                                  NSError *error) {
//                        NSArray* friends = [result objectForKey:@"data"];
//                        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
//                        for (NSDictionary<FBGraphUser>* friend in friends) {
//                            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
//                        }
                    [DataManager deleteAll:[Background parseClassName] inBackground:NO];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
//                    }];
                    break;
                }
                case  (kRowLogout):{
                    [[PFFacebookUtils session] close];
                    [PFUser logOut];
                    [DataManager deleteAll:[Gallery parseClassName] inBackground:YES];
                    [self performSegueWithIdentifier:@"gotoMore" sender:nil];
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case kSectionConfig:{
            switch (indexPath.row) {
                case (kRowDownloadPIVY):{
                    [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
                    break;
                }
                case  (kRowClearPIVY):{
                    [DataManager deleteAll:[Pivy parseClassName] inBackground:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
                    break;
                }
                case  (kRowDownloadGallery):{
                    [DataManager updateLocalDatastore:[Gallery parseClassName] inBackground:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
                    break;
                }
                case  (kRowClearGallery):{
                    [DataManager deleteAll:[Gallery parseClassName] inBackground:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
                    break;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return (viewController != tabBarController.selectedViewController);
}

@end
