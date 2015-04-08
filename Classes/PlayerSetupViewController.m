//
//  PlayerRoleChoiceViewController.m
//  QRQuest2
//
//  Created by Gail on 11-07-22.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "PlayerSetupViewController.h"
#import "GameState.h"


@implementation PlayerSetupViewController

// Private variable
UIViewController *parentController;



- (id) initWithParentController:(UIViewController *)parent
{
    self = [super init];
    if (self) 
    {
        parentController = parent;
        [parentController retain];
    }
    return self;
}

- (void)dealloc
{
    [parentController release];
    [super dealloc];
}



- (void) presentPlayerSetupActionSheet:(UIViewController *)sender
{
    // Build the action sheet, present it
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self 
                                  cancelButtonTitle:nil destructiveButtonTitle:nil 
                                  otherButtonTitles:@"Select Faculty", nil];
    
    [actionSheet showInView:self.view];
    
    UIPickerView *pickerView = [[[UIPickerView alloc] init] autorelease];
    pickerView.tag = 101;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    [actionSheet addSubview:pickerView];
}


- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    GameState *game = [GameState currentGame];
    return [game.playerRoles count];
}


- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    GameState *game = [GameState currentGame];
    PlayerRole *role = [game.playerRoles objectAtIndex:row];
    return role.roleName;
}


- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Tell the game what player role was selected, release the action sheet, and start the regular UI
    
    UIPickerView *picker = (UIPickerView *)[actionSheet viewWithTag:101];
    GameState *game = [GameState currentGame];
    
    PlayerRole *role = [[game playerRoles] objectAtIndex:[picker selectedRowInComponent:0]];
    
    [game setActivePlayerRole:role];
    
    [parentController viewWillAppear:NO];
    
    [actionSheet release];
    [self release];
}




@end
