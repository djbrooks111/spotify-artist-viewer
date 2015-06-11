//
//  SASearchResult.h
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SearchResultType) {
    SearchResultAlbum,
    SearchResultArtist,
    SearchResultTrack
};

@interface SASearchResult : NSObject

// Required data
@property (nonatomic) NSString *name;
@property (nonatomic) SearchResultType resultType;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *imageUrl;

// Optional data
@property (nonatomic) NSString *trackArtist;
@property (nonatomic) NSString *popularity;
@property (nonatomic) NSInteger duration;

- (instancetype)initWithName:(NSString *)name searchResultType:(SearchResultType)resultType identifier:(NSString *)identifier andImageUrl:(NSString *)imageUrl;

@end
