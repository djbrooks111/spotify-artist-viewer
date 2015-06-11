//
//  SAAlbum.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAAlbum.h"

@implementation SAAlbum

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andTracks:(NSArray *)tracks {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageUrl = imageUrl;
        self.tracks = tracks;
    }
    return self;
}

@end
