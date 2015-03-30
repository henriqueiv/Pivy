//
//  CollectionViewController.m
//  Pivy
//
//  Created by Pietro Degrazia on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PivyDetailViewController.h"
#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "CollectionViewCellHeader.h"
#import "Pivy.h"
#import "Gallery.h"
#import "AppDelegate.h"

@interface CollectionViewController()

@property NSString *reuseIdentifier;
@property NSMutableDictionary *pivyDic;
@property NSMutableArray *countries;
@property NSMutableArray *pivyArray;
@property NSArray *galleryArray;

@end


@implementation CollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _reuseIdentifier =  @"Cell";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
   
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsSelection = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    [self createCollection];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self createCollection];
    if([PFUser currentUser])
       [self createGallery];
   [self.collectionView reloadData];
}

-(void)createCollection{
    PFQuery *query = [Pivy query];
    [query fromLocalDatastore];
    [query orderByAscending:@"Country"];
    
    NSArray *objects = [[NSArray alloc]init];
    objects = [query findObjects];
    
#ifndef NDEBUG
    NSLog(@"%lu", (unsigned long)objects.count);
#endif
    if (objects) {
        self.pivyDic = [[NSMutableDictionary alloc]init];
        self.countries = [[NSMutableArray alloc]init];
        for (Pivy *pivy in objects) {
            if ([self.pivyDic objectForKey:pivy.Country]) {
                [[self.pivyDic objectForKey:pivy.Country] addObject:pivy];
            }else{
                NSMutableArray *pivyArray = [[NSMutableArray alloc]initWithObjects:pivy, nil];
                [self.pivyDic setObject:pivyArray forKey:pivy.Country];
                [self.countries addObject:pivy.Country];
            }
        }
    }

}

-(void)createGallery{
    PFQuery *galleryQuery = [Gallery query];
    [galleryQuery fromLocalDatastore];
    
    [galleryQuery whereKey:@"from" equalTo:[PFUser currentUser]];

    self.galleryArray = [[NSArray alloc]init];
    self.galleryArray = [galleryQuery findObjects];
}

- (void) startRefresh:(UICollectionView *)startRefresh {
    [self.collectionView reloadData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == (self.pivyDic.count)-1)
        return UIEdgeInsetsMake(15, 0, 66, 0);
    else
        return UIEdgeInsetsMake(15, 0, 15, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

    header.headerLabel.text = [self.countries objectAtIndex:indexPath.section];
    
    return header;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToPivyDetailFromCollection"]) {
        CollectionViewCell *cell = (CollectionViewCell*) sender;
        PivyDetailViewController *pdvc = (PivyDetailViewController*) segue.destinationViewController;
        pdvc.pivy = cell.pivy;
    }}

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
    cell.layer.cornerRadius = cell.layer.visibleRect.size.height /2;
    cell.pivy = pivy;
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.alpha = 0.2;
    for(Gallery *gallery in self.galleryArray){
        if( (pivy.name == gallery.pivy.name) && (gallery.to == [PFUser currentUser]) ){
            cell.contentView.alpha = 1;
        }
    }

    if(pivy.image){
        
        [pivy.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *ourImage = [UIImage imageWithData:data];
            cell.imageCell.image = ourImage;
        }];
        
    }
    else{
        cell.imageCell.image = [UIImage imageNamed:@"imageTest.png"];
    }
    return cell;
}

@end

