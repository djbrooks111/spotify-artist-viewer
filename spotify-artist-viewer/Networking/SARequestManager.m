//
//  SARequestManager.m
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SARequestManager.h"
#import <UIKit/UIKit.h>

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
        NSURL *imageUrl = [NSURL URLWithString:[[imagesArray objectAtIndex:1] objectForKey:@"url"]];
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
            success([[SAArtist alloc] initWithName:[artistDictionary objectForKey:@"name"] image:artistImage andBio:bioText]);
        } else {
            NSLog(@"Error getting bio text");
        }
    }];
    [bioQuery resume];
}

@end
