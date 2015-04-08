//
//  Graph.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "Graph.h"


@implementation Graph

@synthesize currentlyActiveNode;


- (id) init
{
	self = [super self];
	if (self)
	{
		currentlyActiveNode = nil;
		
		nodes = [NSMutableDictionary dictionaryWithCapacity:10];
		[nodes retain];
        
        rootNode = nil;
	}
	return self;
}


- (void) resetCurrentGame
{
    self.currentlyActiveNode = [self getRootNode];
}


- (void) setRootNode:(NSString *)nodeID
{
    rootNode = [self nodeWithID:nodeID];
    self.currentlyActiveNode = rootNode;
}


- (GraphNode *) getRootNode
{
    return rootNode;
}


- (GraphNode *) nodeWithID:(NSString *)nodeID
{
    return [nodes objectForKey:nodeID];
}


- (GraphNode *) addNewNodeWithID:(NSString *)newID andContent:(GraphNodeContent *)newContent
{
    GraphNode *node = [self nodeWithID:newID];
    if (!node)
    {
        node = [[[GraphNode alloc] initWithIdentifier:newID] autorelease];
        node.content = newContent;
        node.ownerGraph = self;
        [nodes setObject:node forKey:newID];
    }
    return node;
}


- (void) setChild:(NSString *)childID forParent:(NSString *)parentID
{
    // Assumes the nodes already exist
    
    GraphNode *child = [self nodeWithID:childID];
    GraphNode *parent = [self nodeWithID:parentID];
    
    if (child && parent)
    {
        [parent addChild:child];
    }
}


- (NSString *) descriptionFileNameForNode:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return node.content.descriptionFile;
}


- (e_NodeContent_Type) contentTypeForNode:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return node.content.type;
}


- (NSString *) optionalNodeTitle:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return node.content.optionalTitle;
}


- (int) percentProgressForNode:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return node.percentProgress;
}


- (int) numChildrenForNode:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return [[node.children allKeys] count];
}


- (NSArray *) childNodeIdentifiersForNode:(NSString *)nodeID
{
    GraphNode *node = [nodes objectForKey:nodeID];
    return [node.children allKeys];
}


- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID
{
    return [self.currentlyActiveNode player:player foundNewData:data forNodeID:nodeID];
}


- (GraphNode *) nextNodeIfTransitionAllowedForPlayer:(Player *)player
{
    GraphNode *nextNode = [self.currentlyActiveNode nextNodeToVisit];
    
    if (nextNode &&
        [self.currentlyActiveNode isPostconditionSatisfied] &&
        [nextNode isPreconditionSatisfied] &&
        [player canVisitThisNode:nextNode fromNode:self.currentlyActiveNode])
    {
        return nextNode;
    }
    else
    {
        return nil;
    }
}


- (void) transitionToNode:(GraphNode *)node
{
    if (node != nil)
        self.currentlyActiveNode = node;
}



- (void) dealloc
{
	[currentlyActiveNode release];
	[nodes release];
	
	[super dealloc];
}


@end
