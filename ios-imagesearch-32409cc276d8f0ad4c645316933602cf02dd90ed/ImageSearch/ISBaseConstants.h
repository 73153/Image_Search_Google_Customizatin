//
//  ISBaseConstants.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#ifndef ImageSearch_ISBaseConstants_h
#define ImageSearch_ISBaseConstants_h

//Logging
#define ISLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define ISCoreDataModelMajorVersion 1
#define ISCoreDataFileNameFormat @"ImageSearch_v%d.sqlite"
#define ISErrorDomain @"com.sebng.ImageSearch"
#define ISSearchHistoryFetchBatchSize 30
#define ISGoogleImageSearchMaxStart 60

#endif
