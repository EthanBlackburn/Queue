//
//  SCSearchViewController.m
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import "SCSearchViewController.h"

@interface SCSearchViewController ()

@end

@implementation SCSearchViewController
@synthesize account;
@synthesize selectedSongs;
@synthesize searchArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    account= [SCSoundCloud account];
    selectedSongs = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    SCRequestResponseHandler searchHandler;
    searchHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            searchArray = (NSArray *)jsonResponse;
            NSLog(@"%d",[searchArray count]);
        }
    };
    
    NSString *profileURL = [NSString stringWithFormat: @"http://api.soundcloud.com/tracks.json?{client_id={105963b586ee9e7633eef11e29ee5e20}&q={%@}&limit=20&streamable=true&order=playback_count",searchText];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:profileURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:searchHandler];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


@end
