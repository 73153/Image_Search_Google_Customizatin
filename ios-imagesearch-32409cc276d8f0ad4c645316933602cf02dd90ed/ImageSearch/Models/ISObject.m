//
//  ISObject.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISObject.h"

@implementation ISObject

- (NSDictionary *)toDict
{
    return @{};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", [super description], [self toDict]];
}

@end
