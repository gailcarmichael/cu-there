//
//  Team.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "Team.h"


@implementation Team

@synthesize teamName;


- (id) initWithName:(NSString *)newName
{
	self = [super init];
	if (self)
	{
		teamName = newName;
		[teamName retain];
		
		teamMembers = [NSMutableDictionary dictionaryWithCapacity:4];
		[teamMembers retain];
	}
	return self;
}


- (void) playerDidJoinTeam:(Player *)player
{
	if (player)
	{
		[teamMembers setObject:player forKey:player.name];
	}
}


- (BOOL) isPlayerOnTeam:(Player *)player
{
	return [[teamMembers allKeys] containsObject:player.name];
}


- (Player *) playerWithName:(NSString *)name
{
	return [teamMembers objectForKey:name];
}


- (void) dealloc
{
	[teamName release];
	
	[teamMembers release];
	
	[super dealloc];
}

@end
