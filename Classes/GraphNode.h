//
//  GraphNode.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphNodeContent.h"

@class Graph;
@class Player;

@interface GraphNode : NSObject
{
	NSString *nodeIdentifier;
	NSMutableDictionary *children;
	GraphNodeContent *content;
    Graph *ownerGraph;
    
    int percentProgress;
	
	// Non-property, protected members
}

@property (nonatomic, retain) NSString *nodeIdentifier;
@property (nonatomic, retain) NSMutableDictionary *children;
@property (nonatomic, retain) GraphNodeContent *content;
@property (nonatomic, retain) Graph *ownerGraph;
@property (nonatomic) int percentProgress;


- (id) initWithIdentifier:(NSString *)newID;
- (void) addChild:(GraphNode *)child;

- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID;

- (GraphNode *) nextNodeToVisit;
- (BOOL) isPreconditionSatisfied;
- (BOOL) isPostconditionSatisfied;

@end
