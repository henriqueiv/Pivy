//
//  MoreTableViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/24/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MoreTableViewController.h"

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController

-(void)viewDidLoad{
    [self.navigationItem setHidesBackButton:YES];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPivyNotification" object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
