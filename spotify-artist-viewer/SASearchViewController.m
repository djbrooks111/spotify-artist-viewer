//
//  SASearchViewController.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/9/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SASearchViewController.h"
#import "SARequestManager.h"
#import "SAArtistViewController.h"
#import "SASearchResult.h"
#import "UIColor+SpotifyColors.h"

@interface SASearchViewController () <UISearchBarDelegate,  UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (nonatomic) NSArray *resultsArray;
@property (nonatomic) NSString *searchText;
@property (nonatomic) SARequestManager *requestManager;

@end

@implementation SASearchViewController

@synthesize resultsArray = _resultsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setting up delegates
    self.searchBar.delegate = self;
    self.resultsTableView.delegate = self;
    self.resultsTableView.dataSource = self;
    
    // Initially hiding the table view for a cleaner look
    self.resultsTableView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instantiation

- (NSArray *)resultsArray {
    if (!_resultsArray) {
        _resultsArray = [[NSArray alloc] init];
    }
    return _resultsArray;
}

- (void)setResultsArray:(NSArray *)resultsArray {
    _resultsArray = resultsArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resultsTableView reloadData];
    });
}

- (SARequestManager *)requestManager {
    if (!_requestManager) {
        _requestManager = [SARequestManager sharedManager];
    }
    return _requestManager;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.resultsTableView.hidden = NO;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.tintColor = [UIColor oliveColor];
    SASearchResult *searchResult = [self.resultsArray objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = searchResult.name;
    switch (searchResult.resultType) {
        case SearchResultAlbum: {
            cell.detailTextLabel.text = @"Album";
            break;
        }
        case SearchResultArtist: {
            cell.detailTextLabel.text = @"Artist";
            break;
        }
        case SearchResultTrack: {
            cell.detailTextLabel.text = @"Track";
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.requestManager getItemInformationFromSearchResult:[self.resultsArray objectAtIndex:(NSUInteger)indexPath.row] success:^(id item) {
        [self itemPicked:item];
    } failure:^(NSError *error) {
        NSLog(@"Failed to fetch information: %@", error);
    }];
}

- (void)itemPicked:(id)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchBar.text = @"";
        self.resultsArray = nil;
        self.resultsTableView.hidden = YES;
        SAArtistViewController *vc = [[SAArtistViewController alloc] initWithItem:item];
        [self presentViewController:vc animated:YES completion:^{
            self.view.hidden = YES;
        }];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        // Clear results array
        self.resultsTableView.hidden = YES;
        self.resultsArray = nil;
    } else {
        self.resultsTableView.hidden = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *query = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@*&type=artist,album,track", [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        self.searchText = searchText;
        [self.requestManager executeQuery:query success:^(NSArray *searchResults) {
            self.resultsArray = nil;
            self.resultsArray = searchResults;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } failure:^(NSError *error) {
            NSLog(@"Failed to execute %@: %@", query, error);
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height;
    CGFloat scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // End of the tableView, load new data
        NSString *query = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@*&type=artist,album,track", [self.searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        [self.requestManager executePagingQuery:query success:^(NSArray *searchResults) {
            self.resultsArray = [self.resultsArray arrayByAddingObjectsFromArray:searchResults];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } failure:^(NSError *error) {
            NSLog(@"Failed to execute %@: %@", query, error);
        }];
    }
}

@end
