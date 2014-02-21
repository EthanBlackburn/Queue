//
//  QueueAppDelegate.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueueAppDelegate.h"
#import "LeftPanelViewController.h"
#import "SongStruct.h"
#import "SCUI.h"

@implementation QueueAppDelegate

+ (void) initialize
{
    [SCSoundCloud setClientID:@"105963b586ee9e7633eef11e29ee5e20"
                       secret:@"c178f92829c5d1e342989adbb2cc5ad4"
                  redirectURL:[NSURL URLWithString:@"queue://oauth"]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    LeftPanelViewController *leftPanel = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
	self.viewController.leftPanel = leftPanel;
    [leftPanel setBTLE:[storyboard instantiateViewControllerWithIdentifier:@"BTLEController"]];
    
    [leftPanel setQVC:[storyboard instantiateViewControllerWithIdentifier:@"nowPlayingController"]];
    
    [leftPanel setQTVC:[storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
    
	self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[leftPanel QTVC]];
    
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //initialize all of QVC's data required to function
    [leftPanel QVC].myLibrary = [[NSMutableArray alloc] init];
    [leftPanel QVC].songQueue = [[NSMutableArray alloc] init];
    
    //initialize all of QTVC's data required to function
    [leftPanel QTVC].addedSongs = [[NSMutableDictionary alloc] init];
    
    //load our itunes library regardless of whether we are a host or not
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:0 songURL:(NSURL *)[song valueForProperty:MPMediaItemPropertyAssetURL] artwork:[song valueForProperty:MPMediaItemPropertyArtwork] type:@"itunes"];
        [[[leftPanel QVC] myLibrary] addObject:newSong];
        NSLog (@"%@", tempTitle);
    }
    NSLog(@"%lul songs loaded from library",(unsigned long)[[[leftPanel QVC] myLibrary] count]);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"here");
    if (!url) {  return NO; }
    
    //always go to queue table
    if(self.viewController.centerPanel == nil) {return NO; }
    
    
    //save account here
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
