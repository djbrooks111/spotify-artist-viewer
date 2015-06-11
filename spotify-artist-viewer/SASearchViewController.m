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

#define SEARCH_LIMIT 7

@interface SASearchViewController () <UISearchBarDelegate,  UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (nonatomic) NSArray *resultsArray;
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
    return [self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.resultsTableView.hidden = NO;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.tintColor = [UIColor oliveColor];
    SASearchResult *searchResult = [self.resultsArray objectAtIndex:indexPath.row];
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
    [self.requestManager getItemInformationFromSearchResult:[self.resultsArray objectAtIndex:indexPath.row] success:^(id item) {
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *query = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@*&type=artist,album,track&limit=%d", [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"], SEARCH_LIMIT];
    [self.requestManager executeQuery:query success:^(NSArray *searchResults) {
        self.resultsArray = nil;
        self.resultsArray = searchResults;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        NSLog(@"Failed to execute %@: %@", query, error);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view resignFirstResponder];
}

@end
