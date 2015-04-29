//
//  RoundedImageView.m
//  Pivy
//
//  Created by Henrique Valcanaia on 4/28/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "RoundedImageView.h"

@implementation RoundedImageView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self roundCorner];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self roundCorner];
    }
    return self;
}

-(void)roundCorner{
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.cornerRadius = self.layer.visibleRect.size.height/2;
    self.layer.borderWidth = 1.0;
    self.layer.masksToBounds = YES;
}

@end
