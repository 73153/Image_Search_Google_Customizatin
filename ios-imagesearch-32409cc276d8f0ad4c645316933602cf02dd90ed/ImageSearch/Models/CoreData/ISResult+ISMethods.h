//
//  ISResult+ISMethods.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISResult.h"

#define ISEntityNameForISResult @"ISResult"

@interface ISResult (ISMethods)

+ (instancetype)findByImageId:(NSString *)imageId
       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        error:(NSError **)error;

+ (instancetype)insertWithAPIData:(NSDictionary *)apiData
                           search:(ISSearch *)search
           inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            error:(NSError **)error;
- (BOOL)isValid;

@end
