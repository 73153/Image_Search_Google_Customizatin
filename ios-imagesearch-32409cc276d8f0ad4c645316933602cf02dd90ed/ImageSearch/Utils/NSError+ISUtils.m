//
//  NSError+ISUtils.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "NSError+ISUtils.h"

@implementation NSError (ISUtils)

- (NSString *)is_localizedDescription {
    NSString *localizedDescription = nil;
    if (self.code == kCFURLErrorTimedOut ||
        self.code == kCFURLErrorCannotFindHost ||
        self.code == kCFURLErrorCannotConnectToHost ||
        self.code == kCFURLErrorNetworkConnectionLost ||
        self.code == kCFURLErrorNotConnectedToInternet)
    {
        localizedDescription = NSLocalizedString(@"error__no_network", nil);
    }
    else if (self.localizedDescription && self.localizedDescription.length > 0)
    {
        localizedDescription = self.localizedDescription;
    }
    if (localizedDescription)
    {
        if (self.localizedRecoverySuggestion ||
            self.localizedFailureReason) {
            return [NSString stringWithFormat:@"%@ %@", localizedDescription, self.localizedRecoverySuggestion ? self.localizedRecoverySuggestion : self.localizedFailureReason];
        }
        else
        {
            return localizedDescription;
        }
    }
    else
    {
        return NSLocalizedString(@"error__generic", nil);
    }
}

@end
