//
//  ISGoogleImageSearchAPITask.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISNetworkingTask.h"
#import "ISGoogleImageSearchAPIResponse.h"

@interface ISGoogleImageSearchAPITask : ISNetworkingTask

- (void)requestWithQuery:(NSString *)query
                   start:(NSInteger)start
       completionHandler:(void (^)(NSURLResponse *response,
                                   ISGoogleImageSearchAPIResponse *responseObject,
                                   NSError *error))completionHandler;

@end
