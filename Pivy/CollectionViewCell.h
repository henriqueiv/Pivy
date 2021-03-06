//
//  CollectionViewCell.h
//  Pivy
//
//  Created by Pietro Degrazia on 3/20/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "AsyncImageView.h"
#import "Pivy.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *imageCell;
@property (weak, nonatomic) Pivy *pivy;


@end
