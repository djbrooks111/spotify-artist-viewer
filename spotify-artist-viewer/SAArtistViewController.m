//
//  SAArtistViewController.m
//  spotify-artist-viewer
//
//  Created by David Brooks on 6/9/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "SAArtistViewController.h"

@interface SAArtistViewController ()
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (nonatomic) SAArtist *artist;

@end

@implementation SAArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.artistNameLabel.text = self.artist.name;
    self.artistImageView.image = self.artist.image;
    self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.width / 3.0;
    self.artistImageView.layer.masksToBounds = YES;
    self.bioTextView.text = self.artist.bio;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithArtist:(SAArtist *)artist {
    if (self == [super init]) {
        self.artist = artist;
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
