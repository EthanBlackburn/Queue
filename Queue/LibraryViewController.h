//
//  LibraryViewController.h
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LibraryViewControllerDelegate;

@interface LibraryViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<LibraryViewControllerDelegate> libraryDelegate;
@property (nonatomic) NSArray *libraryData;
@property (nonatomic) NSMutableArray *selectedSongs;
@property (nonatomic) NSMutableArray *songButtons;

-(IBAction)done:(id)sender;
-(IBAction)addHandler:(id)sender;

@end

@protocol LibraryViewControllerDelegate <NSObject>

- (void)libraryViewController:(LibraryViewController *)libraryViewController
                   didChooseSongs:(NSMutableArray *)songs;
@end