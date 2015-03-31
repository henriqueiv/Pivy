//
//  DataManager.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/30/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "DataManager.h"
#define DEBUG 1

@implementation DataManager

+ (void) updateLocalDatastore:(NSString*) className {
    [DataManager updateLocalDatastore:className inBackground:NO];
}

+ (void) updateLocalDatastore:(NSString*) className inBackground:(BOOL)inBackground{
    if ([AppUtils hasInternetConnection]) {
        PFQuery *query = [PFQuery queryWithClassName:className];
        if(inBackground){
            [[[query fromLocalDatastore] orderByDescending:@"createdAt"] getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                NSDate *date;
                if (error) {
                    NSLog(@"updateLocalDatastore ERRO\n%@", error);
                }else{
                    if (object) {
                        date = object.createdAt;
#ifdef DEBUG
                        NSLog(@"updateLocalDatastore Objeto encontrado, baixando a partir de %@", date);
#endif
                    }else{
                        date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                        NSLog(@"updateLocalDatastore Objeto NAO encontrado, baixando a partir de %@", date);
#endif
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
                    });
                }
            }];
        }else{
            NSError *error;
            query = [[query fromLocalDatastore] orderByDescending:@"createdAt"];
            PFObject *object = [query getFirstObject:&error];
            if (error) {
                NSLog(@"updateLocalDatastore Erro\n%@", error);
            }else{
                
            }
            
            NSDate *date;
            if (object) {
                date = object.createdAt;
#ifdef DEBUG
                NSLog(@"updateLocalDatastore Objeto encontrado, baixando a partir de %@", date);
#endif
            }else{
                date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                NSLog(@"updateLocalDatastore Objeto NAO encontrado, baixando a partir de %@", date);
#endif
            }
            [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
        }
    }else{
        NSLog(@"updateLocalDatastore Sem internet!");
    }
}

+ (void) downloadFromParse:(NSString*) className afterDate:(NSDate*)date inBackground:(BOOL)inBackground{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"createdAt" greaterThan:date];
    if([className isEqualToString:[Gallery parseClassName]]){
        if ([PFUser currentUser]){
            [query whereKey:@"to" equalTo:[PFUser currentUser]];
        }else{
            NSLog(@"DataManager.downloadFromParse:: Para utilizar a galeria tem que setar o usuario animal!");
            return;
        }
    }
    
    if (inBackground) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
#ifdef DEBUG
                NSLog(@"downloadFromParse \n%ld %@ baixados AGORA", objects.count, className);
#endif
                NSMutableArray *galleries = [[NSMutableArray alloc] initWithArray:objects];
                [PFObject pinAllInBackground:galleries
                                       block:^(BOOL succeeded, NSError *error) {
                                           if (succeeded) {
                                               NSLog(@"downloadFromParse Pivys pinados com sucesso!!!!!!");
                                           }else{
                                               NSLog(@"downloadFromParse Sem sucesso");
                                           }
                                           if(error){
                                               NSLog(@"downloadFromParse Erroooo: %@", error);
                                           }else{
                                               NSLog(@"downloadFromParse Não deu erro");
                                           }
                                       }];
            }
        }];
    }else{
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        if (error) {
            NSLog(@"downloadFromParse Erro!\n%@", error);
        }else{
            if (objs) {
#ifdef DEBUG
                NSLog(@"downloadFromParse \n%ld gallery baixados AGORA", objs.count);
#endif
                [PFObject pinAll:objs error:&error];
            }else{
                NSLog(@"downloadFromParse Nenhum objeto");
            }
        }
    }
}

+ (void) deleteAll:(NSString*) className{
    [DataManager deleteAll:className inBackground:NO];
}

+ (void) deleteAll:(NSString*) className inBackground:(BOOL)inBackground{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query fromLocalDatastore];
    if([className isEqualToString:[Gallery parseClassName]]){
        if ([PFUser currentUser]){
            [query whereKey:@"to" equalTo:[PFUser currentUser]];
        }else{
            NSLog(@"DataManager.downloadFromParse:: Para utilizar a galeria tem que setar o usuario animal!");
            return;
        }
    }
    
    if (!inBackground) {
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        for (PFObject *o in objs) {
            [o unpin:&error];
            if (error) {
                NSLog(@"deleteAll Erro\n%@", error);
            }else{
            }
        }
    }else{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error){
                NSLog(@"deleteAll Erro");
            }else{
            }
            if (objects) {
#ifdef DEBUG
                NSLog(@"deleteAll %lu %@ encontrados para excluir", (unsigned long)objects.count, className);
#endif
                for (PFObject *o in objects) {
                    [o unpinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            
                        }else{
                            NSLog(@"deleteAll Sem sucesso");
                        }
                        
                        if (error) {
                            NSLog(@"deleteAll Erro\n%@", error);
                        }else{
                            
                        }
                    }];
                }
            }else{
                NSLog(@"deleteAll Nenhum objeto");
            }
        }];
    }
}

@end
