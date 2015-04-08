//
//  PlayerRole.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "PlayerRole.h"



static NSMutableDictionary *roles;


@interface PlayerRole (private)

- (id) initWithName:(NSString *)newName;

@end


@implementation PlayerRole


@synthesize roleName;


- (id) init
{
	// Don't allow people to use this one
	return nil;
}


- (id) initWithName:(NSString *)newName
{
	self = [super init];
	if (self)
	{
		roleName = newName;
		[roleName retain];
	}
	return self;
}


- (void) dealloc
{
	[roleName release];
	[super dealloc];
}


- (BOOL) isEqualToRole:(PlayerRole *)otherRole
{
	return [roleName isEqualToString:otherRole->roleName];
}


#pragma mark -
#pragma mark Class Methods

+ (PlayerRole *) roleWithName:(NSString *)name
{
    
	PlayerRole *playerRole;
    
    if (!name)
    {
        playerRole = nil;
    }
    else
    {
        if (!roles)
        {
            roles = [NSMutableDictionary dictionaryWithCapacity:5];
            [roles retain];
        }
        
        if (!(playerRole = [roles objectForKey:name]))
        {
            playerRole = [[[PlayerRole alloc] initWithName:name] autorelease];
            [roles setObject:playerRole forKey:name];
        }
    }
	
	return playerRole;
}



@end
