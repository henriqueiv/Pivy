//
//  MainTableViewCell.m
//  Pivy
//
//  Created by Marcus Vinicius Kuquert on 3/31/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (void)awakeFromNib {
    self.nameLabel.text = @"This is greate";
    self.getButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
