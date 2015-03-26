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
#import "CollectionViewCellHeader.h"
#import "Pivy.h"
#import "AppDelegate.h"

@interface CollectionViewController()

@property NSString *reuseIdentifier;
@property NSMutableDictionary *pivyDic;
@property NSMutableArray *countries;
@property NSMutableArray *pivyArray;

@end


@implementation CollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _reuseIdentifier =  @"Cell";
    // EVIL: Register your own cell class (or comment this out)
    //[self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    // allow multiple selections
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.allowsSelection = YES;
    
//    PFQuery *query = [Pivy query];
//    [query fromLocalDatastore];
//    [query orderByAscending:@"Country"];
//    NSArray *objects = [[NSArray alloc]init];
//    objects = [query findObjects];
//    
//    for(Pivy *pivy in objects){
////        NSLog(@"%@", pivy.Country);
//    }
//    
//    
//    NSString *currentCountry = [[NSString alloc]init];
//    currentCountry = [[objects firstObject] Country];
//    
//    self.pivyDic = [[NSMutableDictionary alloc]init];
////    self.pivyArray = [[NSMutableArray alloc]init];
////    [self.pivyDic setObject:self.pivyArray forKey:@"China"];
//    for (Pivy *pivy in objects) {
//        if ([self.pivyDic objectForKey:pivy.Country]) {
//            [[self.pivyDic objectForKey:pivy.Country] addObject:pivy];
////            NSLog(@"--- KEY: %@ --- OBJ: %@ --",pivy.Country, pivy.name);
//        }
//        else{
//            NSMutableArray *pivyArray = [[NSMutableArray alloc]initWithObjects:pivy, nil];
//            [self.pivyDic setObject:pivyArray forKey:pivy.Country];
//            
////            NSLog(@"--- ELSE ---");
//        }
//    }
////    NSLog(@"DICIONARIO");
////    NSLog(@"%@", self.pivyDic);
////    
////    NSLog(@"CONTAGENS");
////    NSLog(@"%ld", self.pivyDic.count);
   
    
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(15, 0, 15, 0);
   
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionViewCellHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

    header.image.image = [UIImage imageNamed:@"franceBanner.png"];
    
    return header;
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    self.collectionView.backgroundColor = [UIColor blueColor];
    //    self.collectionView.backgroundView.backgroundColor = [UIColor brownColor];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.pivyDic.count;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSString *key = [self.countries objectAtIndex:section];
    return [[self.pivyDic objectForKey:key] count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Pivy *pivy = [[Pivy alloc]init];
    pivy = [[self.pivyDic objectForKey:[self.countries objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor brownColor];
    cell.layer.cornerRadius = cell.layer.visibleRect.size.height /2;
    
    if(pivy.image){
        cell.imageCell.image = [UIImage imageWithData:[pivy.image getData]];
    }
    else{
        cell.imageCell.image = [UIImage imageNamed:@"imageTest.png"];
    }
    
    NSLog(@"SECTION: %ld    ROW: %ld   PIVY: %@", indexPath.section, indexPath.row, pivy.name  );
    
    return cell;
}

@end

