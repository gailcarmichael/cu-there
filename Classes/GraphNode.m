//
//  GraphNode.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "GraphNode.h"
#import "Graph.h"
#import "Player.h"


@implementation GraphNode

@synthesize nodeIdentifier, children, content, ownerGraph, percentProgress;


- (id) initWithIdentifier:(NSString *)newID
{
	self = [super init];
	if (self)
	{
		nodeIdentifier = newID;
		[nodeIdentifier retain];
		
		children = [NSMutableDictionary dictionaryWithCapacity:5];
		[children retain];
        
        percentProgress = 0;
	}
	return self;
}


- (void) addChild:(GraphNode *)child
{
    if (child)
    {
        [self.children setObject:child forKey:child.nodeIdentifier];
    }
}


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
    return [self.content player:player foundNewData:data forNodeID:nodeID];
}


- (GraphNode *) nextNodeToVisit
{
    // Note that we may not know yet which node will be visited
    // next, depending when this is called
    
    NSString *nextNodeID = [self.content nextNodeToVisit];
    if (nextNodeID)
    {
        return [self.ownerGraph nodeWithID:nextNodeID];
    }
    else
    {
        return nil;
    }
}

- (BOOL) isPreconditionSatisfied
{
    return [self.content isPreconditionSatisfied];
}


- (BOOL) isPostconditionSatisfied
{
    return [self.content isPostconditionSatisfied];
}


- (void) dealloc
{
	[nodeIdentifier release];
	[children release];
	
	[super dealloc];
}


@end

