//
//  LoggedMoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/25/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "LoggedMoreTableViewController.h"
#import "PivyDataManager.h"
#import "GalleryDataManager.h"

#define kSectionLogin 0
#define kSectionConfig 1
#define kSectionAbout  2
#define kRowName 
#define kRowLogout 2
#define kRowDownloadPIVY 1
#define kRowClearPIVY 2
#define kRowDownloadGallery 3
#define kRowClearGallery 4

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
    NSLog(@"SECTION: %ld  ROW: %ld",indexPath.section , indexPath.row);
    
    if(indexPath.section == kSectionLogin){
        
        
    }
    
//    switch (indexPath.row) {
//        case  (kRowLogout):{
//            [[PFFacebookUtils session] close];
//            [PFUser logOut];
//            [self performSegueWithIdentifier:@"gotoMore" sender:nil];
//            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//            break;
//        }
//        case (kRowName):{
//            FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                          NSDictionary* result,
//                                                          NSError *error) {
//                NSArray* friends = [result objectForKey:@"data"];
//                NSLog(@"Found: %lu friends", (unsigned long)friends.count);
//                for (NSDictionary<FBGraphUser>* friend in friends) {
//                    NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
//                }
//            }];
//            break;
//        }
//        case (kRow):{
//            NSLog(@"PEGOU A 3");
//            break;
//        }
//        default:
//            break;
//    }
}

@end
