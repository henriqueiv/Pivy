//
//  GalleryDataManager.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/27/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "GalleryDataManager.h"

@implementation GalleryDataManager

-(void)downloadGalleries{
    if ([AppUtils hasInternetConnection]) {
        PFQuery *query = [Gallery query];
        [[[query fromLocalDatastore] orderByDescending:@"createdAt"] getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSDate *date;
            if (error) {
                NSLog(@"ERRO\n%@", error);
            }else{
                if (object) {
                    Gallery *gallery = (Gallery*) object;
                    date = gallery.createdAt;
#ifdef DEBUG
                    NSLog(@"Objeto encontrado, baixando a partir de %@", date);
#endif
                }else{
                    date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                    NSLog(@"Objeto NAO encontrado, baixando a partir de %@", date);
#endif
                }
                [self performSelectorOnMainThread:@selector(downloadAfterBackgroundWithDate:)
                                       withObject:date
                                    waitUntilDone:NO];
            }
        }];
        
        [[[query fromLocalDatastore] orderByDescending:@"createdAt"] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
#ifdef DEBUG
                NSLog(@"\n%ld gallerys já baixados", objects.count);
#endif
                NSDate *date;
                if (objects.count > 0) {
                    Gallery *gallery = (Gallery*) objects[0];
                    date = gallery.createdAt;
#ifdef DEBUG
                    NSLog(@"gallery 0: %@", gallery.createdAt);
#endif
                }else{
                    date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
                }
                // Manda de volta pra main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", date);
                });
                [self performSelectorOnMainThread:@selector(downloadAfterBackgroundWithDate:)
                                       withObject:date
                                    waitUntilDone:NO];
            }
        }];
    }
}

-(void)downloadAfterBackgroundWithDate: (NSDate *)date{
    PFQuery *query = [Gallery query];
#ifdef DEBUG
    NSLog(@"Maior data: %@", date);
#endif
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
#ifdef DEBUG
            NSLog(@"\n%ld gallery baixados AGORA", objects.count);
#endif
            NSMutableArray *galleries = [[NSMutableArray alloc] initWithArray:objects];
            [PFObject pinAllInBackground:galleries
                                   block:^(BOOL succeeded, NSError *error) {
                                       if (succeeded) {
                                           NSLog(@"Pivys pinados com sucesso!!!!!!");
                                       }else{
                                           NSLog(@"Sem sucesso");
                                       }
                                       if(error){
                                           NSLog(@"Erroooo: %@", error);
                                       }else{
                                           NSLog(@"Não deu erro");
                                       }
                                   }];
        }
    }];
}

-(void)clearLocalDB{
    NSInteger count;
    PFQuery *query = [Gallery query];
    [query fromLocalDatastore];
    for (Gallery *gallery in [query findObjects]) {
#ifndef NDEBUG
        if([gallery unpin]){
            count++;
        }
#else
        [gallery unpin];
#endif
    }
    
#ifndef NDEBUG
    NSLog(@"%ld galleries excluidos localmente", count);
#endif
    
}


@end
