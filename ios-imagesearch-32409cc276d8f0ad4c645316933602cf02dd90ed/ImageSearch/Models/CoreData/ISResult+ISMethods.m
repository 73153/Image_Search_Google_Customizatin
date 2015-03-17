//
//  ISResult+ISMethods.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISResult+ISMethods.h"
#import "ISSearch+ISMethods.h"

#define ISResultResponseKeyImageId @"imageId"
#define ISResultResponseKeyTbUrl @"tbUrl"
#define ISResultResponseKeyTitle @"titleNoFormatting"
#define ISResultResponseKeyContent @"contentNoFormatting"

@implementation ISResult (ISMethods)

+ (instancetype)findByImageId:(NSString *)imageId
       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ISEntityNameForISResult
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageId == %@", imageId]];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:error];
    
    if(!*error &&
       fetchedObjects &&
       fetchedObjects.count > 0) {
        return [fetchedObjects firstObject];
    } else {
        return nil;
    }
}

+ (instancetype)insertWithAPIData:(NSDictionary *)apiData
                           search:(ISSearch *)search
           inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            error:(NSError **)error {
    if (!apiData ||
        !managedObjectContext ||
        !search ||
        ![search isValid]) {
        return nil;
    }
    
    id valueForResponseKeyImageId = [apiData objectForKey:ISResultResponseKeyImageId];
    if (valueForResponseKeyImageId &&
        ![valueForResponseKeyImageId isEqual:[NSNull null]]) {
        ISResult *result = [ISResult findByImageId:valueForResponseKeyImageId
                            inManagedObjectContext:managedObjectContext
                                             error:error];
        
        BOOL isNew = result == nil;
        
        if (isNew) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ISEntityNameForISResult
                                                                 inManagedObjectContext:managedObjectContext];
            result = (ISResult *)[[NSManagedObject alloc] initWithEntity:entityDescription
                                          insertIntoManagedObjectContext:managedObjectContext];
            [result setImageId:valueForResponseKeyImageId];
        }
        
        id valueForResponseKeyTbUrl = [apiData objectForKey:ISResultResponseKeyTbUrl];
        if (valueForResponseKeyTbUrl &&
            ![valueForResponseKeyTbUrl isEqual:[NSNull null]]) {
            if (isNew ||
                result.tbUrl == nil ||
                ![result.tbUrl isEqualToString:valueForResponseKeyTbUrl]) {
                [result setTbUrl:valueForResponseKeyTbUrl];
            }
        } else if (result.tbUrl != nil) {
            [result setTbUrl:nil];
        }
        
        id valueForResponseKeyTitle = [apiData objectForKey:ISResultResponseKeyTitle];
        if (valueForResponseKeyTitle &&
            ![valueForResponseKeyTitle isEqual:[NSNull null]]) {
            if (isNew ||
                result.title == nil ||
                ![result.title isEqualToString:valueForResponseKeyTitle]) {
                [result setTitle:valueForResponseKeyTitle];
            }
        } else if (result.title != nil) {
            [result setTitle:nil];
        }
        
        id valueForResponseKeyContent = [apiData objectForKey:ISResultResponseKeyContent];
        if (valueForResponseKeyContent &&
            ![valueForResponseKeyContent isEqual:[NSNull null]]) {
            [result setContent:valueForResponseKeyContent];
            if (isNew ||
                result.content == nil ||
                ![result.content isEqualToString:valueForResponseKeyContent]) {
                [result setContent:valueForResponseKeyContent];
            }
        } else if (result.content != nil) {
            [result setContent:nil];
        }
        
        if (isNew ||
            result.search == nil ||
            result.search.objectID != search.objectID) {
            [result setSearch:search];
        }
    }
    
    return nil;
}

- (BOOL)isValid {
    return self.imageId != nil && self.imageId.length > 0 && self.tbUrl != nil && self.tbUrl.length > 0;
}

@end
