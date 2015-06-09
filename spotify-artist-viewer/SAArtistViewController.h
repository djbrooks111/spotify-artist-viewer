//
//  SAArtistViewController.h
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/9/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAArtist.h"

@interface SAArtistViewController : UIViewController

- (instancetype)initWithArtist:(SAArtist *)artist;

@end
