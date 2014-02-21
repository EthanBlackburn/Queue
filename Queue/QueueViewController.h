//
//  QueueViewController.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SongStruct.h"


@interface QueueViewController : UIViewController < MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, UITabBarDelegate>
{
    NSTimer *audioTimer;
    
}

@property (nonatomic) IBOutlet UIImageView *artworkItem;
@property (nonatomic) NSMutableArray *songQueue;
@property (nonatomic) AVAudioPlayer *appPlayer;
@property (nonatomic) NSURL *soundFileURL;
@property (nonatomic,readwrite) NSUInteger voteCount;
@property (nonatomic,copy) SongStruct *nowPlayingItem;
@property (nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (nonatomic) IBOutlet UILabel *artistLabel;
@property (nonatomic) IBOutlet UILabel *minLabel;
@property (nonatomic) IBOutlet UILabel *maxLabel;
@property (nonatomic) IBOutlet UIButton *pausePlay;
@property (nonatomic) IBOutlet UIProgressView *songProgress;
@property (nonatomic) NSMutableArray *myLibrary;
@property (readwrite) BOOL playing;
@property (readwrite) BOOL interruptedOnPlayback;

-(IBAction)pauseOrPlayMusic :(id)sender;
- (void) updatePlayerQueueWithMediaCollection: (NSArray *) mediaItemCollection;


@end



