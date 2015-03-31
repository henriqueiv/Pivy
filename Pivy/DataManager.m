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
                    NSLog(@"DataManager.updateLocalDatastore(%@):: Erro: %@", className, error);
                }else{
                }
                if (object) {
                    date = object.createdAt;
#ifdef DEBUG
                    NSLog(@"DataManager.updateLocalDatastore(%@) Objeto encontrado, baixando a partir de %@", className, date);
#endif
                }else{
                    date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                    NSLog(@"DataManager.updateLocalDatastore(%@) Objeto NAO encontrado, baixando a partir de %@", className, date);
#endif
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
                });
                
            }];
        }else{
            NSError *error;
            query = [[query fromLocalDatastore] orderByDescending:@"createdAt"];
            PFObject *object = [query getFirstObject:&error];
            if (error) {
                NSLog(@"DataManager.updateLocalDatastore(%@):: Erro: %@", className, error);
            }else{
                
            }
            
            NSDate *date;
            if (object.createdAt) {
                date = object.createdAt;
#ifdef DEBUG
                NSLog(@"DataManager.updateLocalDatastore(%@):: Objeto encontrado, baixando a partir de %@", className, date);
#endif
            }else{
                date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                NSLog(@"DataManager.updateLocalDatastore(%@):: Objeto NAO encontrado, baixando a partir de %@", className, date);
#endif
            }
            [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
        }
    }else{
        NSLog(@"DataManager.updateLocalDatastore(%@):: Sem internet!", className);
    }
}

+ (void) downloadFromParse:(NSString*) className afterDate:(NSDate*)date inBackground:(BOOL)inBackground{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"createdAt" greaterThan:date];
    if([className isEqualToString:[Gallery parseClassName]]){
        if ([PFUser currentUser]){
            [query whereKey:@"to" equalTo:[PFUser currentUser]];
        }else{
            NSLog(@"DataManager.downloadFromParse(%@):: Para utilizar a galeria tem que setar o usuario animal!", className);
            return;
        }
    }
    
    if (inBackground) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
#ifdef DEBUG
                NSLog(@"DataManager.downloadFromParse(%@):: %ld baixados AGORA", className, objects.count);
#endif
                NSMutableArray *galleries = [[NSMutableArray alloc] initWithArray:objects];
                [PFObject pinAllInBackground:galleries
                                       block:^(BOOL succeeded, NSError *error) {
                                           if (succeeded) {
                                               NSLog(@"DataManager.downloadFromParse(%@):: Pinados com sucesso", className);
                                           }else{
                                               NSLog(@"DataManager.downloadFromParse(%@):: Sem sucesso", className);
                                           }
                                           if(error){
                                               NSLog(@"DataManager.downloadFromParse(%@):: Erroooo: %@", className, error);
                                           }else{
                                               NSLog(@"DataManager.downloadFromParse(%@):: Não deu erro", className);
                                           }
                                       }];
            }
        }];
    }else{
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        if (error) {
            NSLog(@"DataManager.downloadFromParse(%@):: Erro: %@", className, error);
        }else{
            if (objs.count > 0) {
#ifdef DEBUG
                NSLog(@"DataManager.downloadFromParse(%@):: %ld gallery baixados AGORA", className, objs.count);
#endif
                [PFObject pinAll:objs error:&error];
            }else{
                NSLog(@"DataManager.downloadFromParse(%@):: Nenhum objeto", className);
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
            NSLog(@"DataManager.downloadFromParse(%@):: Para utilizar a galeria tem que setar o usuario animal!", className);
            return;
        }
    }
    
    if (!inBackground) {
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        for (PFObject *o in objs) {
            [o unpin:&error];
            if (error) {
                NSLog(@"DataManager.deleteAll(%@):: Erro: %@", className, error);
            }else{
            }
        }
    }else{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error){
                NSLog(@"DataManager.deleteAll(%@):: Erro: %@", className, error);
            }else{
            }
            if (objects.count > 0) {
#ifdef DEBUG
                NSLog(@"DataManager.deleteAll(%@) %lu %@ encontrados para excluir", className, (unsigned long)objects.count, className);
#endif
                for (PFObject *o in objects) {
                    [o unpinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            
                        }else{
                            NSLog(@"DataManager.deleteAll(%@) Sem sucesso", className);
                        }
                        
                        if (error) {
                            NSLog(@"DataManager.deleteAll(%@) Erro\n%@", className, error);
                        }else{
                            
                        }
                    }];
                }
            }else{
                NSLog(@"DataManager.deleteAll(%@) Nenhum objeto", className);
            }
        }];
    }
}

@end
