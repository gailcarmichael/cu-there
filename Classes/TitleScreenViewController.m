//
//  TitleScreenViewController.m
//  QRQuest2
//
//  Created by Gail on 12-10-23.
//  Copyright 2012 GailCarmichael. All rights reserved.
//

#import "TitleScreenViewController.h"

#import "GameState.h"
#import "GraphNodeViewController.h"
#import "RoleSelectionTableViewController.h"


@implementation TitleScreenViewController

@synthesize welcomeLabel, playerRoleLabel, selectRoleButton, startGameButton;


- (id)init
{
    self = [super init];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [welcomeLabel release];
    [playerRoleLabel release];
    [selectRoleButton release];
    [startGameButton release];
    
    [super dealloc];
}



#pragma mark - UI event handlers

- (void) selectRoleButtonTouched
{
    RoleSelectionTableViewController *setupView = [[RoleSelectionTableViewController alloc] init];
    [self.navigationController pushViewController:setupView animated:YES];
}

- (void) startGameButtonTouched
{
    [[GameState currentGame] startGame];
}


#pragma mark - UI updating

- (void) updateLabels
{
    GameState *game = [GameState currentGame];
    
    NSString * welcomeMsg = [NSString stringWithFormat:@"Welcome to\n%@", game.gameName];
    self.welcomeLabel.text = welcomeMsg;
    
    PlayerRole *role = [game activePlayerRole];
    NSString *roleMsg;
    if (role == nil)
    {
        roleMsg = @"Please choose your faculty.";
    }
    else
    {
        roleMsg = [NSString stringWithFormat:@"Your faculty: %@", role.roleName];
    }
    self.playerRoleLabel.text = roleMsg;
}

- (void) updateButtons
{
    // If there is no player role yet, can't start the game
    
    if ([[GameState currentGame] activePlayerRole] == nil)
    {
        self.startGameButton.enabled = NO;
        self.startGameButton.alpha = 0.4f;
    }
    else
    {
        self.startGameButton.enabled = YES;
        self.startGameButton.alpha = 1.0f;
    }
}


#pragma mark - Model updating

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType
{
    BOOL shouldCancelRemaining = NO;
    
    if (updateType == e_ModelUpdate_GameStarted)
    {
        GraphNodeViewController *vc = [[GraphNodeViewController alloc] initWithNodeID:[[GameState currentGame] activeNodeIdentifier]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (updateType == e_ModelUpdate_NewActivePlayerRole)
    {
        [self updateLabels];
        [self updateButtons];
    }
    
    return shouldCancelRemaining;
}


#pragma mark - View lifecycle

- (void) loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"TitleScreenViewController" owner:self options:nil] lastObject];
    
    // Save references to UI objects
    
    self.welcomeLabel = (UILabel *)[self.view viewWithTag:101];
    self.playerRoleLabel = (UILabel *)[self.view viewWithTag:102];
    
    self.selectRoleButton = (UIButton *)[self.view viewWithTag:201];
    self.startGameButton = (UIButton *)[self.view viewWithTag:202];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add ourselves as an observer
    [[GameState currentGame] registerObserver:self];
    
    // Add selectors for pushing buttons
    [self.selectRoleButton addTarget:self action:@selector(selectRoleButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.startGameButton addTarget:self action:@selector(startGameButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self updateLabels];
    [self updateButtons];
    
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    // Should this screen be bypassed?
    // If we are loading a game rather than starting a new one, then yes.
    
    if (![[GameState currentGame] isANewGame])
    {
        [[GameState currentGame] startGame];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    // Remove ourselves as an observer
    [[GameState currentGame] deregisterObserver:self];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
