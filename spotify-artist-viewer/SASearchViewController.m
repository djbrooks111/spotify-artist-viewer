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
@class SAArtist;

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

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.requestManager getArtistInformationWithDictionary:[self.resultsArray objectAtIndex:indexPath.row] success:^(SAArtist *artist) {
        [self artistPicked:artist];
    } failure:^(NSError *error) {
        NSLog(@"Failed to fetch %@'s information: %@", [self.resultsArray objectAtIndex:indexPath.row], error);
    }];
}

- (void)artistPicked:(SAArtist *)artist {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchBar.text = @"";
        self.resultsArray = nil;
        SAArtistViewController *vc = [[SAArtistViewController alloc] initWithItem:artist];
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *query = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@*&type=artist,album,track&limit=10", [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    [self.requestManager executeQuery:query success:^(NSArray *searchResults) {
        NSLog(@"results set");
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
