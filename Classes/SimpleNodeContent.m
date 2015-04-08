//
//  GraphNodeContentSimple.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "SimpleNodeContent.h"
#import "GraphNode.h"
#import "Graph.h"


@implementation SimpleNodeContent


- (id) init
{
	self = [super initWithType:e_NodeContent_Simple];
	if (self)
	{
		[self reset];
	}
	return self;
}


- (NSString *) nextNodeToVisit
{
	// For simple nodes there should be only one child that is allowed to be visited
    // but to find it we need to check the preconditions of all the children nodes
    
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


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
    NSString *nextNodeName = [self nextNodeToVisit];
    GraphNode *nextNode = [self.owner.ownerGraph nodeWithID:nextNodeName];
    
	// Does the data match the next graph node's identifier (or override)?
    if (!haveFoundCorrectData)
    {
        NSString *override = nextNode.content.optionalCodeOverride;
        if (override && [data isEqualToString:override])
        {
            haveFoundCorrectData = YES;
        }
        else if  (nextNodeName && [data isEqualToString:nextNodeName])
        {
            haveFoundCorrectData = YES;
        }
    }
    
    return haveFoundCorrectData;
}


- (BOOL) isPostconditionSatisfied
{
	return haveFoundCorrectData;
}


- (void) reset
{
    haveFoundCorrectData = NO;
}


@end
