//
//  Graph.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GraphNode.h"
#import "Player.h"
#import "GraphNodeContent.h"


@interface Graph : NSObject 
{
	GraphNode *currentlyActiveNode;

	// Non-property, protected members
	NSMutableDictionary *nodes;
    GraphNode *rootNode;
}

@property (nonatomic, retain) GraphNode *currentlyActiveNode;

- (void) resetCurrentGame;

- (GraphNode *) nodeWithID:(NSString *)nodeID;

- (void) setRootNode:(NSString *)nodeID;
- (GraphNode *) getRootNode;
- (void) setChild:(NSString *)childID forParent:(NSString *)parentID;
- (GraphNode *) addNewNodeWithID:(NSString *)newID andContent:(GraphNodeContent *)content;

- (NSString *) descriptionFileNameForNode:(NSString *)nodeID;
- (e_NodeContent_Type) contentTypeForNode:(NSString *)nodeID;
- (NSString *) optionalNodeTitle:(NSString *)nodeID;
- (int) percentProgressForNode:(NSString *)nodeID;
- (int) numChildrenForNode:(NSString *)nodeID;
- (NSArray *) childNodeIdentifiersForNode:(NSString *)nodeID;

- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID;
- (GraphNode *) nextNodeIfTransitionAllowedForPlayer:(Player *)player;

- (void) transitionToNode:(GraphNode *)node;

@end
