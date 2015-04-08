//
//  Team.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"


@interface Team : NSObject 
{
	NSString *teamName;
	
	NSMutableDictionary *teamMembers;
}

@property (nonatomic, retain) NSString *teamName;

- (id) initWithName:(NSString *)newName;

- (void) playerDidJoinTeam:(Player *)player;
- (BOOL) isPlayerOnTeam:(Player *)player;
- (Player *) playerWithName:(NSString *)name;

@end
