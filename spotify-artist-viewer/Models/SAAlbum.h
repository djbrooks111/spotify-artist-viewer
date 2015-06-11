//
//  SAAlbum.h
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAAlbum : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSArray *tracks;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *popularity;


- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andTracks:(NSArray *)tracks;

@end
