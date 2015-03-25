//
//  Objeto.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/19/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Objeto : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@end
