//
//  ScavengerListNodeContent.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "ScavengerListNodeContent.h"
#import "GraphNode.h"


@implementation ScavengerListNodeContent


@synthesize itemNodeIDList, itemsFound, lastItemSelectedNodeID;

- (int) minItemsToFind
{
    if (myMinItemsToFind > 0)
        return myMinItemsToFind;
    else
        return [itemNodeIDList count];
}

- (void) setMinItemsToFind:(int)minItemsToFind
{
    myMinItemsToFind = minItemsToFind;
}


- (id) init
{
	self = [super initWithType:e_NodeContent_ScavengerList];
	if (self)
	{
		[self reset];
	}
	return self;
}


- (void) playerSelected:(NSString *)nodeID
{
    if ([itemNodeIDList containsObject:nodeID])
    {
        self.lastItemSelectedNodeID = nodeID;
    }
}


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
    BOOL foundNewItem = NO;
    
	if (![self.itemsFound containsObject:data] &&
        [self.itemNodeIDList containsObject:data] &&
        [self.lastItemSelectedNodeID isEqualToString:data])
    {
        foundNewItem = YES;
        [self.itemsFound addObject:data];
    }
    
    return foundNewItem;
}


- (NSString *) nextNodeToVisit
{
	// Return the identifier of the next node to visit using the same
    // procedure as simple nodes
    
    NSString *nextNodeName = nil;
    
    for (NSString *childName in [owner.children allKeys])
    {
        if ([[owner.children objectForKey:childName] isPreconditionSatisfied])
        {
            nextNodeName = childName;
            break;
        }
    }
    
    return nextNodeName;
}


- (BOOL) isPostconditionSatisfied
{
	return [self.itemsFound count] >= self.minItemsToFind;
}


- (void) dealloc
{
    [itemNodeIDList release];
    [itemsFound release];
    [super dealloc];
}


- (void) reset
{
    self.lastItemSelectedNodeID = nil;
    
    [itemsFound release];
    itemsFound = [NSMutableArray arrayWithCapacity:5];
    [itemsFound retain];
    
    myMinItemsToFind = 0;
}

@end
