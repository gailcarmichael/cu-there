//
//  GraphNodeContent.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Player;
@class GraphNode;


typedef enum
{
	e_NodeContent_Simple,
	e_NodeContent_VirtualObject,
	e_NodeContent_ScavengerList,
	e_NodeContent_ChooseYourPath,
	
} e_NodeContent_Type;


@interface GraphNodeContent : NSObject 
{
	e_NodeContent_Type type;
	NSString *descriptionFile;
    
    NSString *optionalTitle;
    NSString *optionalCodeOverride;
    BOOL lastLocation;
    
    GraphNode *owner;
    
    NSMutableArray *playerRolesAllowed;
}

@property (readonly) e_NodeContent_Type type;
@property (nonatomic, retain) NSString * descriptionFile;
@property (nonatomic, retain) NSString *optionalTitle;
@property (nonatomic, retain) NSString *optionalCodeOverride;
@property BOOL lastLocation;
@property (nonatomic, retain) GraphNode *owner;
@property (nonatomic, retain) NSMutableArray *playerRolesAllowed;


- (id) initWithType:(e_NodeContent_Type) newType;

- (NSString *) description;
- (NSString *) nextNodeToVisit;

- (BOOL) player:(Player *)player foundNewData:(NSString *)data forNodeID:(NSString *)nodeID;

- (BOOL) isPreconditionSatisfied;
- (BOOL) isPostconditionSatisfied;

- (void) reset;

@end
