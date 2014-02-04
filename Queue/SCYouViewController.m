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
@synthesize playlists;
@synthesize posts;
@synthesize currentData;

-(IBAction)segmentedControl:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        currentData = posts;
    }
    else if (segmentedControl.selectedSegmentIndex == 1){
        currentData = playlists;
    }
    else if (segmentedControl.selectedSegmentIndex == 2){
        currentData = tracks;
    }
    [self.tableView reloadData];
}


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

-(void)viewDidAppear:(BOOL)animated{
    if(account == nil){
        [self login];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedSongs = [[NSMutableArray alloc] init];
    songButtons = [[NSMutableArray alloc] init];
    account = [SCSoundCloud account];
    [self profileData];
    
}


-(void)profileData{
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
    
    
    //get users favorites from soundloud. the JSON response is an array of tracks. Each track is a dictionary object with its info.
    SCRequestResponseHandler trackHandler;
    trackHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            
            tracks = (NSArray *)jsonResponse;
            
        }
    };
    
    NSString *tracksURL = @"https://api.soundcloud.com/me/favorites.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:tracksURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:trackHandler];
    
    //get users tracks from soundloud. the JSON response is an array of tracks. Each track is a dictionary object with its info.
    SCRequestResponseHandler postsHandler;
    postsHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            
            posts = (NSArray *)jsonResponse;
            //show posts in table on load
            currentData = posts;
            [self.tableView reloadData];
            
        }
    };
    
    NSString *postsURL = @"https://api.soundcloud.com/me/tracks.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:postsURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:trackHandler];
    
    //get users posts
    SCRequestResponseHandler playlistsHandler;
    playlistsHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            
            playlists = (NSArray *)jsonResponse;
            
        }
    };
    
    NSString *playlistsURL = @"https://api.soundcloud.com/me/playlists.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:playlistsURL]
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [currentData count];
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
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(42.0, 5.0, 190.0, 25)];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    
    [cell.contentView addSubview:titleLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(42.0, 25.0, 190.0, 20.0)];
    artistLabel.font = [UIFont systemFontOfSize:13.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    
    [cell.contentView addSubview:artistLabel];
    
    NSDictionary *track = (NSDictionary *)[currentData objectAtIndex:indexPath.row];
    titleLabel.text = [track objectForKey:@"title"];
    
    NSDictionary *user = [track objectForKey:@"user"];
    artistLabel.text = [user objectForKey:@"username"];
    
    UIButton *addButton = (UIButton *)cell.accessoryView;
    [addButton addTarget:self action:@selector(addHandler:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTag:[indexPath row]];
    [songButtons addObject:addButton];
    [cell.contentView addSubview:addButton];
    
    UIImageView *albumView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,7.5,40.0,40.0)];
    [cell.contentView addSubview:albumView];
    
    if(![[track objectForKey:@"artwork_url"] isKindOfClass:[NSNull class]]){
        NSURL *imageURL = [NSURL URLWithString:[track objectForKey:@"artwork_url"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *tempImage = [UIImage imageWithData:imageData];
        albumView.image = [self resizeimage:tempImage toSize:CGSizeMake(40.0, 40.0)];
    }
    return cell;
}

//soundcloud login VC
- (void) login
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
            account = [SCSoundCloud account];
            [self profileData];
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentModalViewController:loginViewController animated:YES];
    }];
}




@end
