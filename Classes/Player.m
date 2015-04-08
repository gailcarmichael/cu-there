//
//  Player.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "Player.h"
#import "GameState.h"


@implementation Player

@synthesize role, name;
@synthesize virtualItems;


- (id) initWithName:(NSString *)newName andRole:(PlayerRole *)newRole
{
	self = [super init];
	if (self)
	{
		name = newName;
		[newName retain];
		
		role =  newRole;
		[role retain];
		
		nodesVisited = [NSMutableArray arrayWithCapacity:10];
        [nodesVisited retain];
		
		timeStartedPlaying = [NSDate date];
		[timeStartedPlaying retain];
	}
	return self;
}


- (void) resetCurrentGame
{    
    // Clear any virtual items
    [virtualItems removeAllObjects];
    
    // For each node visited, ensure all checklists etc are cleared
    for (GraphNode * node in nodesVisited)
    {
        [node.content reset];
    }
    
    // Clear the nodes visited
    [nodesVisited removeAllObjects];
    
    // Reset the time started playing
    [timeStartedPlaying release];
    timeStartedPlaying = [NSDate date];
    [timeStartedPlaying retain];
    
    // Clear the player's role
    self.role = nil;
}


- (BOOL) hasVirtualItem:(VirtualItem *)item
{
	return [virtualItems containsObject:item];
}


- (void) addVirtualItem:(VirtualItem *)item
{
	[virtualItems addObject:item];
}


- (void) setRootNode:(GraphNode *)node
{
    [nodesVisited insertObject:node atIndex:0];
}


- (void) visitNode:(GraphNode *)node
{
    [nodesVisited addObject:node];
}


- (BOOL) canVisitThisNode:(GraphNode *)newNode fromNode:(GraphNode *)currNode
{
    // For now, can only visit a new node if the current node is last in the list
    return ([self indexOfVisitedNode:currNode.nodeIdentifier] == [self indexOfLastNode]);
}


- (int) numberOfVisitedNodes
{
    return [nodesVisited count];
}


- (int) indexOfVisitedNode:(NSString *)nodeID
{
    int index = -1;
    
    int numNodes = [nodesVisited count];
    for (int i=0; i < numNodes; i++)
    {
        if ([[[nodesVisited objectAtIndex:i] nodeIdentifier] isEqualToString:nodeID])
        {
            index = i;
            break;
        }
    }
    
    return index;
}


- (GraphNode *) visitedNodeWithIndex:(int)index
{
    if (index >= 0 && index < [nodesVisited count])
    {
        return [nodesVisited objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}


- (int) indexOfLastNode
{
    return [nodesVisited count] - 1;
}


- (NSTimeInterval) timeInPlaySoFar
{
	return [timeStartedPlaying timeIntervalSinceNow];
}


- (void) addInfoToPlist:(NSMutableDictionary *)plist
{
    // Store player name
    [plist setValue:self.name forKey:@"playerName"];
    
    // Store name of player role
    [plist setValue:self.role.roleName forKey:@"playerRoleName"];
    
    // Gather and store names of nodes visited (nodeIdentifiers)
    NSMutableArray *nodeNames = [NSMutableArray arrayWithCapacity:5];
    for (GraphNode * node in nodesVisited)
    {
        [nodeNames addObject:node.nodeIdentifier];
    }
    [plist setValue:nodeNames forKey:@"playerVisitedNodeIdentifiers"];
}


- (void) loadInfoFromPlist:(NSDictionary *)plist
{
    // Restore player name
    self.name = [plist objectForKey:@"playerName"];
    
    // Restore player role
    self.role = [PlayerRole roleWithName:[plist objectForKey:@"playerRoleName"]];
    
    
    // Restore list of nodes visited
    
    NSArray *nodeNames = [plist objectForKey:@"playerVisitedNodeIdentifiers"];
    
    [nodesVisited release];
    nodesVisited = [NSMutableArray arrayWithCapacity:[nodeNames count]];
    [nodesVisited retain];
    
    GameState *currentGame = [GameState currentGame];
    
    for (NSString *nodeName in nodeNames)
    {
        [currentGame doPlayer:self visitNodeWithID:nodeName];
    }
}


- (void) dealloc
{
	[role release];
	[virtualItems release];
	
	[nodesVisited release];
	[timeStartedPlaying release];
	
	[super dealloc];
}

@end
