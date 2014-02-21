//
//  SongStruct.m
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "SongStruct.h"

@implementation SongStruct
@synthesize title,
            artist,
            votes,
            mediaURL,
            artwork,
            artworkURL,
            type,
            tinyArtwork;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count songURL:(NSURL *)url artwork:(UIImage *)art type:(NSString *)source
{
    self = [super init];
    
    self.title = strTitle;
    self.artist = strArtist;
    self.votes = count;
    self.strIdentifier = self.identifier;
    self.mediaURL = url;
    self.artwork = art;
    self.type = source;
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        //artwork and mediaURL will be nil. We keep them as nil because the host will
        //never receive those two as an object. Only title, artist and votes will be sent to
        //clients. This makes sending the data easier
        self.title = [coder decodeObjectForKey:@"ASCTitle"];
        self.artist = [coder decodeObjectForKey:@"ASCArtist"];
        self.votes = [coder decodeIntegerForKey:@"ASCVotes"];
        self.type = [coder decodeObjectForKey:@"ASCType"];
        self.artworkURL = [coder decodeObjectForKey:@"ASCArtURL"];
        //set artwork
        [self imageFromURL:artworkURL];
        self.strIdentifier = self.identifier;
    }
    return self;
}

-(void)Vote
{
    self.votes++;
}

-(void)imageFromURL:(NSURL *)url{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    self.artwork = [UIImage imageWithData:imageData];
    
}

-(NSString *)identifier
{
    return [NSString stringWithFormat:@"%@%@",self.title,self.artist];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"ASCTitle"];
    [coder encodeObject:self.artist forKey:@"ASCArtist"];
    [coder encodeInteger:self.votes forKey:@"ASCVotes"];
    [coder encodeObject:self.type forKey:@"ASCType"];
    [coder encodeObject:self.artworkURL forKey:@"ASCArtURL"];
    self.artwork = nil;
}

@end
