//
//  RoleSelectionTableViewController.m
//  QRQuest2
//
//  Created by Gail on 2014-06-27.
//  Copyright (c) 2014 GailCarmichael. All rights reserved.
//

#import "RoleSelectionTableViewController.h"
#import "GameState.h"

@interface RoleSelectionTableViewController ()

@end

@implementation RoleSelectionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GameState *game = [GameState currentGame];
    return [game.playerRoles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RoleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell
    GameState *game = [GameState currentGame];
    PlayerRole *role = [game.playerRoles objectAtIndex:indexPath.row];
    cell.textLabel.text = role.roleName;
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.navigationItem.backBarButtonItem =
	[[[UIBarButtonItem alloc] initWithTitle:@"Choose Your Faculty"
									  style:UIBarButtonItemStylePlain
									 target:nil
									 action:nil] autorelease];
    
    GameState *game = [GameState currentGame];
    
    
    PlayerRole *role = [[game playerRoles] objectAtIndex:indexPath.row];
    [game setActivePlayerRole:role];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
