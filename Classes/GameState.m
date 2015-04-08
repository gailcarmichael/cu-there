//
//  GameState.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "GameState.h"

#import "Graph.h"
#import "GraphNode.h"

#import "SimpleNodeContent.h"
#import "VirtualObjectNodeContent.h"
#import "ScavengerListNodeContent.h"
#import "ChooseYourPathNodeContent.h"


static GameState *currentGame = nil;


@implementation GameState

@synthesize gameName, teams, playerRoles;


- (id) initWithName:(NSString *)newName andGraph:(Graph *)newGraph
{
	self = [super init];
	if (self)
	{
        gameLoadedFromFile = NO;
        gameStarted = NO;
        
		gameName = newName;
		[gameName retain];
		
		teams = [NSMutableDictionary dictionaryWithCapacity:5];
		[teams retain];
		
		graph = newGraph;
		[graph retain];
		
		observers = [NSMutableSet setWithCapacity:5];
		[observers retain];
        
        playerRoles = [NSMutableArray arrayWithCapacity:5];
        [playerRoles retain];
        
        activePlayer = nil;
        
	}
	return self;
}


- (void) resetCurrentGame
{
    // Reset the player
    [activePlayer resetCurrentGame];
    [activePlayer setRootNode:[graph getRootNode]];
    
    // Reset the graph
    [graph resetCurrentGame];
    
    // Mark that it's a fresh new game
    gameLoadedFromFile = NO;
    gameStarted = NO;
    
    // Tell observers we have reset the game
    [self updateObservers:e_ModelUpdate_ResetGame];
    
    
    // Delete saved game file
    NSError *error;
    if ([[NSFileManager defaultManager] removeItemAtPath:[@"~/Documents" stringByExpandingTildeInPath] error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    // Show contents of Documents directory
    NSLog(@"Documents directory: %@",
          [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"~/Documents" stringByExpandingTildeInPath] error:&error]);
}


- (BOOL) isANewGame
{
    return !gameLoadedFromFile;
}


- (void) startGame
{
    gameStarted = YES;
    [self updateObservers:e_ModelUpdate_GameStarted];
}

- (BOOL) isGameInProgress
{
    return gameStarted;
}


- (void) dealloc
{
	[gameName release];
	[teams release];
	
	[graph release];
	
	[observers release];
    
    [playerRoles release];
    [activePlayer release];
	
	[super dealloc];
}


#pragma mark - Team and player


- (void) addTeam:(Team *)team
{
    [teams setObject:team forKey:team.teamName];
}


- (void) player:(Player *)player joinedTeam:(NSString *)name
{
	Team *team = [teams objectForKey:name];
	
	if (!team)
	{
		team = [[Team alloc] initWithName:name];
		[teams setObject:team forKey:name];
	}
	
	[team playerDidJoinTeam:player];
}


- (BOOL) activePlayerExists
{
    return activePlayer != nil;
}


- (void) setActivePlayer:(Player *)player
{
    [activePlayer release];
    activePlayer = player;
    [activePlayer retain];
    
    [activePlayer setRootNode:[graph getRootNode]];
}


- (PlayerRole *)activePlayerRole
{
    return activePlayer.role;
}

- (void) setActivePlayerRole:(PlayerRole *)newRole
{
    activePlayer.role = newRole;
    [self updateObservers:e_ModelUpdate_NewActivePlayerRole];
}


- (void) createAndSetActiveDefaultPlayerWithRole:(PlayerRole *)role
{
    // TODO: Teams will need to be initialized properly
    Team *team = [[[Team alloc] initWithName:@"DefaultTeam"] autorelease];
    [self addTeam:team];
    
    Player *player = [[[Player alloc] initWithName:@"DefaultPlayer" andRole:role] autorelease];
    [self player:player joinedTeam:team.teamName];
    [self setActivePlayer:player];
}


#pragma mark - Graph and nodes


- (NSString *) activeNodeIdentifier
{
	return graph.currentlyActiveNode.nodeIdentifier;
}

- (NSString *) lastNodeSoFarIdentifier
{
    int index = [activePlayer indexOfLastNode];
    return [activePlayer visitedNodeWithIndex:index].nodeIdentifier;
}


- (BOOL) isNodeLastSoFar:(NSString *)nodeID
{
    // Check with the current player to see what index this
    // node ID is at
    
    int index = [activePlayer indexOfVisitedNode:nodeID];
    return (index == [activePlayer indexOfLastNode]);
}


- (BOOL) isNodeLast:(NSString *)nodeID
{
    GraphNode *node = [graph nodeWithID:nodeID];
    return node.content.lastLocation;
}


- (BOOL) isNodeFirst:(NSString *)nodeID
{
    // The node is first if its index is 0 or if there are no visited nodes yet
    
    int index = [activePlayer indexOfVisitedNode:nodeID];
    return index == 0 || [activePlayer numberOfVisitedNodes] == 0;
}


- (void) goToPreviousNode
{
    NSString *nodeID = graph.currentlyActiveNode.nodeIdentifier;
    if (![self isNodeFirst:nodeID])
    {
        int index = [activePlayer indexOfVisitedNode:nodeID];
        [graph transitionToNode:[activePlayer visitedNodeWithIndex:index-1]];
        [self updateObservers:e_ModelUpdate_CurrentStoryNode];
    }
}


- (void) goToNextNode
{
    NSString *nodeID = graph.currentlyActiveNode.nodeIdentifier;
    if (![self isNodeLastSoFar:nodeID])
    {
        int index = [activePlayer indexOfVisitedNode:nodeID];
        [graph transitionToNode:[activePlayer visitedNodeWithIndex:index+1]];
        [self updateObservers:e_ModelUpdate_CurrentStoryNode];
    }
}


- (void) goToLastNode
{
    NSString *nodeID = graph.currentlyActiveNode.nodeIdentifier;
    if (![self isNodeLastSoFar:nodeID])
    {
        [graph transitionToNode:[activePlayer visitedNodeWithIndex:[activePlayer indexOfLastNode]]];
        [self updateObservers:e_ModelUpdate_CurrentStoryNode];
    }
}


- (void) doPlayer:(Player *)player visitNodeWithID:(NSString *)nodeID
{
    // Get the player (may not be the active player) to visit the given node
    // next.  This is particularly useful when loading game state, since we
    // don't want to expose the graph from the game.
    
    GraphNode *node = [graph nodeWithID:nodeID];
    if (node)
    {
        [player visitNode:node];
    }
}


- (void) setRootNode:(NSString *)nodeID
{
    [graph setRootNode:nodeID];
    [activePlayer setRootNode:[graph nodeWithID:nodeID]];
}


- (NSString *) descriptionFileNameForNode:(NSString *)nodeID
{
    return [graph descriptionFileNameForNode:nodeID];
}


- (e_NodeContent_Type) contentTypeForNode:(NSString *)nodeID
{
    return [graph contentTypeForNode:nodeID];
}


- (e_NodeContent_Type) contentTypeForPreviousNode:(NSString *)nodeID
{
    e_NodeContent_Type type = e_NodeContent_Simple; // default
    
    if (![self isNodeFirst:nodeID])
    {
        int index = [activePlayer indexOfVisitedNode:nodeID];
        GraphNode *prevNode = [activePlayer visitedNodeWithIndex:index-1];
        type = prevNode.content.type;
    }
    
    return type;
}


- (NSString *) optionalNodeTitle:(NSString *)nodeID
{
    return [graph optionalNodeTitle:nodeID];
}


- (int) percentProgressForNode:(NSString *)nodeID
{
    return [graph percentProgressForNode:nodeID];
}


- (int) numChildrenForNode:(NSString *)nodeID
{
    return [graph numChildrenForNode:nodeID];
}


- (NSArray *) childNodeIdentifiersForNode:(NSString *)nodeID
{
    return [graph childNodeIdentifiersForNode:nodeID];
}


- (int) numScavengerItemsForNode:(NSString *)nodeID
{
    int num = 0;
    
    if ([self contentTypeForNode:nodeID] == e_NodeContent_ScavengerList)
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
        num = [content.itemNodeIDList count];
    }
    
    return num;
}


- (NSArray *) scavengerItemsForNode:(NSString *)nodeID
{
    NSArray * list = nil;
    
    if ([self contentTypeForNode:nodeID] == e_NodeContent_ScavengerList)
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
        list = content.itemNodeIDList;
    }
    
    return list;
}


- (int) numScavengerItemsFoundForNode:(NSString *)nodeID
{
    int num = 0;
    
    if ([self contentTypeForNode:nodeID] == e_NodeContent_ScavengerList)
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
        num = [content.itemsFound count];
    }
    
    return num;
}


- (int) minNumScavengerItemsToFindForNode:(NSString *)nodeID
{
    int num = 0;
    
    if ([self contentTypeForNode:nodeID] == e_NodeContent_ScavengerList)
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
        num = content.minItemsToFind;
    }
    
    return num;
}


- (BOOL) scavengerCanContinueStory:(NSString *)nodeID
{
    return [self numScavengerItemsFoundForNode:nodeID] >= [self minNumScavengerItemsToFindForNode:nodeID];
}



- (BOOL) scavengerItem:(NSString *)item wasFoundForNode:(NSString *)nodeID
{
    BOOL found = NO;
    
    if ([self contentTypeForNode:nodeID] == e_NodeContent_ScavengerList)
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
        found = [content.itemsFound containsObject:item];
    }
    
    return found;
}


- (void) playerSelectedScavengerItem:(NSString *)nodeID
{
    if (graph.currentlyActiveNode.content.type == e_NodeContent_ScavengerList)
    {
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)graph.currentlyActiveNode.content;
        [content playerSelected:nodeID];
        
        [self updateObservers:e_ModelUpdate_SelectedScavengerListOption];
    }
}


- (NSString *) mostRecentScavengerListItemNodeID
{
    NSString * nodeID = nil;
    
    if (graph.currentlyActiveNode.content.type == e_NodeContent_ScavengerList)
    {
        ScavengerListNodeContent *content = (ScavengerListNodeContent *)graph.currentlyActiveNode.content;
        nodeID = content.lastItemSelectedNodeID;
    }
    
    return nodeID;
}


- (void) playerSelectedChooseYourPath:(NSString *)nodeID
{
    if (graph.currentlyActiveNode.content.type == e_NodeContent_ChooseYourPath)
    {
        ChooseYourPathNodeContent *content = (ChooseYourPathNodeContent *)graph.currentlyActiveNode.content;
        [content playerSelected:nodeID];
        
        [self updateObservers:e_ModelUpdate_SelectedChooseYourPathOption];
    }
}

- (NSString *) mostRecentChooseYourPathNodeID
{
    NSString * nodeID = nil;
    
    if (graph.currentlyActiveNode.content.type == e_NodeContent_ChooseYourPath)
    {
        ChooseYourPathNodeContent *content = (ChooseYourPathNodeContent *)graph.currentlyActiveNode.content;
        nodeID = content.lastNodeIDSelectedByPlayer;
    }
    
    return nodeID;
}


- (void) transitionToNextNode
{
    GraphNode *nextNode = [graph nextNodeIfTransitionAllowedForPlayer:activePlayer];
    if (nextNode)
    {
        [activePlayer visitNode:nextNode];
        [graph transitionToNode:nextNode];
        
        [self updateObservers:e_ModelUpdate_CurrentStoryNode];
    }
}


- (void) playerFoundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
    // First tell the graph, then check if a new node can be visited
    BOOL dataWasUsed = [graph player:activePlayer foundNewData:data forNodeID:nodeID];
    
    if (dataWasUsed)
    {
        // If the current node is a scavenger node, update the observers about
        // the fact that a new item was found
        if (graph.currentlyActiveNode.content.type == e_NodeContent_ScavengerList)
        {
            [self updateObservers:e_ModelUpdate_FoundScavengerItem];
        }
        // Only want to transition if it's not a scavenger node, since the player can
        // continue to find new hunt items if they want before moving on
        else
        {
            [self transitionToNextNode];
        }
    }
    
    
    
    if (!dataWasUsed)
    {
        // Inform observers that either the wrong data was found
        // or otherwise not used
        
        [self updateObservers:e_ModelUpdate_FoundIncorrectCode];
    }
}


#pragma mark - Observers


- (void) registerObserver:(id<GameObserver>) observer
{
	[observers addObject:observer];
}


- (void) deregisterObserver:(id<GameObserver>) observer
{
	[observers removeObject:observer];
}


- (void) updateObservers:(e_ModelUpdate_Type)updateType
{
	for (id<GameObserver> observer in observers)
	{
		BOOL shouldCancelRemaining = [observer modelDidChange:updateType];
        if (shouldCancelRemaining)
        {
            break;
        }
	}
}



#pragma mark -
#pragma mark Plist


- (void) saveToPlist:(NSString *)fileName
{
    // We don't need to save what getGameFromPlist already takes care of; it's
    // only the current game state (in terms of what the player has done) that
    // needs to be stored.
    
    
    // Store the following:
    // - whether the game is in progress or not
    // - active player info, including role and nodes visited
    // - graph's currently active node
    // - any scavenger items that were found
    // - chosen node for choose-your-path nodes
    
    
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithCapacity:5];
    
    
    
    // Game info
    
    [plist setObject:[NSNumber numberWithBool:[self isGameInProgress]] forKey:@"gameInProgress"];
    
    
   
    [activePlayer addInfoToPlist:plist];
    
    [plist setObject:graph.currentlyActiveNode.nodeIdentifier forKey:@"graphActiveNode"];
    
    
    NSMutableDictionary *foundItems = [NSMutableDictionary dictionaryWithCapacity:3];
    NSMutableDictionary *chosenPaths = [NSMutableDictionary dictionaryWithCapacity:3];
    
    for (int nodeNum=0; nodeNum <= [activePlayer indexOfLastNode]; nodeNum++)
    {
        GraphNode *node = [activePlayer visitedNodeWithIndex:nodeNum];
        
        if (node.content.type == e_NodeContent_ScavengerList)
        {
            ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
            [foundItems setObject:content.itemsFound forKey:node.nodeIdentifier];            
        }
        
        if (node.content.type == e_NodeContent_ChooseYourPath)
        {
            ChooseYourPathNodeContent *content = (ChooseYourPathNodeContent *)node.content;
            if (content.idOfChosenNode != nil)
            {
                [chosenPaths setObject:content.idOfChosenNode forKey:node.nodeIdentifier];
            }
        }
    }
    
    [plist setObject:foundItems forKey:@"scavengerNodesFoundItems"];
    [plist setObject:chosenPaths forKey:@"choiceNodesChosenPaths"];
    
    
    // Save to file!
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSLog(@"%@", finalFilePath);
    
    [plist writeToFile:finalFilePath atomically:YES];
    
    
    NSLog(@"Documents directory: %@",
          [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"~/Documents" stringByExpandingTildeInPath] error:nil]);
}


- (void) loadFromPlistAndOverwriteCurrentState:(NSString *)fileName
{
    // Eventually, it would make sense to be able to load individual games.
    // This code would have to be updated to make that possible.  For instance,
    // we could start saving the game definition plist filename with the game
    // state info so the game could be loaded as well when needed.  Multiple
    // players might be supported in the future as well.
    
    // For now, loading the plist will just assume the current game is of
    // the right type, and will overwrite any current state.  It will use
    // the active player.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *finalFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    
    
    // If file does not exist, nothing to load, so return
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalFilePath])
    {
        return;
    }    
    
    
    
    NSDictionary *gameState = [NSDictionary dictionaryWithContentsOfFile:finalFilePath];
    
    
    // If the game that was saved isn't in progress, nothing to do
    if (![[gameState objectForKey:@"gameInProgress"] boolValue])
    {
        NSLog(@"Trying to load a game not in progress - aborting.");
        return;
    }
    
    
        
    gameLoadedFromFile = YES;
        
        
    // Load player info...
    
    if (![self activePlayerExists])
    {
        [self createAndSetActiveDefaultPlayerWithRole:[PlayerRole roleWithName:@"Default"]];
    }
    
    [activePlayer loadInfoFromPlist:gameState];
    
    
    // Load info active node, path choices, and scavenger items...
    
    GraphNode *activeNode = [graph nodeWithID:[gameState objectForKey:@"graphActiveNode"]];
    [graph transitionToNode:activeNode];
    
    NSDictionary *foundDictionary = [gameState objectForKey:@"scavengerNodesFoundItems"];
    for (NSString *nodeID in [foundDictionary allKeys])
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        
        if (node.content.type == e_NodeContent_ScavengerList)
        {
            ScavengerListNodeContent *content = (ScavengerListNodeContent *)node.content;
            content.itemsFound = [[foundDictionary objectForKey:nodeID] mutableCopy];
        }
    }
    
    NSDictionary *chosenPathDictionary = [gameState objectForKey:@"scavengerNodesFoundItems"];
    for (NSString *nodeID in [chosenPathDictionary allKeys])
    {
        GraphNode *node = [graph nodeWithID:nodeID];
        
        if (node.content.type == e_NodeContent_ChooseYourPath)
        {
            ChooseYourPathNodeContent *content = (ChooseYourPathNodeContent *)node.content;
            content.idOfChosenNode = [chosenPathDictionary objectForKey:nodeID];
        }
    }
}


#pragma mark -
#pragma mark Class methods

+ (void) setCurrentGame:(GameState *)game
{
	[currentGame release];
	currentGame = game;
	[currentGame retain];
}

+ (GameState *) currentGame
{
	return currentGame;
}


+ (GameState *) getGameFromPlist:(NSString *)plistPathInBundle
{
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:plistPathInBundle];
	
	NSDictionary *storyDictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSString *name = [storyDictionary objectForKey:@"StoryName"];
    Graph *graph = [[[Graph alloc] init] autorelease];
    
    // Main game state, into which everything else goes
	GameState *game = [[[GameState alloc] initWithName:name andGraph:graph] autorelease];
    
    
    // Node types (if no type given, simple is assumed)
    NSDictionary *nodeTypeDictionary = [storyDictionary objectForKey:@"NodeTypes"];
    
    
    // Optional titles for secondary nodes (scavenger items, choose your path, virtual items, etc)
    NSDictionary *secondaryNodeTitleDictionary = [storyDictionary objectForKey:@"SecondaryNodeTitles"];
    
    
    // ID of the nodes that are the last locations (end of game nodes)
    NSArray *lastNodes = [storyDictionary objectForKey:@"LastNodes"];
    
    // Lists of scavenger items and the min to find for a scavenger hunt node
    NSDictionary *scavengerItemsDictionary = [storyDictionary objectForKey:@"ScavengerItems"];
    NSDictionary *scavengerMinItemsToFindDictionary = [storyDictionary objectForKey:@"ScavengerMinItemsToFind"];
    
    // Set of player roles allowed as preconditions for particular nodes
    NSDictionary *playerRolesForPreconditions = [storyDictionary objectForKey:@"PreconditionForRole"];
    
    
    
    
    // Save the player roles (if any)
    NSArray *playerRoleNames = [storyDictionary objectForKey:@"PlayerRoles"];
    for (NSString *roleName in playerRoleNames)
    {
        [game->playerRoles addObject:[PlayerRole roleWithName:roleName]];
    }
    
    
    // Code overrides (that is, the code players will scan if different from the node ID)
    NSDictionary *codeOverrideDictionary = [storyDictionary objectForKey:@"CodeOverrides"];
    
    
    // Node description files (add nodes to graph here)
    NSDictionary *nodeDescriptionDictionary = [storyDictionary objectForKey:@"NodeDescriptionFiles"];
    NSDictionary *nodePercentProgressDictionary = [storyDictionary objectForKey:@"PercentProgress"];
    for (NSString *nodeID in [nodeDescriptionDictionary allKeys])
    {
        // Assume a node is simple content unless stated otherwise
        NSString *contentType = [nodeTypeDictionary objectForKey:nodeID];
        GraphNodeContent *content;
        if ([contentType isEqualToString:@"ChooseYourPath"])
        {
            content = [[[ChooseYourPathNodeContent alloc] init] autorelease];
        }
        else if ([contentType isEqualToString:@"ScavengerList"])
        {
            ScavengerListNodeContent * scavengerContent = [[[ScavengerListNodeContent alloc] init] autorelease];
            scavengerContent.itemNodeIDList = [scavengerItemsDictionary objectForKey:nodeID];
            scavengerContent.minItemsToFind = [[scavengerMinItemsToFindDictionary objectForKey:nodeID] intValue];
            content = scavengerContent;
        }
        else if ([contentType isEqualToString:@"VirtualObject"])
        {
            content = [[[VirtualObjectNodeContent alloc] init] autorelease];
        }
        else // simple or undefined
        {
            content = [[[SimpleNodeContent alloc] init] autorelease];
        }
        
        NSString *descFilePath = [storyDictionary objectForKey:@"DescriptionPath"];
        content.descriptionFile = [descFilePath stringByAppendingPathComponent:[nodeDescriptionDictionary objectForKey:nodeID]];
        
        content.owner = [graph addNewNodeWithID:nodeID andContent:content];
        content.owner.percentProgress = [[nodePercentProgressDictionary objectForKey:nodeID] intValue];
        
        content.optionalTitle = [secondaryNodeTitleDictionary objectForKey:nodeID];
        content.optionalCodeOverride = [codeOverrideDictionary objectForKey:nodeID];
        
        if ([lastNodes containsObject:nodeID])
        {
            content.lastLocation = YES;
        }
        else
        {
            content.lastLocation = NO;
        }
        
        // Add the allowed roles for the node (will be a precondition)
        NSString *roleNames = [playerRolesForPreconditions objectForKey:nodeID];
        for (NSString *name in [roleNames componentsSeparatedByString:@","])
        {
            [content.playerRolesAllowed addObject:[PlayerRole roleWithName:name]];
        }
    }
    
    
    // Set up the children
    NSDictionary *parentsDictionary = [storyDictionary objectForKey:@"NodeParents"];
    for (NSString *childID in [parentsDictionary allKeys])
    {
        // In some cases there may be more than one parent (so, for example, two different
        // paths can eventually converge)
        NSArray *parentIDs = [[parentsDictionary objectForKey:childID] componentsSeparatedByString:@","];
        
        for (NSString *parentID in parentIDs)
        {
            [graph setChild:childID forParent:parentID];
        }
    }
    
    
    // Set the root node
    NSString *rootID = [storyDictionary objectForKey:@"RootNode"];
    [game setRootNode:rootID];
    
    
    
    // Create a default player with no role
    [game createAndSetActiveDefaultPlayerWithRole:nil];
    
    
	
	return game;
}


@end





