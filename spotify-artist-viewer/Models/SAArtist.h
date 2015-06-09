//
//  SAArtist.h
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SAArtist : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *bio;

- (instancetype)initWithName:(NSString *)name image:(UIImage *)image andBio:(NSString *)bio;

@end
