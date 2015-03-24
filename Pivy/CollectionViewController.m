//
//  CollectionViewController.m
//  Pivy
//
//  Created by Pietro Degrazia on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "Pivy.h"

@interface CollectionViewController()
 @property NSString *reuseIdentifier;
 @property NSMutableArray *pivyArray;
@end

@implementation CollectionViewController

- (void)viewDidLoad {

[super viewDidLoad];
_reuseIdentifier =  @"Cell";
    self.pivyArray = [[NSMutableArray alloc]init];


    
// EVIL: Register your own cell class (or comment this out)
//[self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];

// allow multiple selections
self.collectionView.allowsMultipleSelection = YES;
self.collectionView.allowsSelection = YES;

    PFQuery *query = [PFQuery queryWithClassName:@"Pivy"];
    
    [query fromLocalDatastore];

    [self.pivyArray addObjectsFromArray:[query findObjects]];
    
    
    NSMutableArray *countries = [[NSMutableArray alloc]init];
    for (PFObject *pivy in self.pivyArray){
     [countries addObject:pivy[@"Country"]];
    }
    
    NSSet *countrySet = [[NSSet alloc]initWithArray:countries];
    
    NSLog(@"\n\nPAISES = %ld", countrySet.count);
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    self.collectionView.backgroundColor = [UIColor blueColor];
//    self.collectionView.backgroundView.backgroundColor = [UIColor brownColor];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    
    }


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.cellData.count;
    return [self.pivyArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
//    cell.textLabel.text = [self.cellData objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor brownColor];
    cell.imageCell.image = [UIImage imageNamed:@"imageTest.png"];
    cell.layer.cornerRadius = cell.layer.visibleRect.size.height /2;
    
    return cell;
}

@end

