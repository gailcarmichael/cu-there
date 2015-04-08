//
//  ChooseYourPathNodeContent.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "ChooseYourPathNodeContent.h"
#import "GraphNode.h"


@implementation ChooseYourPathNodeContent

@synthesize idOfChosenNode, lastNodeIDSelectedByPlayer;

- (id) init
{
	self = [super initWithType:e_NodeContent_ChooseYourPath];
	if (self)
	{
		[self reset];
	}
	return self;
}


- (NSString *) nextNodeToVisit
{
	GraphNode *chosenPath = [owner.children objectForKey:idOfChosenNode];
    NSString *nextNodeName = nil;
    
    //return [[[chosenPath children] allKeys] objectAtIndex:0];
   
    for (NSString *childID in [[chosenPath children] allKeys])
    {
        if ([[[chosenPath children] objectForKey:childID] isPreconditionSatisfied])
        {
            nextNodeName = childID;
            break;
        }
    }
    
    return nextNodeName;
}


- (BOOL) isLegitimateChild:(NSString *)nodeID
{
    return [[owner.children allKeys] containsObject:nodeID];
}


- (void) playerSelected:(NSString *)nodeID
{
    if ([self.owner.children objectForKey:nodeID] != nil)
    {
        self.lastNodeIDSelectedByPlayer = nodeID;
    }
}


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
	// Does the data match the graph node's identifier?
    if (!hasFoundOneOfChoices && 
        [self isLegitimateChild:data] &&
        [data isEqualToString:nodeID] &&
        [lastNodeIDSelectedByPlayer isEqualToString:nodeID])
    {
        hasFoundOneOfChoices = YES;
        idOfChosenNode = [data retain];
    }
    
    return hasFoundOneOfChoices;
}


- (BOOL) isPostconditionSatisfied
{
	return hasFoundOneOfChoices;
}


- (void) dealloc
{
    [idOfChosenNode release];
    [super dealloc];
}


- (void) reset
{
    self.lastNodeIDSelectedByPlayer = nil;
    
    hasFoundOneOfChoices = NO;
    idOfChosenNode = nil;
}


@end
