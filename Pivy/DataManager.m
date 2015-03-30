//
//  DataManager.m
//  Pivy
//
//  Created by Henrique Valcanaia on 3/30/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "DataManager.h"

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
                    NSLog(@"ERRO\n%@", error);
                }else{
                    if (object) {
                        date = object.createdAt;
#ifdef DEBUG
                        NSLog(@"Objeto encontrado, baixando a partir de %@", date);
#endif
                    }else{
                        date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                        NSLog(@"Objeto NAO encontrado, baixando a partir de %@", date);
#endif
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
                    });
                }
            }];
        }else{
            NSError *error;
            PFObject *object = [[[query fromLocalDatastore] orderByDescending:@"createdAt"] getFirstObject:&error];
            if (error) {
                NSLog(@"Erro\n%@", error);
            }else{
                NSDate *date;
                if (object) {
                    date = object.createdAt;
#ifdef DEBUG
                    NSLog(@"Objeto encontrado, baixando a partir de %@", date);
#endif
                }else{
                    date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
#ifdef DEBUG
                    NSLog(@"Objeto NAO encontrado, baixando a partir de %@", date);
#endif
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DataManager downloadFromParse:className afterDate:date inBackground:inBackground];
                });
            }
        }
    }else{
        NSLog(@"Sem internet!");
    }
}

+ (void) downloadFromParse:(NSString*) className afterDate:(NSDate*)date inBackground:(BOOL)inBackground{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"createdAt" greaterThan:date];
    if([className isEqualToString:[Gallery parseClassName]])
        [query whereKey:@"to" equalTo:[PFUser currentUser]];
    
    if (inBackground) {
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
    }else{
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        if (error) {
            NSLog(@"Erro!\n%@", error);
        }else{
            if (objs) {
#ifdef DEBUG
                NSLog(@"\n%ld gallery baixados AGORA", objs.count);
#endif
                [PFObject pinAll:objs error:&error];
            }else{
                NSLog(@"Nenhum objeto");
            }
        }
    }
}

+ (void) deleteAll:(NSString*) className{
    [DataManager deleteAll:className inBackground:NO];
}

+ (void) deleteAll:(NSString*) className inBackground:(BOOL)inBackground{
#ifdef DEBUG
    NSInteger __block count = 0;
#endif
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query fromLocalDatastore];
    if (inBackground) {
        NSError *error;
        NSArray *objs = [query findObjects:&error];
        for (PFObject *o in objs) {
#ifdef DEBUG
            count++;
#endif
            [o unpin:&error];
            if (error) {
                NSLog(@"Erro\n%@", error);
            }else{
            }
        }
    }else{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error){
                NSLog(@"Erro");
            }else{
                if (objects) {
                    for (PFObject *o in objects) {
#ifdef DEBUG
                        count++;
#endif
                        
                        [o unpinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                
                            }else{
                                NSLog(@"Sem sucesso");
                            }
                            
                            if (error) {
                                NSLog(@"Erro\n%@", error);
                            }else{
                                
                            }
                        }];
                    }
                }else{
                    NSLog(@"Nenhum objeto");
                }
            }
        }];
        
#ifdef DEBUG
        NSLog(@"Objetos excluidos: %ld", (long)count);
#endif
        
    }
}

@end
