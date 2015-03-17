//
//  ISGoogleImageSearchAPIResponse.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISGoogleImageSearchAPIResponse.h"

#define ISGoogleImageSearchAPIResponseKeyResponseStatus @"responseStatus"
#define ISGoogleImageSearchAPIResponseKeyResponseData @"responseData"
#define ISGoogleImageSearchAPIResponseKeyResults @"results"
#define ISGoogleImageSearchAPIResponseKeyCursor @"cursor"
#define ISGoogleImageSearchAPIResponseKeyEstimatedResultCount @"estimatedResultCount"

#define ISGoogleImageSearchAPIResponseValueResponseStatusOK 200
#define ISGoogleImageSearchAPIResponseValueResponseStatusForbidden 403

@implementation ISGoogleImageSearchAPIResponse

- (instancetype)initWithRawAPIResponse:(id)apiResponse {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
        id valueForResponseValueResponseStatus = [apiResponse objectForKey:ISGoogleImageSearchAPIResponseKeyResponseStatus];
        if (valueForResponseValueResponseStatus != nil) {
            self.responseStatus = [valueForResponseValueResponseStatus integerValue];
            if ([self isValid]) {
                id valueForResponseValueResponseData = [apiResponse objectForKey:ISGoogleImageSearchAPIResponseKeyResponseData];
                if (valueForResponseValueResponseData != nil) {
                    id valueForResponseValueResponseResults = [valueForResponseValueResponseData objectForKey:ISGoogleImageSearchAPIResponseKeyResults];
                    if (valueForResponseValueResponseResults != nil &&
                        [valueForResponseValueResponseResults isKindOfClass:[NSArray class]]) {
                        [self setResults:valueForResponseValueResponseResults];
                    }
                    id valueForResponseValueResponseCursor = [valueForResponseValueResponseData objectForKey:ISGoogleImageSearchAPIResponseKeyCursor];
                    if (valueForResponseValueResponseCursor != nil) {
                        id valueForResponseValueResponseEstimatedResultCount = [valueForResponseValueResponseCursor objectForKey:ISGoogleImageSearchAPIResponseKeyEstimatedResultCount];
                        if (valueForResponseValueResponseEstimatedResultCount != nil) {
                            [self setEstimatedResultCount:[valueForResponseValueResponseEstimatedResultCount integerValue]];
                        }
                    }
                }
            }
        }
    }
    
    return self;
}

- (BOOL)isValid {
    return self.responseStatus == ISGoogleImageSearchAPIResponseValueResponseStatusOK;
}

- (BOOL)isBlocked {
    return self.responseStatus == ISGoogleImageSearchAPIResponseValueResponseStatusForbidden;
}

- (NSDictionary *)toDict
{
    NSDictionary *dict = [[super toDict] mutableCopy];
    [dict setValue:[NSNumber numberWithInteger:self.estimatedResultCount]
            forKey:ISGoogleImageSearchAPIResponseKeyEstimatedResultCount];
    [dict setValue:self.results
            forKey:ISGoogleImageSearchAPIResponseKeyResults];
    return dict;
}

@end
