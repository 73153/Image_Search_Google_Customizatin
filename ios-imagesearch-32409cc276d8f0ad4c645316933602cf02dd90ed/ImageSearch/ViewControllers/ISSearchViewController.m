//
//  ISSearchViewController.m
//  ImageSearch
//
//  Created by Sebastian Ng on 2/9/15.
//  Copyright (c) 2015 Sebastian Ng. All rights reserved.
//

#import "ISSearchViewController.h"
#import <CoreData/CoreData.h>
#import "ISSearch+ISMethods.h"
#import "AppDelegate.h"
#import "NSError+ISUtils.h"
#import "UIAlertView+Blocks.h"
#import "ISResultsViewController.h"

@interface ISSearchViewController ()

- (void)reloadTableDataForRecentSearches;
- (void)updateFetchedResultsControllerForFilteredSearches:(NSString *)searchPhrase;
- (void)updateViews;
- (void)searchPhrase:(NSString *)phrase;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForRecentSearches;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForFilteredSearches;
@property (strong, nonatomic) NSManagedObjectID *mostRecentSearchObjectID;

@end

@implementation ISSearchViewController

static NSString * const ISCacheNameForRecentSearches = @"ISCacheNameForRecentSearches";
static NSString * const ISCacheNameForFilteredSearches = @"ISCacheNameForFilteredSearches";
static NSString * const ISTableViewCellIdentiferRecentSearch = @"recent_search";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
    // Register cell classes
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class]
                                                forCellReuseIdentifier:ISTableViewCellIdentiferRecentSearch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.navigationController.navigationBar isTranslucent]) [self.navigationController.navigationBar setTranslucent:YES];
    
    [self reloadTableDataForRecentSearches];
    
    if (self.searchDisplayController.searchBar.text.length > 0) {
        [self updateFetchedResultsControllerForFilteredSearches:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableDataForRecentSearches {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [NSFetchedResultsController deleteCacheWithName:ISCacheNameForRecentSearches];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ISEntityNameForISSearch];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:ISSearchHistoryFetchBatchSize];
    
    self.fetchedResultsControllerForRecentSearches = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                         managedObjectContext:appDelegate.managedObjectContext
                                                                                           sectionNameKeyPath:nil
                                                                                                    cacheName:ISCacheNameForRecentSearches];
    NSError *fetchError;
    if (![self.fetchedResultsControllerForRecentSearches performFetch:&fetchError])
    {
        if (DEBUG) ISLog(@"fetchedResultsControllerForRecentSearches > NSError:%@", fetchError);
        [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                           message:[fetchError is_localizedDescription]
                 cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
    [self.tableView reloadData];
    
    [self updateViews];
}

- (void)updateFetchedResultsControllerForFilteredSearches:(NSString *)searchPhrase {
    if (searchPhrase == nil || searchPhrase.length == 0) {
        self.fetchedResultsControllerForFilteredSearches = nil;
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [NSFetchedResultsController deleteCacheWithName:ISCacheNameForFilteredSearches];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ISEntityNameForISSearch];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phrase contains[cd] %@", searchPhrase];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:ISSearchHistoryFetchBatchSize];
    
    self.fetchedResultsControllerForFilteredSearches = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                           managedObjectContext:appDelegate.managedObjectContext
                                                                                             sectionNameKeyPath:nil
                                                                                                      cacheName:ISCacheNameForFilteredSearches];
    NSError *fetchError;
    if (![self.fetchedResultsControllerForFilteredSearches performFetch:&fetchError])
    {
        if (DEBUG) ISLog(@"fetchedResultsControllerForRecentSearches > NSError:%@", fetchError);
        [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                           message:[fetchError is_localizedDescription]
                 cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

- (void)updateViews {
    self.tableView.tableHeaderView = self.fetchedResultsControllerForRecentSearches.fetchedObjects.count > 0 ? nil : self.viewEmpty;
}

- (void)searchPhrase:(NSString *)phrase {
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSError *coreDataError;
        ISSearch *search = [ISSearch insertWithPhrase:phrase
                               inManagedObjectContext:appDelegate.managedObjectContext
                                                error:&coreDataError];
        if (coreDataError == nil)
        {
            [appDelegate.managedObjectContext save:&coreDataError];
        }
        if (coreDataError != nil) {
            if (DEBUG) ISLog(@"CoreData > Insert search > coreDataError:%@", coreDataError);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView showWithTitle:NSLocalizedString(@"error__generic__alert_title", nil)
                                   message:[coreDataError is_localizedDescription]
                         cancelButtonTitle:NSLocalizedString(@"common__btn_dismiss", nil)
                         otherButtonTitles:nil
                                  tapBlock:nil];
            });
        } else {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.mostRecentSearchObjectID = search.objectID;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf performSegueWithIdentifier:@"SearchPhrase" sender:strongSelf];
            });
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        return self.fetchedResultsControllerForRecentSearches.fetchedObjects.count;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.fetchedResultsControllerForFilteredSearches.fetchedObjects.count;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView &&
        self.fetchedResultsControllerForRecentSearches.fetchedObjects.count > 0) {
        return NSLocalizedString(@"search__recent", nil);
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ISTableViewCellIdentiferRecentSearch forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    if (tableView == self.tableView) {
        ISSearch *search = [self.fetchedResultsControllerForRecentSearches objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        cell.textLabel.text = search.phrase;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        ISSearch *search = [self.fetchedResultsControllerForFilteredSearches objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        cell.textLabel.text = search.phrase;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        ISSearch *search = [self.fetchedResultsControllerForRecentSearches objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self searchPhrase:search.phrase];
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        ISSearch *search = [self.fetchedResultsControllerForFilteredSearches objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self searchPhrase:search.phrase];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchPhrase:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFetchedResultsControllerForFilteredSearches:searchString];
    return searchString.length > 0;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.fetchedResultsControllerForFilteredSearches = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.destinationViewController isMemberOfClass:[ISResultsViewController class]]) {
        ISResultsViewController *resultsViewController = segue.destinationViewController;
        if (self.mostRecentSearchObjectID)
        {
            [resultsViewController setSearchObjectID:self.mostRecentSearchObjectID];
            self.mostRecentSearchObjectID = nil;
        }
    }
}

@end
