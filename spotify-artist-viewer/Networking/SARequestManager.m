//
//  SARequestManager.m
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SARequestManager.h"
#import <UIKit/UIKit.h>
#import "SAAlbum.h"
#import "SAArtist.h"
#import "SATrack.h"

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
        NSString *imageUrl = [[[itemDictionary objectForKey:@"images"] firstObject] objectForKey:@"url"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultAlbum identifier:identifer andImageUrl:imageUrl];
        searchResult.popularity = [itemDictionary objectForKey:@"popularity"];
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

- (NSArray *)extractArtistsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDictionary in [dictionary objectForKey:@"items"]) {
        NSString *identifer = [itemDictionary objectForKey:@"id"];
        NSString *name = [itemDictionary objectForKey:@"name"];
        NSString *imageUrl = [[[itemDictionary objectForKey:@"images"] firstObject] objectForKey:@"url"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultArtist identifier:identifer andImageUrl:imageUrl];
        searchResult.popularity = [itemDictionary objectForKey:@"popularity"];
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

- (NSArray *)extractTracksFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDictionary in [dictionary objectForKey:@"items"]) {
        NSString *identifer = [itemDictionary objectForKey:@"id"];
        NSString *name = [itemDictionary objectForKey:@"name"];
        NSString *imageUrl = [[[[itemDictionary objectForKey:@"album"] objectForKey:@"images"] firstObject] objectForKey:@"url"];
        SASearchResult *searchResult = [[SASearchResult alloc] initWithName:name searchResultType:SearchResultTrack identifier:identifer andImageUrl:imageUrl];
        searchResult.trackArtist = [[[itemDictionary objectForKey:@"artists"] firstObject] objectForKey:@"name"];
        NSInteger duration = [[itemDictionary objectForKey:@"duration_ms"] integerValue];
        searchResult.duration = duration;
        [returnArray addObject:searchResult];
    }
    return returnArray;
}

#pragma mark - Item Detail View

- (void)getItemInformationFromSearchResult:(SASearchResult *)searchResult success:(void (^)(id item))success failure:(void (^)(NSError *error))failure {
    switch (searchResult.resultType) {
        case SearchResultAlbum: {
            [self getAlbumInformation:searchResult success:success];
            break;
        }
        case SearchResultArtist: {
            [self getArtistInformation:searchResult success:success];
            break;
        }
        case SearchResultTrack: {
            [self getTrackInformation:searchResult success:success];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)getAlbumInformation:(SASearchResult *)searchResult success:(void (^)(id))success {
    NSURL *tracksUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@/tracks", searchResult.identifier]];
    NSURLSessionDataTask *tracksQuery = [[NSURLSession sharedSession] dataTaskWithURL:tracksUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            NSMutableArray *tracks = [[NSMutableArray alloc] init];
            NSDictionary *itemsDictionary = [jsonDictionary objectForKey:@"items"];
            for (NSDictionary *item in itemsDictionary) {
                [tracks addObject:[item objectForKey:@"name"]];
            }
            [self getAlbumPopularity:searchResult success:success tracks:tracks];
        } else {
            NSLog(@"Error getting tracks");
        }
    }];
    [tracksQuery resume];
}

- (void)getAlbumPopularity:(SASearchResult *)searchResult success:(void (^)(id))success tracks:(NSMutableArray *)tracks {
    NSURL *albumUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@", searchResult.identifier]];
    NSURLSessionDataTask *albumQuery = [[NSURLSession sharedSession] dataTaskWithURL:albumUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            NSString *popularity = [jsonDictionary objectForKey:@"popularity"];
            SAAlbum *album = [[SAAlbum alloc] initWithName:searchResult.name imageUrl:searchResult.imageUrl andTracks:[tracks copy]];
            album.identifier = searchResult.identifier;
            album.popularity = popularity;
            success(album);
        } else {
            NSLog(@"Error getting album popularity");
        }
    }];
    [albumQuery resume];
}

- (void)getArtistInformation:(SASearchResult *)searchResult success:(void (^)(id))success {
    // Need to get the artist's bio
    NSURL *echonestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/biographies?api_key=%@&id=spotify:artist:%@", ECHONEST_API_KEY, searchResult.identifier]];
    NSURLSessionDataTask *bioQuery = [[NSURLSession sharedSession] dataTaskWithURL:echonestUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            NSString *bioText = [[[[jsonDictionary objectForKey:@"response"] objectForKey:@"biographies"] objectAtIndex:1] objectForKey:@"text"];
            SAArtist *artist = [[SAArtist alloc] initWithName:searchResult.name imageUrl:searchResult.imageUrl andBio:bioText];
            artist.identifier = searchResult.identifier;
            artist.popularity = searchResult.popularity;
            success(artist);
        } else {
            NSLog(@"Error getting bio text");
        }
    }];
    [bioQuery resume];
}

- (void)getTrackInformation:(SASearchResult *)searchResult success:(void (^)(id))success {
    SATrack *track = [[SATrack alloc] initWithName:searchResult.name imageUrl:searchResult.imageUrl andArtist:searchResult.trackArtist];
    track.identifier = searchResult.identifier;
    track.duration = searchResult.duration;
    success(track);
}

@end
