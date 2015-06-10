//
//  SAArtist.m
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAArtist.h"

@implementation SAArtist

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andBio:(NSString *)bio {
    if (self == [super init]) {
        self.name = name;
        self.imageUrl = imageUrl;
        self.bio = bio;
    }
    return self;
}

@end
