//
//  ISGoogleImageSearchAPIResponse.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISObject.h"

#define ISAPIResponseErrorCodeInvalidResponse 1001

@interface ISGoogleImageSearchAPIResponse : ISObject

- (instancetype)initWithRawAPIResponse:(id)apiResponse;
- (BOOL)isValid;
- (BOOL)isBlocked;

@property (nonatomic) NSInteger responseStatus;
@property (nonatomic) NSInteger estimatedResultCount;
@property (nonatomic, strong) NSArray *results;

@end
