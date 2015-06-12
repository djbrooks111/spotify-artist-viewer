//
//  SARequestManager.h
//  spotify-artist-viewer
//
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SASearchResult.h"

@interface SARequestManager : NSObject

+ (instancetype)sharedManager;

- (void)executeQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(void (^)(NSError *error))failure;

- (void)executePagingQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(void (^)(NSError *error))failure;

- (void)getItemInformationFromSearchResult:(SASearchResult *)searchResult success:(void (^)(id item))success failure:(void (^)(NSError *error))failure;

@end
