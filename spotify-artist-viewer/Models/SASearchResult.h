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

// Optional data
@property (nonatomic) NSArray *availableMarkets;
@property (nonatomic) NSString *trackArtist;

- (instancetype)initWithName:(NSString *)name searchResultType:(SearchResultType)resultType andIdentifier:(NSString *)identifier;

@end
