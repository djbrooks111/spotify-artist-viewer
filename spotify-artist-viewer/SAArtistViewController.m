//
//  SAArtistViewController.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/9/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAArtistViewController.h"
#import "SAArtist.h"
#import "SAAlbum.h"
#import "SATrack.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define IMAGE_BORDER_WIDTH 3.0f
#define IMAGE_CORNER_RADIUS 10.0f

@interface SAArtistViewController ()
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) id item;

@end

@implementation SAArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.item isKindOfClass:[SAArtist class]]) {
        // item is an artist
        SAArtist *artist = (SAArtist *)self.item;
        self.artistNameLabel.text = artist.name;
        [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:artist.imageUrl]];
        self.bioTextView.text = artist.bio;
    } else if ([self.item isKindOfClass:[SAAlbum class]]) {
        // item is an album
        SAAlbum *album = (SAAlbum *)self.item;
        self.artistNameLabel.text = album.name;
        [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:album.imageUrl]];
        NSString *marketString = [album.availableMarkets componentsJoinedByString:@"\n- "];
        self.bioTextView.text = [NSString stringWithFormat:@"This album is availble in the following markets:\n- %@", marketString];
    } else if ([self.item isKindOfClass:[SATrack class]]) {
        // item is a track
        SATrack *track = (SATrack *)self.item;
        self.artistNameLabel.text = track.name;
        [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:track.imageUrl]];
        self.bioTextView.text = [NSString stringWithFormat:@"Artist: %@", track.artist];
    }
    self.artistImageView.layer.borderWidth = IMAGE_BORDER_WIDTH;
    self.artistImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.artistImageView.layer.cornerRadius = IMAGE_CORNER_RADIUS;
    self.artistImageView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithItem:(id)item {
    self = [super init];
    if (self) {
        self.item = item;
    }
    return self;
}

- (IBAction)touchUpBackButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
