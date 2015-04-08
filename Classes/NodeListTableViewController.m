//
//  NodeListTableViewController.m
//  QRQuest2
//
//  Created by Gail on 11-06-03.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "GameState.h"
#import "NodeListTableViewController.h"
#import "SimpleGraphNodeViewController.h"


@implementation NodeListTableViewController

@synthesize itemsFoundButton, continueStoryButton;


- (NSString *)itemsFoundString
{
    GameState *game = [GameState currentGame];
    
    int min = [game minNumScavengerItemsToFindForNode:[game activeNodeIdentifier]];
    int found = [game numScavengerItemsFoundForNode:[game activeNodeIdentifier]];
    //int total = [game numScavengerItemsForNode:[game activeNodeIdentifier]];
    
	int numLeft = min - found;
	
	/*if (min == total)
	{
        if (numLeft > 0)
            return @"Find all items.";
        else
            return @"You found all the items.";
	}
	else*/ if (numLeft > 1)
	{
		return [NSString stringWithFormat:@"Find at least %d more items.", numLeft];
	}
	else if (numLeft == 1)
	{
		return [NSString stringWithFormat:@"Find at least %d more item.", numLeft];
	}
	else
	{
		return @"You have found enough items.";
	}
}


- (void) continueStoryButtonTapped
{
    // As items are found the game does not advance, so we have
    // to advance it here
    
    [[GameState currentGame] transitionToNextNode];
}


#pragma mark - Model updating

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType
{
    BOOL shouldCancelRemaining = NO;
    
    if (updateType == e_ModelUpdate_SelectedScavengerListOption)
    {
        SimpleGraphNodeViewController *controller =
            [[SimpleGraphNodeViewController alloc]
                initWithNodeID: [[GameState currentGame] mostRecentScavengerListItemNodeID]];
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    if (updateType == e_ModelUpdate_FoundScavengerItem)
    {
        // Need to refresh the table so we can add checkmarks to the items
        // that were found
        [self.tableView reloadData];
        
    }
    
    if (updateType == e_ModelUpdate_CurrentStoryNode)
    {
        // Pop to show the new node
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    if (updateType == e_ModelUpdate_FoundIncorrectCode)
    {
        UIAlertView *wrongCode = [[UIAlertView alloc] initWithTitle: @"Sorry!"
                                                            message: @"This is not the code you were looking for. Keep trying!"
                                                           delegate: self 
                                                  cancelButtonTitle: @"OK" 
                                                  otherButtonTitles: nil];   
        
        [wrongCode show];
        [wrongCode release];
        
        shouldCancelRemaining = YES;
    }
    
    return shouldCancelRemaining;
}



#pragma mark - View updating


- (void) setupToolbarAnimated:(BOOL)animated
{
    // Show info on the bottom toolbar
	
	NSMutableArray *toolbarItems = [NSMutableArray array];
	
	UIBarButtonItem * flex =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												   target:nil 
												   action:nil] autorelease];
	[toolbarItems addObject:flex];
	
    GameState *game = [GameState currentGame];
    
    if (![game isNodeLastSoFar:[game activeNodeIdentifier]])
    {
        // add nothing
    }
	else if (![game scavengerCanContinueStory:[game activeNodeIdentifier]])
	{
        self.itemsFoundButton.title = [self itemsFoundString];
		[toolbarItems addObject:self.itemsFoundButton];
	}
	else
	{
		[toolbarItems addObject:self.continueStoryButton];
	}
    
	
	[toolbarItems addObject:flex];
	
    // Set the toolbar items
	[self setToolbarItems:toolbarItems animated:animated];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Find These Items";
    
    // Add ourselves as an observer
    [[GameState currentGame] registerObserver:self];
    
    
    // Setup and save the reused buttons
    
    self.itemsFoundButton = [[[UIBarButtonItem alloc] initWithTitle:[self itemsFoundString]
                                                              style:UIBarButtonItemStylePlain 
                                                             target:nil 
                                                             action:nil] autorelease];
    
    self.continueStoryButton = [[[UIBarButtonItem alloc] initWithTitle:@"Continue Story" 
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self 
                                                                action:@selector(continueStoryButtonTapped)] autorelease];
    //self.continueStoryButton.enabled = NO;
}


- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
    
    [self setupToolbarAnimated:YES];
	
	// Table View stuff
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView reloadData];
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GameState *currentGame = [GameState currentGame];
    return [currentGame numScavengerItemsForNode:[currentGame activeNodeIdentifier]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScavengerItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    GameState *currentGame = [GameState currentGame];
    NSArray *items = [currentGame scavengerItemsForNode:[currentGame activeNodeIdentifier]];
    
    // Configure the cell's title and put a checkmark if the item has been found
    cell.textLabel.text = [currentGame optionalNodeTitle:[items objectAtIndex:indexPath.row]];
    BOOL checked = [currentGame scavengerItem:[items objectAtIndex:indexPath.row] 
                              wasFoundForNode:[currentGame activeNodeIdentifier]];
	cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.navigationItem.backBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"List" 
									  style:UIBarButtonItemStylePlain 
									 target:nil 
									 action:nil] autorelease];
    
    GameState *currentGame = [GameState currentGame];
    NSArray *items = [currentGame scavengerItemsForNode:[currentGame activeNodeIdentifier]];
    
    [currentGame playerSelectedScavengerItem:[items objectAtIndex:indexPath.row]];
}

#pragma mark -

- (void) dealloc
{
    [itemsFoundButton release];
    [continueStoryButton release];
    [super dealloc];
}


@end
