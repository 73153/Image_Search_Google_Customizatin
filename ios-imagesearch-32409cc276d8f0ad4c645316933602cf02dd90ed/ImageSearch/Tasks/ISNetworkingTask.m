//
//  ISNetworkingTask.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISNetworkingTask.h"

@implementation ISNetworkingTask

- (void)requestJsonWithMethod:(NSString *)method
                    URLString:(NSString *)URLString
                   parameters:(id)parameters
            completionHandler:(void (^)(NSURLResponse *response,
                                        id responseObject,
                                        NSError *error))completionHandler
{
    
    if (DEBUG) ISLog(@"Invoking %@ method: %@ with params: %@", method, URLString, parameters);
    
    NSMutableURLRequest *jsonRequest = [[AFJSONRequestSerializer serializer] requestWithMethod:method
                                                                                     URLString:URLString
                                                                                    parameters:parameters
                                                                                         error:nil];
    
    self.urlSessionDataTask = [[AFHTTPSessionManager new] dataTaskWithRequest:jsonRequest
                                                            completionHandler:^(NSURLResponse *response,
                                                                                id responseObject,
                                                                                NSError *error) {
                                                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                    if (error) {
                                                                        if (DEBUG) ISLog(@"Error > error:%@ | response:%@", error, response);
                                                                    } else {
                                                                        if (DEBUG) ISLog(@"Raw response > responseObject:%@ | response:%@", responseObject, response);
                                                                    }
                                                                    completionHandler(response, responseObject, error);
                                                                });
                                                            }];
    [self.urlSessionDataTask resume];
}

@end
