//
//  SCYouViewController.m
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import "SCYouViewController.h"

@interface SCYouViewController ()

@end

@implementation SCYouViewController
@synthesize segmentButtons;
@synthesize profileName;
@synthesize profilePicture;
@synthesize tracks;
@synthesize account;
@synthesize profile;
@synthesize selectedSongs;
@synthesize songButtons;

-(IBAction)addHandler:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    NSDictionary *tempSong = [tracks objectAtIndex:senderButton.tag];
    [selectedSongs addObject:tempSong];
    senderButton.enabled = NO;
}

-(IBAction)done:(id)sender
{
    [self.delegate youViewController:self didChooseSongs:selectedSongs];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedSongs = [[NSMutableArray alloc] init];
    songButtons = [[NSMutableArray alloc] init];
    account = [SCSoundCloud account];
    if(account == nil){
        
    }
    //get user json data from soundcloud
    SCRequestResponseHandler profileHandler;
    profileHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
            profile = (NSDictionary *)jsonResponse;
            //set profile label and picture
            profileName.text = [profile objectForKey:@"username"];
            NSURL *imageURL = [NSURL URLWithString:[profile objectForKey:@"avatar_url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *tempImage = [UIImage imageWithData:imageData];
            profilePicture.image = tempImage;
            
        }
    };
    
    NSString *profileURL = @"https://api.soundcloud.com/me.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:profileURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:profileHandler];
    
    
    //get users tracks from soundloud. the JSON response is an array of tracks. Each track is a dictionary object with its info.
    SCRequestResponseHandler trackHandler;
    trackHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            
            tracks = (NSArray *)jsonResponse;
            [self.tableView reloadData];
            
        }
    };
    
    NSString *tracksURL = @"https://api.soundcloud.com/me/favorites.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:tracksURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:trackHandler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//resize image to fit cell
-(UIImage *)resizeimage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext( size );
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    return img;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Track";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // Configure the cell...
    NSLog(@"%d",indexPath.row);
    UILabel *titleLabel;
    UILabel *artistLabel;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 7.5, 210.0, 25)];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    
    [cell.contentView addSubview:titleLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 25.0, 210.0, 20.0)];
    artistLabel.font = [UIFont systemFontOfSize:12.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    
    [cell.contentView addSubview:artistLabel];
    
    NSDictionary *track = (NSDictionary *)[tracks objectAtIndex:indexPath.row];
    titleLabel.text = [track objectForKey:@"title"];
    
    NSDictionary *user = [track objectForKey:@"user"];
    artistLabel.text = [user objectForKey:@"username"];
    
    UIButton *addButton = (UIButton *)cell.accessoryView;
    [addButton addTarget:self action:@selector(addHandler:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTag:[indexPath row]];
    [songButtons addObject:addButton];
    [cell.contentView addSubview:addButton];
    
    UIImageView *albumView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0,7.5,25.0,25.0)];
    [cell.contentView addSubview:albumView];
    
    NSURL *imageURL = [NSURL URLWithString:[track objectForKey:@"artwork_url"]];
    if(![imageURL isKindOfClass:[NSNull class]]){
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *tempImage = [UIImage imageWithData:imageData];
        albumView.image = [self resizeimage:tempImage toSize:CGSizeMake(25.0, 25.0)];
    }
    
    return cell;
}



@end
