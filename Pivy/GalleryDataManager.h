//
//  GalleryDataManager.h
//  Pivy
//
//  Created by Henrique Valcanaia on 3/27/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gallery.h"
#import "AppUtils.h"

@interface GalleryDataManager : NSObject

-(void)downloadGalleries;
-(void)clearLocalDB;

@end
