//
//  SongStruct.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SongStruct : NSObject

@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *title;
@property (nonatomic) NSUInteger votes;
@property (nonatomic) NSString *strIdentifier;
@property (nonatomic) NSURL *mediaURL;
@property (nonatomic) NSURL *artworkURL;
@property (nonatomic) UIImage *artwork;
@property (nonatomic) NSString *type;
@property (nonatomic) UIImage *tinyArtwork;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count songURL:(NSURL *)url artwork:(UIImage *)art type:(NSString *)source;
-(NSString *)identifier;
-(void) Vote;
-(void)imageFromURL:(NSURL *)url;

@end
