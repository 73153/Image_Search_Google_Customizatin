//
//  ISResultsViewController.h
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ISResultsViewController : UICollectionViewController

@property (strong, nonatomic) NSManagedObjectID *searchObjectID;
@property (weak, nonatomic) IBOutlet UILabel *labelEmpty;

@end
