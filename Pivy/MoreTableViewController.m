//
//  MoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/24/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MoreTableViewController.h"

@interface MoreTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *cellLogin;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSignUp;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAbout;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTeam;

@end

@implementation MoreTableViewController

-(void)viewDidLoad{
    [self.navigationItem setHidesBackButton:YES];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG-Purple.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    
    self.tableView.backgroundView = tempImageView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setCellsBackgroundColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setCellsBackgroundColor{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithObjects:self.cellLogin, self.cellSignUp, self.cellAbout, self.cellTeam, nil];
    
    for (UITableViewCell *cell in cells) {
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }
}

@end
