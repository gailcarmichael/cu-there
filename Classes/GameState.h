//
//  GameState.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"
#import "Team.h"
#import "GraphNodeContent.h"


typedef enum
{
    e_ModelUpdate_ResetGame,
    e_ModelUpdate_GameStarted,
    
	e_ModelUpdate_NewTeam,
	e_ModelUpdate_NewPlayer,
    e_ModelUpdate_NewActivePlayerRole,
    
    e_ModelUpdate_SelectedChooseYourPathOption,
    e_ModelUpdate_SelectedScavengerListOption,
    
    e_ModelUpdate_CurrentStoryNode,
    e_ModelUpdate_FoundScavengerItem,
    e_ModelUpdate_FoundIncorrectCode,
	
} e_ModelUpdate_Type;


@protocol GameObserver

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType;

@end




@interface GameState : NSObject 
{
	NSString *gameName;
	NSMutableDictionary *teams;
    NSMutableArray *playerRoles;
    
    ////
    // Protected members
	
    Graph *graph;
	NSMutableSet *observers;
    
    Team *activeTeam;
    Player *activePlayer;
    
    BOOL gameLoadedFromFile;
    BOOL gameStarted;
    
}

@property (nonatomic, retain) NSString *gameName;
@property (nonatomic, readonly) NSMutableDictionary *teams;
@property (nonatomic, readonly) NSMutableArray *playerRoles;


- (id) initWithName:(NSString *)newName andGraph:(Graph *)newGraph;

- (void) resetCurrentGame;
- (BOOL) isANewGame;

- (void) startGame;
- (BOOL) isGameInProgress;

- (void) addTeam:(Team *)team;
- (void) player:(Player *)player joinedTeam:(NSString *)name;
- (BOOL) activePlayerExists;
- (void) setActivePlayer:(Player *)player;
- (PlayerRole *) activePlayerRole;
- (void) setActivePlayerRole:(PlayerRole *)newRole;

- (void) createAndSetActiveDefaultPlayerWithRole:(PlayerRole *)role;

- (NSString *) activeNodeIdentifier;
- (NSString *) lastNodeSoFarIdentifier;

- (BOOL) isNodeLastSoFar:(NSString *)nodeID;
- (BOOL) isNodeLast:(NSString *)nodeID;
- (BOOL) isNodeFirst:(NSString *)nodeID;

- (void) goToPreviousNode;
- (void) goToNextNode;
- (void) goToLastNode;

- (void) doPlayer:(Player *)player visitNodeWithID:(NSString *)nodeID;

- (void) setRootNode:(NSString *)nodeID;
- (NSString *) descriptionFileNameForNode:(NSString *)nodeID;
- (e_NodeContent_Type) contentTypeForNode:(NSString *)nodeID;
- (e_NodeContent_Type) contentTypeForPreviousNode:(NSString *)nodeID;
- (NSString *) optionalNodeTitle:(NSString *)nodeID;
- (int) percentProgressForNode:(NSString *)nodeID;

- (int) numChildrenForNode:(NSString *)nodeID;
- (NSArray *) childNodeIdentifiersForNode:(NSString *)nodeID;

- (int) numScavengerItemsForNode:(NSString *)nodeID;
- (NSArray *) scavengerItemsForNode:(NSString *)nodeID;
- (int) numScavengerItemsFoundForNode:(NSString *)nodeID;
- (int) minNumScavengerItemsToFindForNode:(NSString *)nodeID;
- (BOOL) scavengerCanContinueStory:(NSString *)nodeID;
- (BOOL) scavengerItem:(NSString *)item wasFoundForNode:(NSString *)nodeID;

- (void) playerSelectedScavengerItem:(NSString *)nodeID;
- (NSString *) mostRecentScavengerListItemNodeID;

- (void) playerSelectedChooseYourPath:(NSString *)nodeID;
- (NSString *) mostRecentChooseYourPathNodeID;

- (void) transitionToNextNode;
- (void) playerFoundNewData:(NSString *)data forNodeID:(NSString *)nodeID;

- (void) registerObserver:(id<GameObserver>) observer;
- (void) deregisterObserver:(id<GameObserver>) observer;
- (void) updateObservers:(e_ModelUpdate_Type)updateType;

- (void) saveToPlist:(NSString *)fileName;
- (void) loadFromPlistAndOverwriteCurrentState:(NSString *)fileName;


// Class methods

+ (void) setCurrentGame:(GameState *)game;
+ (GameState *) currentGame;

+ (GameState *) getGameFromPlist:(NSString *)plistPathInBundle;


@end
