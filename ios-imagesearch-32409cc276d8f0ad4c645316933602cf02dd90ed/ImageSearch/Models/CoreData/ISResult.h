//
//  ISResult.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ISSearch;

@interface ISResult : NSManagedObject

@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSString * tbUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) ISSearch *search;

@end
