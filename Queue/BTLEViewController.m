//
//  BTLEViewController.m
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

static NSString * const QueueService = @"queue-service";

static NSString * const kOperationCellIdentifier = @"Settings";
static NSString * const kBeaconCellIdentifier = @"Host";

static NSString * const kAdvertisingOperationTitle = @"Host A PlayList";
static NSString * const kRangingOperationTitle = @"Find A Playlist";
static NSString * const kSoundCloudOperationTitle = @"SoundCloud Account";
static NSUInteger const kNumberOfSections = 2;
static NSUInteger const kNumberOfAvailableOperations = 3;
static CGFloat const kOperationCellHeight = 44;
static CGFloat const kBeaconCellHeight = 52;
static NSString * const kBeaconSectionTitle = @"Looking for playlists...";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"HostHeader";

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

typedef NS_ENUM(NSUInteger, NTOperationsRow) {
    NTSoundCloudRow,
    NTAdvertisingRow,
    NTRangingRow
};

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "BTLEViewController.h"
#import "QueueViewController.h"
#import "QueueTableViewController.h"
#import "LeftPanelViewController.h"
#import "SCUI.h"
#import "SongStruct.h"

@interface BTLEViewController ()

@end

@implementation BTLEViewController
@synthesize myPeerID;
@synthesize foundPeers;
@synthesize connectedPeer;
@synthesize hostName;
@synthesize browser;
@synthesize currSession;
@synthesize sessions;
@synthesize advertiser;
@synthesize hostLibrary;
@synthesize accountLabel;

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch(state){
        case MCSessionStateConnected:
        {
            NSLog(@"%@ is connected",peerID.displayName);
            if(self.advertisingSwitch.on){
                /*NSMutableArray *tempLibrary = [[NSMutableArray alloc] init];
                [tempLibrary addObject:@"itunes"];
                [tempLibrary addObjectsFromArray:hostLibrary];//hostLibrary is my library when I am a server
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tempLibrary];
                [self sendData:data toPeers:[[NSArray alloc] initWithObjects:peerID, nil] reliable:YES error:nil];*/ //probably wont need this feature
                LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
                QueueTableViewController *queueTable = [leftController QTVC];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[queueTable songArray]];
                [self sendData:data toPeers:[[NSArray alloc] initWithObjects:peerID, nil] reliable:YES error:nil];
                disconnectCount = 0;
            }

        }
        case MCSessionStateConnecting:
        {
            NSLog(@"%@ is connecting",peerID.displayName);
        }
        case MCSessionStateNotConnected:
        {
            disconnectCount ++;
            NSLog(@"%@ is not connected",peerID.displayName);
            if((disconnectCount > 1) && self.rangingSwitch.on){
                [self centralDidDisconnect];
            }
        }
    }
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"receiving stream");
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"receiving resource %@",resourceName);
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"finished receiving resource");
}

- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || [[alertView textFieldAtIndex:0].text  isEqual: @""]){
        self.advertisingSwitch.on = NO;
    }
    else{
        [self setHostName:[alertView textFieldAtIndex:0].text];
        self.statusLabel.text = [NSString stringWithFormat:@"You are currently hosting a playlist named: %@",hostName ];
        [self createAdvertiser];
    }
    
}

-(void)dealloc{
    for(MCSession *tempSession in sessions){
        [tempSession disconnect];
        [sessions removeObject:tempSession];
    }
    
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Found peer %@",peerID);
    [foundPeers addObject:peerID];
    [self.tableView reloadData];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Peer %@ went out of range",peerID);
    [foundPeers removeObject:peerID];
    [self.tableView reloadData];
}

-(void)centralDidConnect
{
    [self.statusLabel setText:[NSString stringWithFormat:@"Currently connected to %@",connectedPeer.displayName]];
    [foundPeers removeAllObjects];
}

-(void)centralDidDisconnect
{
    [self.statusLabel setText:@"Connect to a playlist"];
    connectedPeer = nil;
    [browser startBrowsingForPeers];
    disconnectCount = 0;
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    QueueTableViewController *queueTable = [leftController QTVC];
    [queueTable.addedSongs removeAllObjects];
    [queueTable refreshTable];
    [self.tableView reloadData];
}

 //May not want to include wifi
-(void)centralStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to find or host a playlist";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    sessions = [[NSMutableArray alloc] init];
    hostLibrary = [[NSMutableArray alloc] init];
    [self centralStatePoweredOff];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createAdvertiser
{
    NSLog(@"Advertising started");
    myPeerID = [[MCPeerID alloc] initWithDisplayName:hostName];
    advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID
                                                   discoveryInfo:nil
                                                     serviceType:QueueService];
    advertiser.delegate = self;
    currSession = [self availableSession];
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    QueueViewController *qvc = [leftController QVC];
    hostLibrary = [qvc myLibrary];
    [advertiser startAdvertisingPeer];
}
/** Start advertising
 */
- (IBAction)advertisingSwitchChanged:(id)sender
{
    if (self.advertisingSwitch.on) {
        if(self.rangingSwitch.on){
            self.rangingSwitch.on = NO;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Playlist Name"
                                                            message:@"Please enter a name for your playlist"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        
    }
    
    else {
        [advertiser stopAdvertisingPeer];
        for(MCSession *tempSession in sessions){
            [tempSession disconnect];
        }
        [sessions removeAllObjects];
        advertiser = nil;
        currSession = nil;
        self.statusLabel.text = nil;
    }
}

/** Start ranging
 */
- (IBAction)rangingSwitchChanged:(id)sender
{
    if (self.rangingSwitch.on) {
        if(self.advertisingSwitch.on){
            self.advertisingSwitch.on = NO;
        }
        NSLog(@"ranging switch ON");
        foundPeers = [[NSMutableArray alloc] init];
        myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        browser = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:QueueService];
        browser.delegate = self;
        hostLibrary = [[NSMutableArray alloc] init];
        LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
        QueueTableViewController *queueTable = [leftController QTVC];
        //if we have data in our table, remove it
        [queueTable.addedSongs removeAllObjects];
        [queueTable refreshTable];
        currSession = [self availableSession];
        self.statusLabel.text = @"Connect to a playlist";
        [browser startBrowsingForPeers];
        [self.tableView reloadData];
        
    }
    
    else {
        [browser stopBrowsingForPeers];
        [currSession disconnect];
        [hostLibrary removeAllObjects];
        [foundPeers removeAllObjects];
        [sessions removeAllObjects];
        browser = nil;
        [self centralDidDisconnect];
        NSLog(@"ranging off");
        [self.tableView reloadData];
    }
}

- (MCSession *)availableSession {
    
    //Try and use an existing session
    for (MCSession *tempSession in sessions)
        if ([tempSession.connectedPeers count]<kMCSessionMaximumNumberOfPeers)
            return tempSession;
    
    //Or create a new session
    MCSession *newSession = [self newSession];
    [sessions addObject:newSession];
    
    return newSession;
}

- (MCSession *)newSession {
    
    MCSession *newSession = [[MCSession alloc] initWithPeer:myPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    newSession.delegate = self;
    
    return newSession;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
    NSLog(@"received invitation from %@",peerID.displayName);
    MCSession *newSession = [self availableSession];
    invitationHandler(YES,newSession);
    
    NSLog(@"sessions: %lu",(unsigned long)[sessions count]);
    
}

- (void)sendData:(NSData *)data toPeers:(NSArray *)peerIDs reliable:(BOOL)reliable error:(NSError *__autoreleasing *)error {
    
    if ([peerIDs count]==0)
        return;
    NSPredicate *peerNamePred;
    MCSessionSendDataMode mode = (reliable) ? MCSessionSendDataReliable : MCSessionSendDataUnreliable;
    if([[peerIDs objectAtIndex:0] isEqual:@"all"]){
        NSMutableArray *peers = [[NSMutableArray alloc] init];
        for(MCSession *tempSession in sessions){
            [peers addObjectsFromArray:tempSession.connectedPeers];
        }
        peerNamePred = [NSPredicate predicateWithFormat:@"displayName in %@", [peers valueForKey:@"displayName"]];
    }
    else{
        peerNamePred = [NSPredicate predicateWithFormat:@"displayName in %@", [peerIDs valueForKey:@"displayName"]];
    }
   
    
    //Need to match up peers to their session
    for (MCSession *tempSession in sessions){
        NSError __autoreleasing *currentError = nil;
        NSLog(@"Sending data");
        NSArray *filteredPeerIDs = [tempSession.connectedPeers filteredArrayUsingPredicate:peerNamePred];
        [tempSession sendData:data toPeers:filteredPeerIDs withMode:mode error:&currentError];
        
        if (currentError && !error)
            error = &currentError;
    }
}

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    QueueViewController *mainView = [leftController QVC];
    QueueTableViewController *queueTable = [leftController QTVC];
    
    NSLog(@"received data from %@",peerID.displayName);
    NSMutableArray *newPlaylist = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if([newPlaylist isKindOfClass:[NSMutableArray class]]){
        //the first song is a message from the host for parsing
        NSString *message = [newPlaylist objectAtIndex:0];
        //remove message
        [newPlaylist removeObjectAtIndex:0];
        //If the client requested the host itues library, the first song in the array will have the title "itunes"
        if([message isEqual: @"itunes"]){
            NSLog(@"itunes data size %u",[newPlaylist count]-1);
            for (id item in newPlaylist) {
                if([item isKindOfClass:[SongStruct class]]){//dont want to add the message object
                    [hostLibrary addObject:(SongStruct *)item];
                }
            }
        }
        else{
            //handling of adding songs should be the same on QTVC for both server and client
            for (SongStruct *item in newPlaylist) {
                //if we dont have have the song, query for it in our library, then add it
                if(self.advertisingSwitch.on){//if we're hosting the playlist
                    MPMediaPropertyPredicate *artistNamePredicate =
                    [MPMediaPropertyPredicate predicateWithValue: item.artist
                                                     forProperty: MPMediaItemPropertyArtist
                                                  comparisonType:MPMediaPredicateComparisonEqualTo];
                    NSLog(@"%@",item.artist);
                    MPMediaPropertyPredicate *albumNamePredicate =
                    [MPMediaPropertyPredicate predicateWithValue: item.title
                                                     forProperty: MPMediaItemPropertyTitle
                                                  comparisonType:MPMediaPredicateComparisonEqualTo];
                    NSLog(@"%@",item.title);
                    MPMediaQuery *myComplexQuery = [[MPMediaQuery alloc] init];
                    
                    [myComplexQuery addFilterPredicate: artistNamePredicate];
                    [myComplexQuery addFilterPredicate: albumNamePredicate];
                    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:[myComplexQuery items]];
                    NSMutableArray *hostSongs = [[NSMutableArray alloc] init];
                    for(MPMediaItem *item in collection.items){
                        //host songstruct includes url/buffer. Client songs do not
                        SongStruct *tempSong = [[SongStruct alloc] initWithTitle:[item valueForProperty:MPMediaItemPropertyTitle] artist:[item valueForProperty:MPMediaItemPropertyArtist] voteCount:1 songURL:[item valueForProperty:MPMediaItemPropertyAssetURL] artwork:[item valueForProperty:MPMediaItemPropertyArtwork] type:@"itunes"];
                        [hostSongs addObject:tempSong];
                        
                    }
                    [mainView updatePlayerQueueWithMediaCollection: hostSongs];
                    
                    for(MCSession *tempSession in sessions){
                        //dont resend the data to the peer who sent us the updated playlist or it may cause an infinite loop
                        NSMutableArray *idsToSend = [[NSMutableArray alloc] init];
                        for(MCPeerID *peer in tempSession.connectedPeers){
                            if(peer != peerID){
                                [idsToSend addObject:peer];
                            }
                        }
                        [self sendData:data toPeers:idsToSend reliable:YES error:nil];
                    }

                }
                [queueTable addSong:item];
            }
        }
    
    }
    
}

//tableView methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case NTOperationsSection: {
            cell = [tableView dequeueReusableCellWithIdentifier:kOperationCellIdentifier];
            switch (indexPath.row) {
                case NTSoundCloudRow:
                    cell = [tableView dequeueReusableCellWithIdentifier:kOperationCellIdentifier];
                    cell.textLabel.text = kSoundCloudOperationTitle;
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.accessoryView = nil;
                    accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 25.0, 230.0, 25.0)];
                    accountLabel.font = [UIFont systemFontOfSize:20.0];
                    accountLabel.textAlignment = NSTextAlignmentLeft;
                    accountLabel.textColor = [UIColor blackColor];
                    accountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
                    [cell.contentView addSubview:accountLabel];
                    if([SCSoundCloud account] != nil){
                        accountLabel.text = [[SCSoundCloud account] identifier];
                    }
                    break;
                case NTAdvertisingRow:
                    cell.textLabel.text = kAdvertisingOperationTitle;
                    self.advertisingSwitch = (UISwitch *)cell.accessoryView;
                    [self.advertisingSwitch addTarget:self
                                               action:@selector(advertisingSwitchChanged:)
                                     forControlEvents:UIControlEventValueChanged];
                    break;
                case NTRangingRow:
                default:
                    cell.textLabel.text = kRangingOperationTitle;
                    self.rangingSwitch = (UISwitch *)cell.accessoryView;
                    [self.rangingSwitch addTarget:self
                                           action:@selector(rangingSwitchChanged:)
                                 forControlEvents:UIControlEventValueChanged];
                    break;
            }
        }
            break;
        case NTDetectedBeaconsSection:
        default: {
            MCPeerID *tempID = foundPeers[indexPath.row];
            
            cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
            
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:kBeaconCellIdentifier];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@",tempID.displayName];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
            break;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.rangingSwitch.on && connectedPeer == nil) {
        return kNumberOfSections;       // All sections visible
    } else {
        return kNumberOfSections - 1;   // Beacons section not visible
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return kNumberOfAvailableOperations;
        case NTDetectedBeaconsSection:
        default:
            return [foundPeers count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return nil;
        case NTDetectedBeaconsSection:
        default:
            return kBeaconSectionTitle;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case NTOperationsSection:
            return kOperationCellHeight;
        case NTDetectedBeaconsSection:
        default:
            return kBeaconCellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView =
    [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kBeaconsHeaderViewIdentifier];
    
    // Adds an activity indicator view to the section header
    UIActivityIndicatorView *indicatorView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [headerView addSubview:indicatorView];
    
    indicatorView.frame = (CGRect){kActivityIndicatorPosition, indicatorView.frame.size};
    
    [indicatorView startAnimating];
    
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == NTOperationsSection && [indexPath row] == NTSoundCloudRow) {
        [self login];
    }
    
    else if([indexPath section] > 0){
        connectedPeer = [foundPeers objectAtIndex:[indexPath row]];
        [browser invitePeer:connectedPeer toSession:currSession withContext:nil timeout:0];
        [self centralDidConnect];
        [browser stopBrowsingForPeers];
        [self.tableView reloadData];
    }
    
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
            accountLabel.text = [[SCSoundCloud account] identifier];
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
