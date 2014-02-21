//
//  LibraryViewController.m
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "LibraryViewController.h"
#import "BTLEViewController.h"
#import "QueueTableViewController.h"
#import "BTLEViewController.h"
#import "SongStruct.h"

@interface LibraryViewController ()

@end

@implementation LibraryViewController
@synthesize libraryData;
@synthesize selectedSongs;
@synthesize songButtons;



-(IBAction)done:(id)sender
{
    [self.libraryDelegate libraryViewController:self didChooseSongs:selectedSongs];
}

-(IBAction)addHandler:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    SongStruct *tempSong = [libraryData objectAtIndex:[senderButton tag]];
    [tempSong Vote];
    [selectedSongs addObject:tempSong];
    senderButton.enabled = NO;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Showing library picker");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    selectedSongs = [[NSMutableArray alloc] init];
    songButtons = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [libraryData count] > 0 ? 1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%d",[libraryData count]);
    return [libraryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 7.5, 230.0, 20)];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 22.5, 230.0, 25.0)];
    artistLabel.font = [UIFont systemFontOfSize:12.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:artistLabel];
    
    UIButton *addButton = (UIButton *)cell.accessoryView;
    [addButton addTarget:self action:@selector(addHandler:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTag:[indexPath row]];
    [songButtons addObject:addButton];
    [cell.contentView addSubview:addButton];
    
    SongStruct *tempSong = [libraryData objectAtIndex:[indexPath row]];
    [artistLabel setText:tempSong.artist];
    [titleLabel setText:tempSong.title];
    
    return cell;
}


@end
