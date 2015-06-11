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
#import "UIColor+SpotifyColors.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define IMAGE_BORDER_WIDTH 3.0f
#define IMAGE_CORNER_RADIUS 10.0f
#define BUTTON_BORDER_WIDTH 2.0f
#define MILISECONDS_TO_SECONDS 1000.0
#define SECONDS_TO_MINUTES 60.0

@interface SAArtistViewController ()
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *openInSpotifyButton;
@property (weak, nonatomic) IBOutlet UILabel *extraInfoLabel;
@property (nonatomic) NSString *urlSchema;
@property (strong, nonatomic) id item;

@end

@implementation SAArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.item isKindOfClass:[SAArtist class]]) {
        [self setupItemAsArtist];
    } else if ([self.item isKindOfClass:[SAAlbum class]]) {
        [self setupItemAsAlbum];
    } else if ([self.item isKindOfClass:[SATrack class]]) {
        [self setupItemAsTrack];
    }
    
    self.bioTextView.textColor = [UIColor aluminiumColor];
    self.bioTextView.font = [UIFont fontWithName:@"Avenir-Book" size:16.0];
    
    if (![self canOpenSpotify]) {
        self.openInSpotifyButton.enabled = NO;
    }
    
    [self roundAndBorderUserInterfaceItems];
}

#pragma mark - Data Setup

- (void)setupItemAsArtist {
    SAArtist *artist = (SAArtist *)self.item;
    self.artistNameLabel.text = artist.name;
    [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:artist.imageUrl]];
    self.bioTextView.text = artist.bio;
    self.urlSchema = [NSString stringWithFormat:@"spotify://http://open.spotify.com/artist/%@", artist.identifier];
    self.extraInfoLabel.text = [NSString stringWithFormat:@"%@ ❤︎", artist.popularity];
}

- (void)setupItemAsAlbum {
    SAAlbum *album = (SAAlbum *)self.item;
    self.artistNameLabel.text = album.name;
    [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:album.imageUrl]];
    NSString *trackString = [album.tracks componentsJoinedByString:@"\n- "];
    self.bioTextView.text = [NSString stringWithFormat:@"Songs on this album:\n- %@", trackString];
    self.urlSchema = [NSString stringWithFormat:@"spotify://http://open.spotify.com/album/%@", album.identifier];
    self.extraInfoLabel.text = [NSString stringWithFormat:@"%@ ❤︎", album.popularity];
}

- (void)setupItemAsTrack {
    SATrack *track = (SATrack *)self.item;
    self.artistNameLabel.text = track.name;
    [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:track.imageUrl]];
    self.bioTextView.text = [NSString stringWithFormat:@"Artist: %@", track.artist];
    self.urlSchema = [NSString stringWithFormat:@"spotify://http://open.spotify.com/track/%@", track.identifier];
    float seconds = ceil(track.duration / MILISECONDS_TO_SECONDS);
    int minutes = (seconds / SECONDS_TO_MINUTES) / 1;
    int remainingSeconds = (seconds - (minutes * 60)) / 1;
    self.extraInfoLabel.text = [NSString stringWithFormat:@"Time: %d:%d", minutes, remainingSeconds];
}

#pragma mark - User Interface

- (void)roundAndBorderUserInterfaceItems {
    self.artistImageView.layer.borderWidth = IMAGE_BORDER_WIDTH;
    self.artistImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.artistImageView.layer.cornerRadius = IMAGE_CORNER_RADIUS;
    self.artistImageView.clipsToBounds = YES;
    
    self.backButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backButton.layer.cornerRadius = self.backButton.frame.size.height / 2;
    self.backButton.clipsToBounds = YES;
    self.openInSpotifyButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    self.openInSpotifyButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.openInSpotifyButton.layer.cornerRadius = self.openInSpotifyButton.frame.size.height / 2;
    self.openInSpotifyButton.clipsToBounds = YES;
}

- (BOOL)canOpenSpotify {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.urlSchema]];
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

#pragma mark - UIButton Actions

- (IBAction)touchUpBackButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openInSpotifyButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlSchema]];
}

@end
