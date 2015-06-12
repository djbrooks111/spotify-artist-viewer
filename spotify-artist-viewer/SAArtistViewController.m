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

static const CGFloat ImageBorderWidth = 3.0f;
static const CGFloat ImageCornerRadius = 10.0f;
static const CGFloat ButtonBorderWidth = 2.0f;
static const CGFloat MillisecondsToSeconds = 1000.0;
static const CGFloat SecondsToMinutes = 60.0f;

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
    double seconds = ceil(track.duration / MillisecondsToSeconds);
    int minutes = (int)(seconds / SecondsToMinutes);
    int remainingSeconds = (int)(seconds - (minutes * 60));
    self.extraInfoLabel.text = [NSString stringWithFormat:@"Time: %d:%d", minutes, remainingSeconds];
}

#pragma mark - User Interface

- (void)roundAndBorderUserInterfaceItems {
    self.artistImageView.layer.borderWidth = ImageBorderWidth;
    self.artistImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.artistImageView.layer.cornerRadius = ImageCornerRadius;
    self.artistImageView.clipsToBounds = YES;
    
    self.backButton.layer.borderWidth = ButtonBorderWidth;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backButton.layer.cornerRadius = self.backButton.frame.size.height / 2;
    self.backButton.clipsToBounds = YES;
    self.openInSpotifyButton.layer.borderWidth = ButtonBorderWidth;
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
