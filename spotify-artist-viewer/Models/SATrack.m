//
//  SATrack.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SATrack.h"

@implementation SATrack

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andArtist:(NSString *)artist {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageUrl = imageUrl;
        self.artist = artist;
    }
    return self;
}

@end
