//
//  GraphNodeViewController.m
//  QRQuest2
//
//  Created by Gail on 11-04-25.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "GraphNodeViewController.h"
#import "NodeChoiceTableViewController.h"
#import "NodeListTableViewController.h"
#import "PlayerSetupViewController.h"
#import "TitleScreenViewController.h"


@interface GraphNodeViewController (private)

// Private selectors here

- (void) updateCurrentStoryNode;
- (void) updateNavigationButtons;

@end


@implementation GraphNodeViewController

@synthesize resetButton, backButton, forwardButton, endButton, seeChoicesButton, seeListButton;

const int RESET_BUTTON_YES_INDEX = 0;



- (id) initWithNodeID:(NSString *)newNodeID
{
    self = [super initWithNodeID:newNodeID];
    if (self)
    {

    }
    return self;
}


- (void)dealloc
{
    [resetButton release];
    [backButton release];
    [forwardButton release];
    [endButton release];
    [seeChoicesButton release];
    [seeListButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UI event handlers


- (void) seeChoicesButtonTapped
{
    self.navigationItem.backBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"Back" 
									  style:UIBarButtonItemStylePlain 
									 target:nil 
									 action:nil] autorelease];
    
    NodeChoiceTableViewController *controller = [[NodeChoiceTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void) seeListButtonTapped
{
    self.navigationItem.backBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"Back" 
									  style:UIBarButtonItemStylePlain 
									 target:nil 
									 action:nil] autorelease];
    
    NodeListTableViewController *controller = [[NodeListTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void) backButtonTapped
{
    [[GameState currentGame] goToPreviousNode];
}


- (void) forwardButtonTapped
{
    [[GameState currentGame] goToNextNode];
}


- (void) endButtonTapped
{
    [[GameState currentGame] goToLastNode];
}

- (void) resetButtonTapped
{
    UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle: @"Are You Sure?" 
                                                         message: @"Restarting the game will result in losing all of your progress." 
                                                        delegate: self 
                                               cancelButtonTitle: nil
                                               otherButtonTitles: @"Restart", @"Cancel", nil];  
    [resetAlert show];
    [resetAlert release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == RESET_BUTTON_YES_INDEX)
    {
        [self viewWillDisappear:YES];
        [[GameState currentGame] resetCurrentGame];
        [self viewWillAppear:YES];
    }
}



#pragma mark - View updating


- (void) setupTitle
{
    GameState *game = [GameState currentGame];
    int progress = [game percentProgressForNode:[game lastNodeSoFarIdentifier]];
    
    self.title = [[game gameName] stringByAppendingFormat:@" (%d%%)", progress];
}


- (void) setupToolbarAnimated:(BOOL)animated
{
    NSString *activeNodeID = [[GameState currentGame] activeNodeIdentifier];
    
    
    UIBarButtonItem *sideSpace =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil
                                                   action:nil] autorelease];
	sideSpace.width = 20;
    
    
    UIBarButtonItem *middleSpace =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil
                                                   action:nil] autorelease];
	middleSpace.width = 125;
    
    
    UIBarButtonItem *betweenIconSpace = 
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                   target:nil 
                                                   action:nil] autorelease];
	betweenIconSpace.width = 20;
	
	UIBarButtonItem *flexiblespace = 
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                   target:nil 
                                                   action:nil] autorelease];

    
    // What button to use depends on the type of node being shown
   
    e_NodeContent_Type type = [[GameState currentGame] contentTypeForNode:activeNodeID];
    UIBarButtonItem *button = nil;
    
    if (type == e_NodeContent_ChooseYourPath)
    {
        button = self.seeChoicesButton;
    }
    else if (type == e_NodeContent_Simple)
    {
        button = self.scanBarButton;
    }
    else if (type == e_NodeContent_ScavengerList)
    {
        button = self.seeListButton;
    }
    
    
    NSArray *items = 
    [[[NSArray alloc] initWithObjects:
      sideSpace,
      self.resetButton, betweenIconSpace, self.backButton,
      flexiblespace,
      button,
      flexiblespace,
      self.forwardButton, betweenIconSpace, self.endButton,
      sideSpace, nil]
     autorelease];
	
    [self setToolbarItems:items animated:animated];
}


- (void) updateNavigationButtons
{
    NSString *activeNodeID = [[GameState currentGame] activeNodeIdentifier];
    
    self.resetButton.enabled = YES;
    
    self.backButton.enabled = YES;
    self.forwardButton.enabled = YES;
    self.endButton.enabled = YES;
    
    self.scanBarButton.enabled = NO;
    scanButton.enabled = NO;
    
    
    BOOL first = [[GameState currentGame] isNodeFirst:activeNodeID];
    BOOL last = [[GameState currentGame] isNodeLastSoFar:activeNodeID];
    BOOL end = [[GameState currentGame] isNodeLast:activeNodeID];
    
    if (first)
    {
        self.backButton.enabled = NO;
    }
    
    if (last)
    {
        self.forwardButton.enabled = NO;
        self.endButton.enabled = NO;
        
        self.scanBarButton.enabled = YES;
        scanButton.enabled = YES;
    }
    
    if (end)
    {
        self.scanBarButton.enabled = NO;
        scanButton.enabled = NO;
    }
}



#pragma mark - Model updating

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType
{
    BOOL shouldCancelRemaining = NO;
    
    if (updateType == e_ModelUpdate_ResetGame)
    {
        // Make sure we are at the bottom level of the stack
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    
    if (updateType == e_ModelUpdate_CurrentStoryNode)
    {
        // Refresh the web view and enable/disable buttons accordingly
        [self setupToolbarAnimated:NO];
        [self updateCurrentStoryNode];
        [self updateNavigationButtons];
    }
    
    
    if (updateType == e_ModelUpdate_FoundIncorrectCode)
    {
        UIAlertView *wrongCode = [[UIAlertView alloc] initWithTitle: @"Sorry!"
                                                            message: @"This is not the code you were looking for. Keep trying!" 
                                                           delegate: nil 
                                                  cancelButtonTitle: @"OK" 
                                                  otherButtonTitles: nil];   
        
        [wrongCode show];
        [wrongCode release];
        
        shouldCancelRemaining = YES;
    }
    
    return shouldCancelRemaining;
}

- (void) updateCurrentStoryNode
{
    NSString *activeNodeID = [[GameState currentGame] activeNodeIdentifier];
    NSString *fileName = [[GameState currentGame] descriptionFileNameForNode:activeNodeID];
    [self setWebViewContent:fileName];
    [self setupTitle];
}



#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.title = [[GameState currentGame] gameName];
    self.navigationItem.hidesBackButton = YES;
    
    
    self.resetButton =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                   target:self 
                                                   action:@selector(resetButtonTapped)] autorelease];
    
    
	self.backButton =
    [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-prev.png"]
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(backButtonTapped)] autorelease];
	
	self.backButton.enabled = NO;
	
	self.forwardButton =
    [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-next.png"]
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(forwardButtonTapped)] autorelease];
	self.forwardButton.enabled = NO;
    
    
    
	
	self.endButton =
    [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-last.png"] 
                                      style:UIBarButtonItemStylePlain 
                                     target:self 
                                     action:@selector(endButtonTapped)] autorelease];
	self.endButton.enabled = NO;
     
	
    
    
    // Scan button is set up in superclass
    
    
    
    ///
    // Get the alternate center buttons ready...
    
    UIButton *choicesButtonTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *choicesButtonImageNormal = [UIImage imageNamed:@"CenterButton-Choice.png"];
    UIImage *choicesButtonImageDisabled = [UIImage imageNamed:@"CenterButton-ChoiceDisabled.png"];
    
    [choicesButtonTemp setImage:choicesButtonImageNormal forState:UIControlStateNormal];
    [choicesButtonTemp setImage:choicesButtonImageDisabled forState:UIControlStateDisabled];
    
    choicesButtonTemp.frame = CGRectMake(0, 0, choicesButtonImageNormal.size.width, choicesButtonImageNormal.size.height);
    [choicesButtonTemp addTarget:self action:@selector(seeChoicesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *choicesButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, choicesButtonImageNormal.size.width, choicesButtonImageNormal.size.height)];
    
    [choicesButtonView addSubview:choicesButtonTemp];
    
    self.seeChoicesButton = [[UIBarButtonItem alloc] initWithCustomView:choicesButtonView];
    
    
    UIButton *listButtonTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *listButtonImageNormal = [UIImage imageNamed:@"CenterButton-List.png"];
    UIImage *listButtonImageDisabled = [UIImage imageNamed:@"CenterButton-ListDisabled.png"];
    
    [listButtonTemp setImage:listButtonImageNormal forState:UIControlStateNormal];
    [listButtonTemp setImage:listButtonImageDisabled forState:UIControlStateDisabled];
    
    listButtonTemp.frame = CGRectMake(0, 0, listButtonImageNormal.size.width, listButtonImageNormal.size.height);
    [listButtonTemp addTarget:self action:@selector(seeListButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *listButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, listButtonImageNormal.size.width, listButtonImageNormal.size.height)];
    
    [listButtonView addSubview:listButtonTemp];
    
    self.seeListButton = [[UIBarButtonItem alloc] initWithCustomView:listButtonView];
}

- (void)viewDidUnload
{
    self.resetButton = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.endButton = nil;
    self.seeChoicesButton = nil;
    self.seeListButton = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    // Update the views etc
    [self setupTitle];
    [self setupToolbarAnimated:NO];
    [self updateCurrentStoryNode];
    [self updateNavigationButtons];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
