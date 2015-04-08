//
//  ScavengerListNodeContent.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GraphNodeContent.h"

@interface ScavengerListNodeContent : GraphNodeContent 
{
    NSArray *itemNodeIDList;
    NSMutableArray *itemsFound;
    int myMinItemsToFind;
    
    NSString *lastItemSelectedNodeID;
}

@property (nonatomic, retain) NSArray *itemNodeIDList;
@property (nonatomic, retain) NSMutableArray *itemsFound;
@property int minItemsToFind;
@property (nonatomic, retain) NSString *lastItemSelectedNodeID;

- (void) playerSelected:(NSString *)nodeID;

@end
