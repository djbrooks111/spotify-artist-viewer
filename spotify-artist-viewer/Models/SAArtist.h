//
//  SAArtist.h
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAArtist : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *bio;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *popularity;

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl andBio:(NSString *)bio;

@end
