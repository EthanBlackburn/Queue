//
//  QueueViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "QueueViewController.h"
#import "QueueTableViewController.h"
#import "QuartzCore/CALayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface QueueViewController ()

@end


@implementation QueueViewController

@synthesize songQueue;
@synthesize soundFileURL;
@synthesize appPlayer;
@synthesize voteCount;
@synthesize nowPlayingItem;
@synthesize nowPlayingLabel;
@synthesize artworkItem;
@synthesize artistLabel;
@synthesize pausePlay;
@synthesize songProgress;
@synthesize playing;
@synthesize interruptedOnPlayback;
@synthesize myLibrary;
@synthesize minLabel;
@synthesize maxLabel;

-(void)handleRouteChange:(NSNotification*)notification{
    //AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    //  AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            [appPlayer pause];
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            [appPlayer pause];
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            [appPlayer play];
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    //AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count]?session.currentRoute.inputs:nil objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self viewSetup];
    
    [self registerForMediaPlayerNotifications];
    
    
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    
	if (appPlayer.rate != 0.0f && songQueue) {
		
		[appPlayer play];
	}
    
}

- (void) registerForMediaPlayerNotifications {
    
    
    
	/*[[NSNotificationCenter defaultCenter] addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: mainPlayer];*/
    
    [[NSNotificationCenter defaultCenter]  addObserver: self
                        selector: @selector(handleRouteChange:)
                         name: AVAudioSessionRouteChangeNotification
                            object: appPlayer];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:appPlayer.currentItem];*/
    
    /*[notificationCenter addObserver: self
                          selector: @selector(handleInterruption:)
                           name: AVAudioSessionInterruptionNotification
                          object: session];*/
    
}

#pragma mark resize image method
-(UIImage *)resizeimage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext( size );
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    if([image respondsToSelector:@selector(drawInRect:)]){
        [image drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        return img;

    }
    else{
        return [(MPMediaItemArtwork *)image imageWithSize:size];
    }
}

#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying:(NSNotification *)notification {
    
    NSLog(@"finished playing song");
    if(audioTimer)
        [audioTimer invalidate];
    
	playing = NO;
    [songQueue removeObjectAtIndex:0];
    [appPlayer removeObserver:self forKeyPath:@"status"];
    [self nextSong];
	
}


- (void) audioPlayerBeginInterruption: player {
    
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	
	if (interruptedOnPlayback) {
        
		[appPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)audioProgressUpdate{
    
    if (appPlayer.playing){
        double currentTime = appPlayer.duration;
        double duration = appPlayer.currentTime;
        [songProgress setProgress:currentTime/duration];
        minLabel.text = [NSString stringWithFormat: @"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60];
        maxLabel.text = [NSString stringWithFormat: @"%02d:%02d", (int)duration / 60, (int)duration % 60];
    }
}

-(IBAction)pauseOrPlayMusic:(id)sender
{
    
    if(appPlayer != nil){
        if(appPlayer.playing){
            [appPlayer pause];
            [pausePlay setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        }
        else{
            [appPlayer play];
            [pausePlay setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)nextSong{
    if([songQueue count] > 0){
        NSLog(@"Next song");
        SongStruct *song = [songQueue objectAtIndex:0];
        if([song.type isEqual:@"SC"]){
            SCAccount *account = [SCSoundCloud account];
            
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:song.mediaURL
                     usingParameters:nil
                         withAccount:account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                         NSError *playerError;
                         
                         appPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                         [appPlayer prepareToPlay];
                         [appPlayer play];
                         [appPlayer addObserver:self forKeyPath:@"status" options:0 context:nil]; // add observer for player
                         [appPlayer setVolume: 1.0];
                     }];
        }
        
        SongStruct *currentItem = [songQueue objectAtIndex:0];
        nowPlayingItem = currentItem;
        [self registerForMediaPlayerNotifications];
    }
    else{
        nowPlayingItem = nil;
    }
    [self viewSetup];
    
}

-(void)viewSetup{
    if([songQueue count] > 0){
        [pausePlay setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
        [artworkItem setImage:nil];
        
        // Get the artwork from the current media item, if it has artwork.
        UIImage *artwork = [nowPlayingItem artwork];
        // Obtain a UIImage object from the MPMediaItemArtwork object
        if (artwork) {
            artworkItem.image = [self resizeimage:artwork toSize:CGSizeMake (280, 280)];
            
            UIColor *background = [[UIColor alloc] initWithPatternImage:[self resizeimage:artwork toSize:CGSizeMake(1000, 1000)]];
            [self.view setBackgroundColor:background];
        }
        
        // Display the artist and song name for the now-playing media item
        [nowPlayingLabel setText: [nowPlayingItem title]];
        [artistLabel setText: [nowPlayingItem artist]];
    }
    else{
        artworkItem.image = nil;
        [pausePlay setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        [nowPlayingLabel setText: NSLocalizedString (@"", @"Brief instructions to user, shown at launch")];
        [artistLabel setText:NSLocalizedString(@"", @"Artist")];
        [minLabel setText:@"00:00"];
        [maxLabel setText:@"--:--"];
        [songProgress setProgress:0];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]]];
    }
}

- (void) updatePlayerQueueWithMediaCollection: (NSArray *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
    
	if (mediaItemCollection) {

        [songQueue addObjectsFromArray:mediaItemCollection];
        NSLog(@"%@",[songQueue objectAtIndex:0]);
        //if not playing or hasnt been initiated
        if(!appPlayer || !appPlayer.playing){
            NSLog(@"next song");
            [self nextSong];
            
        }
            
    }
    
}


@end









