//
//  SATrack.h
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/10/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SATrack : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSInteger duration;


- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andArtist:(NSString *)artist;

@end
