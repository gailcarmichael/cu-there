//
//  NodeChoiceTableViewController.m
//  QRQuest2
//
//  Created by Gail on 11-05-13.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "NodeChoiceTableViewController.h"
#import "GameState.h"
#import "SimpleGraphNodeViewController.h"


@implementation NodeChoiceTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Model updating

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType
{
    BOOL shouldCancelRemaining = NO;
    
    if (updateType == e_ModelUpdate_SelectedChooseYourPathOption)
    {
        GameState *currentGame = [GameState currentGame];
        
        SimpleGraphNodeViewController *controller =
        [[SimpleGraphNodeViewController alloc] initWithNodeID: [currentGame mostRecentChooseYourPathNodeID]];
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    return shouldCancelRemaining;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GameState *game = [GameState currentGame];
    
    // Add ourselves as an observer
    [game registerObserver:self];
    
    self.title = @"Choose Your Path";
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GameState *currentGame = [GameState currentGame];
    return [currentGame numChildrenForNode:[currentGame activeNodeIdentifier]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChooseYourPathCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell
    GameState *currentGame = [GameState currentGame];
    NSArray *children = [currentGame childNodeIdentifiersForNode:[currentGame activeNodeIdentifier]];
    cell.textLabel.text = [currentGame optionalNodeTitle:[children objectAtIndex:indexPath.row]];
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.navigationItem.backBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"Choices" 
									  style:UIBarButtonItemStylePlain 
									 target:nil 
									 action:nil] autorelease];
    
    GameState *currentGame = [GameState currentGame];
    NSArray *children = [currentGame childNodeIdentifiersForNode:[currentGame activeNodeIdentifier]];
    
    [currentGame playerSelectedChooseYourPath:[children objectAtIndex:indexPath.row]];
}

@end
