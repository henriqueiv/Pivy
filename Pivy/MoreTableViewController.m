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
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
