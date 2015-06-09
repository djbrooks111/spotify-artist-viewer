//
//  SARequestManager.h
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAArtist.h"

@interface SARequestManager : NSObject

+ (instancetype)sharedManager;

- (void)getArtistsWithQuery:(NSString *)query
                    success:(void (^)(NSArray *artists))success
                    failure:(void (^)(NSError *error))failure;

- (void)getArtistInformationWithDictionary:(NSDictionary *)simpleArtist
                             success:(void (^)(SAArtist *artist))success
                             failure:(void (^)(NSError *error))failure;

@end
