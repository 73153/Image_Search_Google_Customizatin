//
//  ISSearch+ISMethods.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISSearch+ISMethods.h"
#import "NSDate+ISUtils.h"

@implementation ISSearch (ISMethods)

+ (instancetype)findByPhrase:(NSString *)phrase
      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ISEntityNameForISSearch
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"phrase == %@", phrase]];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:error];
    
    if(!*error &&
       fetchedObjects &&
       fetchedObjects.count > 0)
    {
        return [fetchedObjects firstObject];
    } else {
        return nil;
    }
}

+ (instancetype)insertWithPhrase:(NSString *)phrase
          inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                           error:(NSError **)error {
    if (phrase == nil ||
        phrase.length == 0 ||
        !managedObjectContext) {
        return nil;
    }
    
    ISSearch *search = [ISSearch findByPhrase:phrase
                       inManagedObjectContext:managedObjectContext
                                        error:error];
    
    if(*error) {
        return nil;
    } else {
        BOOL isNew = search == nil;
        
        if (isNew)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ISEntityNameForISSearch
                                                                 inManagedObjectContext:managedObjectContext];
            search = (ISSearch *)[[NSManagedObject alloc] initWithEntity:entityDescription
                                          insertIntoManagedObjectContext:managedObjectContext];
            [search setPhrase:phrase];
        }
        
        [search setEstimatedResultCount:[NSNumber numberWithInteger:0]];
        [search setTimestamp:[NSNumber numberWithInteger:[[NSDate date] is_unixTimestamp]]];
        
        return search;
    }
}

- (BOOL)isValid {
    return self.phrase != nil && self.phrase.length > 0;
}

@end
