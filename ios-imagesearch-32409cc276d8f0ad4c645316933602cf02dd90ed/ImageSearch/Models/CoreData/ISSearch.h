//
//  ISSearch.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ISResult;

@interface ISSearch : NSManagedObject

@property (nonatomic, retain) NSNumber * estimatedResultCount;
@property (nonatomic, retain) NSString * phrase;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSOrderedSet *results;
@end

@interface ISSearch (CoreDataGeneratedAccessors)

- (void)insertObject:(ISResult *)value inResultsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromResultsAtIndex:(NSUInteger)idx;
- (void)insertResults:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeResultsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInResultsAtIndex:(NSUInteger)idx withObject:(ISResult *)value;
- (void)replaceResultsAtIndexes:(NSIndexSet *)indexes withResults:(NSArray *)values;
- (void)addResultsObject:(ISResult *)value;
- (void)removeResultsObject:(ISResult *)value;
- (void)addResults:(NSOrderedSet *)values;
- (void)removeResults:(NSOrderedSet *)values;
@end
