//
//  SAArtist.m
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAArtist.h"

@implementation SAArtist

- (instancetype)initWithName:(NSString *)name image:(UIImage *)image andBio:(NSString *)bio {
    if (self == [super init]) {
        self.name = name;
        self.image = image;
        self.bio = bio;
    }
    return self;
}

@end
