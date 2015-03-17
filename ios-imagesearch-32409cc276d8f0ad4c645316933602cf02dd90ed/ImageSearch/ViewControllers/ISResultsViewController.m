//
//  ISResultsViewController.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISResultsViewController.h"
#import "AppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "NSError+ISUtils.h"
#import "ISSearch+ISMethods.h"
#import "ISResult+ISMethods.h"
#import "ISGoogleImageSearchAPITask.h"
#import "ISCollectionViewCellForResult.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVPullToRefresh.h"

@interface ISResultsViewController ()

- (void)fetchGoogleImageSearchResultsFromServer:(NSInteger)start
                                 deleteExisting:(BOOL)deleteExisting
                              completionHandler:(void (^)())completionHandler;

- (void)fetchGoogleImageSearchResultsFromServer:(NSInteger)start
                              completionHandler:(void (^)())completionHandler;

@property (strong, nonatomic) ISGoogleImageSearchAPITask *googleImageSearchAPITask;
@property (nonatomic) BOOL bIsLoading;

@end

@implementation ISResultsViewController

static NSString * const ISCacheNameForSearchResults = @"ISCacheNameForSearchResults";
static NSString * const ISCollectionViewCellIdentiferSearchResult = @"search_result";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    __weak __typeof(self) weakSelf = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:self.searchObjectID];
    if (search != nil) {
        self.title = search.phrase;
        
        if (search.results.count == 0 ||
            [search.estimatedResultCount integerValue] == 0) {
            self.bIsLoading = YES;
            [self.collectionView setShowsPullToRefresh:NO];
            [self fetchGoogleImageSearchResultsFromServer:0
                                        completionHandler:^{
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            strongSelf.bIsLoading = NO;
                                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                            ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:strongSelf.searchObjectID];
                                            [strongSelf.labelEmpty setHidden:search.results.count > 0];
                                            [strongSelf.collectionView setShowsPullToRefresh:YES];
                                        }];
        }
    }
    
    // setup pull-to-refresh
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.collectionView addPullToRefreshWithActionHandler:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.bIsLoading = YES;
        if (!strongSelf.labelEmpty.hidden) [strongSelf.labelEmpty setHidden:YES];
        [strongSelf fetchGoogleImageSearchResultsFromServer:0
                                             deleteExisting:YES
                                          completionHandler:^{
                                              __strong __typeof(weakSelf) strongSelf = weakSelf;
                                              strongSelf.bIsLoading = NO;
                                              AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                              ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:strongSelf.searchObjectID];
                                              [strongSelf.labelEmpty setHidden:search.results.count > 0];
                                              [strongSelf.collectionView.pullToRefreshView stopAnimating];
                                    }];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.googleImageSearchAPITask &&
        self.googleImageSearchAPITask.urlSessionDataTask &&
        (self.googleImageSearchAPITask.urlSessionDataTask.state == NSURLSessionTaskStateRunning ||
         self.googleImageSearchAPITask.urlSessionDataTask.state == NSURLSessionTaskStateSuspended))
    {
        [self.googleImageSearchAPITask.urlSessionDataTask cancel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchGoogleImageSearchResultsFromServer:(NSInteger)start
                                 deleteExisting:(BOOL)deleteExisting
                              completionHandler:(void (^)())completionHandler {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:strongSelf.searchObjectID];
        strongSelf.googleImageSearchAPITask = [ISGoogleImageSearchAPITask new];
        [strongSelf.googleImageSearchAPITask requestWithQuery:search.phrase
                                                        start:start
                                            completionHandler:^(NSURLResponse *response,
                                                                ISGoogleImageSearchAPIResponse *responseObject,
                                                                NSError *error) {
                                                if (error != nil) {
                                                    if (DEBUG) ISLog(@"API > Error fetching Google Image Search results > error:%@ | response:%@", error, response);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        NSString *errorMessage = [error is_localizedDescription];
                                                        if (![errorMessage isEqualToString:@"cancelled"]) {
                                                            [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                                                                               message:errorMessage
                                                                     cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                                                                     otherButtonTitles:nil
                                                                              tapBlock:nil];
                                                        }
                                                        if (completionHandler) completionHandler();
                                                    });
                                                } else {
                                                    if (DEBUG) ISLog(@"API > Fetched Google Image Search results > responseObject:%@ | response:%@", responseObject, response);
                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                    if (![responseObject isValid]) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [UIAlertView showWithTitle:NSLocalizedString([responseObject isBlocked] ? @"results__rate_limiting" : @"error__generic__alert_title", nil)
                                                                               message:NSLocalizedString([responseObject isBlocked] ? @"results__rate_limited" : @"error__generic", nil)
                                                                     cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                                                                     otherButtonTitles:nil
                                                                              tapBlock:nil];
                                                            if (completionHandler) completionHandler();
                                                        });
                                                    }
                                                    else {
                                                        BOOL bHasChanged = NO;
                                                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                        ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:strongSelf.searchObjectID];
                                                        if ([responseObject estimatedResultCount] != 0 &&
                                                            [responseObject estimatedResultCount] != [search.estimatedResultCount integerValue]) {
                                                            search.estimatedResultCount = [NSNumber numberWithInteger:[responseObject estimatedResultCount]];
                                                            bHasChanged = YES;
                                                        }
                                                        NSError *coreDataError;
                                                        if (deleteExisting) {
                                                            for (ISResult *result in search.results) {
                                                                [appDelegate.managedObjectContext deleteObject:result];
                                                            }
                                                        }
                                                        if (responseObject.results != nil &&
                                                            responseObject.results.count > 0) {
                                                            //parse and store results in CoreData
                                                            for (id resultData in responseObject.results) {
                                                                [ISResult insertWithAPIData:resultData
                                                                                     search:search
                                                                     inManagedObjectContext:appDelegate.managedObjectContext
                                                                                      error:&coreDataError];
                                                                if (coreDataError != nil) {
                                                                    break;
                                                                }
                                                            }
                                                            bHasChanged = YES;
                                                        }
                                                        if (coreDataError != nil) {
                                                            if (DEBUG) ISLog(@"CoreData > Insert results > coreDataError:%@", coreDataError);
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                                                                                   message:[coreDataError is_localizedDescription]
                                                                         cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                                                                         otherButtonTitles:nil
                                                                                  tapBlock:nil];
                                                                if (completionHandler) completionHandler();
                                                            });
                                                        } else if (bHasChanged) {
                                                            [appDelegate.managedObjectContext save:&coreDataError];
                                                            if (coreDataError != nil) {
                                                                if (DEBUG) ISLog(@"CoreData > Saving results > coreDataError:%@", coreDataError);
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                                                                                       message:[coreDataError is_localizedDescription]
                                                                             cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                                                                             otherButtonTitles:nil
                                                                                      tapBlock:nil];
                                                                    if (completionHandler) completionHandler();
                                                                });
                                                            } else {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                    [strongSelf.collectionView reloadData];
                                                                    if (completionHandler) completionHandler();
                                                                });
                                                            }
                                                        } else {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                if (completionHandler) completionHandler();
                                                            });
                                                        }
                                                    }
                                                }
                                            }];
    });
}


- (void)fetchGoogleImageSearchResultsFromServer:(NSInteger)start
                              completionHandler:(void (^)())completionHandler {
    [self fetchGoogleImageSearchResultsFromServer:start
                                   deleteExisting:NO
                                completionHandler:completionHandler];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:self.searchObjectID];
    return search.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ISCollectionViewCellForResult *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ISCollectionViewCellIdentiferSearchResult
                                                                                    forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [ISCollectionViewCellForResult new];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ISSearch *search = (ISSearch *)[appDelegate.managedObjectContext objectWithID:self.searchObjectID];
    if (search.results.count > [indexPath row]) {
        ISResult *result = [search.results objectAtIndex:[indexPath row]];
        
        [cell.imageViewThumbnail setHidden:NO];
        [cell.imageViewThumbnail sd_setImageWithURL:[NSURL URLWithString:result.tbUrl]
                                   placeholderImage:[UIImage imageNamed:@"ic_imagesearch"]];
        
        if (!self.bIsLoading &&
            [indexPath row] == search.results.count - 1 &&
            search.results.count <= ISGoogleImageSearchMaxStart &&
            search.results.count < [search.estimatedResultCount integerValue]) {
            
            self.bIsLoading = YES;
            [self.collectionView setShowsPullToRefresh:NO];
            __weak __typeof(self) weakSelf = self;
            [self fetchGoogleImageSearchResultsFromServer:search.results.count
                                        completionHandler:^{
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            strongSelf.bIsLoading = NO;
                                            [strongSelf.collectionView setShowsPullToRefresh:YES];
                                        }];
        }
    } else {
        [cell.imageViewThumbnail setHidden:YES];
    }
    
    return cell;
}

@end
