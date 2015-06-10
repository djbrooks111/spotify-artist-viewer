//
//  SAAlbum.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAAlbum.h"

@implementation SAAlbum

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andAvailableMarkets:(NSArray *)availableMarkets {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageUrl = imageUrl;
        self.availableMarkets = availableMarkets;
    }
    return self;
}

@end
