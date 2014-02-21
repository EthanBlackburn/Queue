//
//  QueueTableViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "QueueTableViewController.h"
#import "QueueViewController.h"
#import "LeftPanelViewController.h"


@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;
@synthesize songArray;
@synthesize addSongIsPressed;
@synthesize goToHost;
@synthesize goToSC;
@synthesize shadow;
@synthesize selectionBox;
@synthesize btController;

- (IBAction) addHandler {
    
    //if addMusicButton is already pressed remove the shadow and selectionBox
    if (addSongIsPressed == true) {
        [shadow removeFromSuperview];
        [selectionBox removeFromSuperview];
        addSongIsPressed = false;
        return;
    }
    else {
        addSongIsPressed = true;
    }

    
    //create another view with black background and alpha<1
    shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [self.view addSubview:shadow];

    
    //create box for choosing either from hosts library or soundcloud
    selectionBox = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 20, self.view.frame.size.width/2, 100)];
    selectionBox.backgroundColor = [UIColor whiteColor];
    [shadow addSubview:selectionBox];
    
    
    //add proper buttons to selectionBox
        //go to hosts library
    self.goToHost = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, selectionBox.frame.size.width -20, selectionBox.frame.size.height/2-20)];
    [goToHost setTitle:@"Host's Library" forState:UIControlStateNormal];
    goToHost.backgroundColor = [UIColor blackColor];
    [goToHost addTarget:self action:@selector(goToHost:) forControlEvents:UIControlEventTouchUpInside];
    [selectionBox addSubview:goToHost];
    
    
        //go to sound cloud
    goToSC = [[UIButton alloc] initWithFrame:CGRectMake(10,selectionBox.frame.size.height/2+10,selectionBox.frame.size.width-20, selectionBox.frame.size.height/2-20)];
    [goToSC setTitle:@"Sound Cloud" forState:UIControlStateNormal];
    goToSC.backgroundColor = [UIColor blackColor];
    [goToSC addTarget:self action:@selector(goToSC:) forControlEvents:UIControlEventTouchUpInside];
    [selectionBox addSubview:goToSC];
    
    
}

-(void)goToHost:(id)senderA{
    NSLog(@"senderA");
    [shadow removeFromSuperview];
    [selectionBox removeFromSuperview];
    if(!btController.rangingSwitch.on){
        MPMediaPickerController *mediaPicker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
        
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = NSLocalizedString (@"Add a song to the queue", @"Choose a song to add to the queue");
        
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:mediaPicker animated:YES completion:nil];
        } else {
            [self presentModalViewController:mediaPicker animated:YES];
        }
    }
    
    else{
        [self performSegueWithIdentifier:@"LibrarySegue" sender:self];
    }
}

-(void)goToSC:(id)senderB{
    NSLog(@"senderB");
    [self performSegueWithIdentifier:@"SCSegue" sender:self];
}

//vote button for song
-(void)upVote:(id)sender{
    UIButton *tempButton = (UIButton *)sender;
    SongStruct *temp = [self.songArray objectAtIndex:tempButton.tag];
    [temp Vote];
    tempButton.enabled = NO; //not working
    //[self.currentQueue cellForRowAtIndexPath:tempButton.tag] remove cell button
    [self.currentQueue reloadData];
    NSArray *tempArray = [[NSArray alloc] initWithObjects:temp, nil];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tempArray];
    if(btController.rangingSwitch.on && btController.connectedPeer != nil){
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:btController.connectedPeer, nil] reliable:YES error:nil];
    }
    else if (btController.advertisingSwitch.on){
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:@"all",nil] reliable:YES error:nil];
    }
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    //set addSongisPressed to false
    self.addedSongs = [[NSMutableDictionary alloc] init];
    addSongIsPressed = false;
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    btController = [leftController BTLE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//library view controller for clients
-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSMutableArray *)songs
{
    if([songs count] > 0){
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songs];
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:btController.connectedPeer, nil] reliable:YES error:nil];
        for(SongStruct *tempSong in songs){
            //QueueTable delegate method
            [self addSong:tempSong];
        }
        
    }
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//chose song from soundcloud. Clients and host
-(void)youViewController:(SCYouViewController *)YouViewController didChooseSongs:(NSMutableArray *)songs
{
    if([songs count] > 0){
        
        for(SongStruct *tempSong in songs){
            [self addSong:tempSong];
        }
        if(btController.advertisingSwitch.on){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songs];
            [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:@"all", nil] reliable:YES error:nil];
        }
        else if(btController.rangingSwitch.on){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songs];
            [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:btController.connectedPeer, nil] reliable:YES error:nil];
        }
        QueueViewController *mainView = [(LeftPanelViewController *)self.sidePanelController.leftPanel QVC];
        [mainView updatePlayerQueueWithMediaCollection:songs];
        
    }
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// library view controller for host
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    //dismiss picker
	if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //add the songs to our queue table view
    for (int i = 0; i<mediaItemCollection.items.count; i++) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        //note: Do not need buffer, url or album artwork for queue table. It is simply a list
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:1 songURL:nil artwork:nil type:@"itunes"];
        [self addSong:newSong];
        
    }
    if(!btController.rangingSwitch.on){
        //get relevant data from songs and add them to the queue
        NSMutableArray *songData = [[NSMutableArray alloc] init];
        for(MPMediaItem *item in mediaItemCollection.items){
            SongStruct *newSong = [[SongStruct alloc] initWithTitle:[item valueForProperty:MPMediaItemPropertyTitle] artist:[item valueForProperty:MPMediaItemPropertyArtist] voteCount:1 songURL:[item valueForProperty:MPMediaItemPropertyAssetURL] artwork:[item valueForProperty:MPMediaItemPropertyArtwork] type:@"itunes"];
            NSLog(@"%@",[newSong mediaURL]);
            NSLog(@"%@",[item valueForProperty:MPMediaItemPropertyTitle]);
            //add song to queue table
            [self addSong:newSong];
            
        }
        
        //if ranging switch is off, we are hosting a playlist.
        //QueueViewController *mainView = [leftController QVC];
        //add picked songs to our media queue
        //[mainView updatePlayerQueueWithMediaCollection: songData];
        //update playlist tables of all connected peers. They dont need the media data
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songArray];
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:@"all", nil] reliable:YES error:nil];
    }
}

-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.addedSongs count];
}

-(void)refreshTable{
    [self.currentQueue reloadData];
}

//update our table view with added/edited songs
-(void)addSong:(SongStruct *)song{
    if([self.addedSongs objectForKey:song.identifier] == nil){
        [self.addedSongs setObject:song forKey:song.identifier];
    }
    else{
        SongStruct *temp = [self.addedSongs objectForKey:song.identifier];
        [temp Vote];
    }
    self.songArray = [self.addedSongs allValues];
	[self refreshTable];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UILabel *titleLabel;
    UILabel *artistLabel;
    UIButton *sideButton;
    UILabel *votesLabel;
    SongStruct *anItem = (SongStruct *)[self.songArray objectAtIndex:[indexPath row]];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 7.5, 230.0, 20)];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:titleLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 25.0, 230.0, 25.0)];
    artistLabel.font = [UIFont systemFontOfSize:14.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:artistLabel];
    
    votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 25.0, 55.0, 25.0)];
    votesLabel.font = [UIFont systemFontOfSize:14.0];
    votesLabel.textAlignment = NSTextAlignmentLeft;
    votesLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:votesLabel];
    
    
    sideButton = [[UIButton alloc] initWithFrame:CGRectMake(255.0, 15.0, 55.0, 15.0)];
    [sideButton addTarget:self action:@selector(upVote:) forControlEvents:UIControlEventTouchUpInside];
    [sideButton setTag:[indexPath row]];
    [sideButton setTitle:@"Vote" forState:UIControlStateNormal];
    [sideButton setBackgroundColor:[UIColor blackColor]];
    [cell.contentView addSubview:sideButton];
    [titleLabel setText: anItem.title];
    [artistLabel setText:anItem.artist];
    NSString *tempLabel = anItem.votes > 1 ? @"Votes":@"Vote";
    [votesLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)anItem.votes,tempLabel]];
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"LibrarySegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        LibraryViewController *LVC = navController.viewControllers[0];
        [LVC setLibraryDelegate:self];
        [LVC setLibraryData:[btController hostLibrary]];
    }
    else if([[segue identifier] isEqualToString:@"SCSegue"]){
        UITabBarController *tabController = segue.destinationViewController;
        UINavigationController *navController = tabController.viewControllers[0];
        SCYouViewController *youViewController = navController.viewControllers[0];
        youViewController.delegate = self;
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
