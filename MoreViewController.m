//
//  MoreViewController.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/23/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MoreViewController.h"

@implementation MoreViewController
NSArray *array;


-(void)viewWillAppear:(BOOL)animated{
    array = [[NSArray alloc] initWithObjects:@"Login",@"Signup", @"Teste",nil];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"User";
    else
        return @"Section 2";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
        return [array count];
    else
        return 5;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0)
        cell.textLabel.text = [array objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [NSString stringWithFormat:@"index: %d", (int)indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row] message:@"Fuck you!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
