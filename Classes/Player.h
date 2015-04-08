//
//  Player.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerRole.h"
#import "VirtualItem.h"
#import "GraphNode.h"

@interface Player : NSObject 
{
	NSString *name;
	PlayerRole *role;
	
	NSMutableSet *virtualItems;
    
    //Protected members
	NSMutableArray *nodesVisited;
	NSDate *timeStartedPlaying;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PlayerRole *role;

@property (nonatomic, retain) NSMutableSet *virtualItems;


- (id) initWithName:(NSString *)name andRole:(PlayerRole *)newRole;
- (void) resetCurrentGame;

- (BOOL) hasVirtualItem:(VirtualItem *)item;
- (void) addVirtualItem:(VirtualItem *)item;

- (void) setRootNode:(GraphNode *)node;

- (void) visitNode:(GraphNode *)node;
- (BOOL) canVisitThisNode:(GraphNode *)newNode fromNode:(GraphNode *)currNode;

- (int) numberOfVisitedNodes;
- (int) indexOfVisitedNode:(NSString *)nodeID;
- (int) indexOfLastNode;

- (GraphNode *) visitedNodeWithIndex:(int)index;

- (NSTimeInterval) timeInPlaySoFar;

- (void) addInfoToPlist:(NSMutableDictionary *)plist;
- (void) loadInfoFromPlist:(NSDictionary *)plist;


@end
