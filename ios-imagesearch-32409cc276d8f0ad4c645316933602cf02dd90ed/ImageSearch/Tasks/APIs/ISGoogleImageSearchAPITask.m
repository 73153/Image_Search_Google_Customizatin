//
//  ISGoogleImageSearchAPITask.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISGoogleImageSearchAPITask.h"
#import "AppDelegate.h"

#define ISGoogleImageSearchAPIURL @"https://ajax.googleapis.com/ajax/services/search/images"

#define ISGoogleImageSearchAPIParamKeyVersion @"v"
#define ISGoogleImageSearchAPIParamKeyQuery @"q"
#define ISGoogleImageSearchAPIParamKeyStart @"start"
#define ISGoogleImageSearchAPIParamValueVersion @"1.0"

@implementation ISGoogleImageSearchAPITask

- (void)requestWithQuery:(NSString *)query
                   start:(NSInteger)start
       completionHandler:(void (^)(NSURLResponse *response,
                                   ISGoogleImageSearchAPIResponse *responseObject,
                                   NSError *error))completionHandler {
    [self requestJsonWithMethod:LMNetworkingHTTPMethodGET
                      URLString:ISGoogleImageSearchAPIURL
                     parameters:@{ISGoogleImageSearchAPIParamKeyVersion: ISGoogleImageSearchAPIParamValueVersion,
                                  ISGoogleImageSearchAPIParamKeyQuery: query,
                                  ISGoogleImageSearchAPIParamKeyStart: [NSNumber numberWithInteger:start]}
              completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                  if (error) {
                      completionHandler(response, nil, error);
                  } else if (![responseObject isKindOfClass:[NSDictionary class]]) {
                      completionHandler(response, nil, [[NSError alloc] initWithDomain:ISErrorDomain
                                                                                  code:ISAPIResponseErrorCodeInvalidResponse
                                                                              userInfo:nil]);
                  } else {
                      completionHandler(response, [[ISGoogleImageSearchAPIResponse alloc] initWithRawAPIResponse:responseObject], nil);
                  }
              }];
}

@end
