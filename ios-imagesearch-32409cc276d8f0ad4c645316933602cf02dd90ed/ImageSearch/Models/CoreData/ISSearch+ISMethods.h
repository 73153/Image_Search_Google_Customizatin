//
//  ISSearch+ISMethods.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISSearch.h"

#define ISEntityNameForISSearch @"ISSearch"

@interface ISSearch (ISMethods)

+ (instancetype)findByPhrase:(NSString *)phrase
      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       error:(NSError **)error;

+ (instancetype)insertWithPhrase:(NSString *)phrase
          inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                           error:(NSError **)error;

- (BOOL)isValid;

@end
