//
//  NSDate+ISUtils.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "NSDate+ISUtils.h"

@implementation NSDate (ISUtils)

- (NSInteger)is_unixTimestamp
{
    return [[NSNumber numberWithDouble:round([self timeIntervalSince1970])] integerValue];
}

@end
