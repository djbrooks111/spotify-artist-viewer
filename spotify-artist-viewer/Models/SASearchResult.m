//
//  SASearchResult.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SASearchResult.h"

@implementation SASearchResult

- (instancetype)initWithName:(NSString *)name searchResultType:(SearchResultType)resultType identifier:(NSString *)identifier andImageUrl:(NSString *)imageUrl {
    self = [super init];
    if (self) {
        self.name = name;
        self.resultType = resultType;
        self.identifier = identifier;
        self.imageUrl = imageUrl;
    }
    return self;
}

@end
