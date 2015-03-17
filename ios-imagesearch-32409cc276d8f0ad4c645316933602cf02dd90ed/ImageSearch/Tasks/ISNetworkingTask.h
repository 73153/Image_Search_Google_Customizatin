//
//  ISNetworkingTask.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define LMNetworkingHTTPMethodGET @"GET"
#define LMNetworkingHTTPMethodPOST @"POST"

@interface ISNetworkingTask : NSObject

- (void)requestJsonWithMethod:(NSString *)method
                    URLString:(NSString *)URLString
                   parameters:(id)parameters
            completionHandler:(void (^)(NSURLResponse *response,
                                        id responseObject,
                                        NSError *error))completionHandler;

@property (strong, nonatomic) NSURLSessionDataTask * urlSessionDataTask;

@end
