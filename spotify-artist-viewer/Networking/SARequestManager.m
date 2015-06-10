//
//  SARequestManager.m
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SARequestManager.h"
#import <UIKit/UIKit.h>
#import "SASearchResult.h"

#define ECHONEST_API_KEY @"6SMVCIMVWEQWVKFKW"

@implementation SARequestManager

+ (instancetype)sharedManager {
    static SARequestManager *sharedRequestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRequestManager = [[self alloc] init];
    });
    return sharedRequestManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Search Functionality

- (void)executeQuery:(NSString *)query success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:query];
    NSURLSessionDataTask *queryTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            // Successful fetch
            if (success) {
                // Safety net to not crash if !success
                [self parseQueryResultsFromData:data withSuccess:success];
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [queryTask resume];
}

- (void)parseQueryResultsFromData:(NSData *)data withSuccess:(void (^)(NSArray *))success {
    NSError *jsonError = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (!jsonError) {
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        NSArray *albums = [self extractAlbumsFromDictionary:[jsonDictionary objectForKey:@"albums"]];
        NSArray *artists = [self extractArtistsFromDictionary:[jsonDictionary objectForKey:@"artists"]];
        NSArray *tracks = [self extractTracksFromDictionary:[jsonDictionary objectForKey:@"tracks"]];
        NSInteger maxCount = [tracks count];
        if ([albums count] > [artists count] && [albums count] > [tracks count]) {
            maxCount = [albums count];
        } else if ([artists count] > [albums count] && [artists count] > [tracks count]) {
            maxCount = [artists count];
        }
        for (int i = 0; i < maxCount; i++) {
            if (i < [albums count]) {
                [returnArray addObject:[albums objectAtIndex:i]];
            }
            if (i < [artists count]) {
                [returnArray addObject:[artists objectAtIndex:i]];
            }
            if (i < [tracks count]) {
                [returnArray addObject:[tracks objectAtIndex:i]];
            }
        }
        success([returnArray copy]);
    } else {
        NSLog(@"Error parsing JSON");
    }
}

- (NSArray *)extractAlbumsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDictionary in [dictionary objectForKey:@"items"]) {
        NSString *identifer = [itemDictionary objectForKey:@"id"];
        NSString *name = [itemDictionary objectForKey:@"name"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultAlbum andIdentifier:identifer];
        searchResult.availableMarkets = [itemDictionary objectForKey:@"available_markets"];
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

- (NSArray *)extractArtistsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDictionary in [dictionary objectForKey:@"items"]) {
        NSString *identifer = [itemDictionary objectForKey:@"id"];
        NSString *name = [itemDictionary objectForKey:@"name"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultArtist andIdentifier:identifer];
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

- (NSArray *)extractTracksFromDictionary:(NSDictionary *)dictionary {
    NSLog(@"%@", dictionary);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDictionary in [dictionary objectForKey:@"items"]) {
        NSString *identifer = [itemDictionary objectForKey:@"id"];
        NSString *name = [itemDictionary objectForKey:@"name"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultTrack andIdentifier:identifer];
        searchResult.trackArtist = [[[itemDictionary objectForKey:@"artists"] firstObject] objectForKey:@"name"];
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

#pragma mark - Item Detail View

//- (void)getItemInformationFromSearchResult:(SASearchResult *)searchResult success:(void (^)()

#pragma mark - Methods From Master Branch
// These methods are not used in this branch

- (void)getArtistsWithQuery:(NSString *)query
                    success:(void (^)(NSArray *artists))success
                    failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:query];
    NSURLSessionDataTask *queryTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            // Successful fetch
            if (success) {
                [self extractArtistsFromData:data withSuccess:success];
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [queryTask resume];
}

- (void)extractArtistsFromData:(NSData *)data withSuccess:(void (^)(NSArray *artists))success {
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (!error) {
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        NSDictionary *artistDictionary = [jsonDictionary objectForKey:@"artists"];
        for (NSDictionary *itemDictionary in [artistDictionary objectForKey:@"items"]) {
            NSDictionary *simpleArtist = @{@"name" : [itemDictionary objectForKey:@"name"], @"id" : [itemDictionary objectForKey:@"id"]};
            [returnArray addObject:simpleArtist];
        }
        success([returnArray copy]);
    } else {
        NSLog(@"Error parsing JSON.");
    }
}

- (void)getArtistInformationWithDictionary:(NSDictionary *)simpleArtist
                             success:(void (^)(SAArtist *artist))success
                             failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/artists/%@", [simpleArtist objectForKey:@"id"]]];
    NSURLSessionDataTask *queryTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            // Successful fetch
            if (success) {
                [self extractArtistInformationFromData:data andArtistDictionary:simpleArtist withSuccess:success];
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [queryTask resume];
}

- (void)extractArtistInformationFromData:(NSData *)data andArtistDictionary:(NSDictionary *)artistDictionary withSuccess:(void (^)(SAArtist *artist))success {
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    __block UIImage *artistImage;
    if (!error) {
        NSArray *imagesArray = [jsonDictionary objectForKey:@"images"];
        NSURL *imageUrl = [NSURL URLWithString:[[imagesArray firstObject] objectForKey:@"url"]];
        NSURLSessionDownloadTask *downloadImageTask = [[NSURLSession sharedSession] downloadTaskWithURL:imageUrl completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            artistImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            [self getArtistBioWithDictionary:artistDictionary withSuccess:success andImage:artistImage];
        }];
        [downloadImageTask resume];
    }
}

- (void)getArtistBioWithDictionary:(NSDictionary *)artistDictionary withSuccess:(void (^)(SAArtist *artist))success andImage:(UIImage *)artistImage {
    NSURL *echonestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/biographies?api_key=%@&id=spotify:artist:%@", ECHONEST_API_KEY, [artistDictionary objectForKey:@"id"]]];
    NSURLSessionDataTask *bioQuery = [[NSURLSession sharedSession] dataTaskWithURL:echonestUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            NSString *bioText = [[[[jsonDictionary objectForKey:@"response"] objectForKey:@"biographies"] objectAtIndex:1] objectForKey:@"text"];
//            success([[SAArtist alloc] initWithName:[artistDictionary objectForKey:@"name"] image:artistImage andBio:bioText]);
        } else {
            NSLog(@"Error getting bio text");
        }
    }];
    [bioQuery resume];
}

@end
