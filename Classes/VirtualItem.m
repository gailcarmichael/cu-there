//
//  VirtualItem.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "VirtualItem.h"


static NSMutableDictionary *items;


@implementation VirtualItem

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
		itemName = newName;
		[itemName retain];
	}
	return self;
}


- (void) dealloc
{
	[itemName release];
	[super dealloc];
}


- (BOOL) equalToItem:(VirtualItem *)otherItem
{
	return [itemName isEqualToString:otherItem->itemName];
}


#pragma mark -
#pragma mark Class Methods

+ (VirtualItem *) itemWithName:(NSString *)name
{
	if (!items)
	{
		items = [NSMutableDictionary dictionaryWithCapacity:10];
		[items retain];
	}
	
	VirtualItem *newItem;
	if (!(newItem = [items objectForKey:name]))
	{
		newItem = [[[VirtualItem	alloc] initWithName:name] autorelease];
		[items setObject:newItem forKey:name];
	}
	
	return newItem;
}

@end
