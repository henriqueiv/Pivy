//
//  CollectionViewController.m
//  Pivy
//
//  Created by Pietro Degrazia on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "CollectionViewController.h"

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
    
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG-Purple.png"]];

    _reuseIdentifier =  @"Cell";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsSelection = YES;
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetPivyNotification:)
                                                 name:@"GetPivyNotification"
                                               object:nil];
    [self createCollection];
    
    if([PFUser currentUser])
        [self createGallery];
}

-(void)handleGetPivyNotification:(Pivy*) pivy{
    if([PFUser currentUser])
        [self createGallery];
   [self.collectionView reloadData];
}

-(void)createCollection{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [Pivy query];
    [query fromLocalDatastore];
    [query orderByAscending:@"Country"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
        if(error){
            NSLog(@"ERRO: %@", error);
        }
       dispatch_async(dispatch_get_main_queue(), ^{
           [MBProgressHUD hideHUDForView:self.view animated:YES];
           [self.collectionView reloadData];
       });
    }];
    

}

-(void)createGallery{
    PFQuery *galleryQuery = [Gallery query];
    [galleryQuery fromLocalDatastore];
    [galleryQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [galleryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects){
            self.galleryArray = [[NSArray alloc] initWithArray:objects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }];
}

- (void) startRefresh:(UIRefreshControl *)startRefresh {
    [startRefresh beginRefreshing];
    [DataManager updateLocalDatastore:[Gallery parseClassName] inBackground:NO];
    if([PFUser currentUser])
        [self createGallery];
    [self.collectionView reloadData];
    [startRefresh endRefreshing];
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
        pdvc.hidesBottomBarWhenPushed = true;
    }}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.pivyDic.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *key = [self.countries objectAtIndex:section];
    return [[self.pivyDic objectForKey:key] count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Pivy *pivy = [[self.pivyDic objectForKey:[self.countries objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    cell.layer.cornerRadius = cell.layer.visibleRect.size.height /2;
    cell.pivy = pivy;
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.alpha = 0.2;
    for(Gallery *gallery in self.galleryArray){
        if( ([pivy.name isEqualToString:gallery.pivy.name]) && ([gallery.to isEqual:[PFUser currentUser]]) ){
            cell.contentView.alpha = 1;
        }
    }
    
    cell.imageCell.crossfadeDuration = 0;

    if(pivy.image){
        
        [AsyncImageLoader cancelPreviousPerformRequestsWithTarget:cell.imageCell];
        cell.imageCell.image = [UIImage imageNamed:@"PIVY_logo.png"];
        [cell.imageCell setImageURL:[NSURL URLWithString:(NSString *)[pivy.image url]]];
        
    }
    else{

        cell.imageCell.image = [UIImage imageNamed:@"PIVY_logo.png"];
    }
    return cell;
}

@end

