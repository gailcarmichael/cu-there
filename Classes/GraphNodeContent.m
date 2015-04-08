//
//  GraphNodeContent.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//


#import "GameState.h"
#import "GraphNodeContent.h"
#import "Player.h"
#import "GraphNode.h"


@implementation GraphNodeContent

@synthesize type, descriptionFile, owner;
@synthesize optionalTitle, optionalCodeOverride;
@synthesize lastLocation, playerRolesAllowed;


- (id) initWithType:(e_NodeContent_Type) newType
{
	self = [super init];
	if (self)
	{
		type = newType;
        
        playerRolesAllowed = [NSMutableArray arrayWithCapacity:2];
        [playerRolesAllowed retain];
	}
	return self;
}


- (NSString *) description
{
	// Load file, return description
	// TODO: what if there are multiple files needed? Should
	// all files be preloaded as in the last version?
	
	return nil;
}


- (NSString *) nextNodeToVisit
{
	// Return the identifier of the next node to visit based
	// on the current state of the game, etc
	
	return nil;
}


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
	// The user has scanned a code, and now we're being informed of it.
	// Do something about it.
    // (Override in specific content types.)
    return NO;
}


- (BOOL) isPreconditionSatisfied
{
	// Can this node be visited next based on the game state?
    // (Make sure to call this one in subclasses so roles get checked)
	
    // Can continue to this node if either the roles allowed array is empty (i.e. no restrictions)
    // or contains the role of the active player
    
    PlayerRole *activeRole = [[GameState currentGame] activePlayerRole];
    return (([playerRolesAllowed count]==0) || [self.playerRolesAllowed containsObject:activeRole]);
}


- (BOOL) isPostconditionSatisfied
{
	// Have the exit requirements been met (QR codes been found)?
	
	return NO;
}


- (void) dealloc
{
	[descriptionFile release];
    [optionalTitle release];
    [owner release];
    [playerRolesAllowed release];
	
	[super dealloc];
}


- (void) reset
{
    
}


@end
