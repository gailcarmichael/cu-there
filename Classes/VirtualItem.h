//
//  VirtualItem.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VirtualItem : NSObject 
{
	NSString *itemName;
}

- (BOOL) equalToItem:(VirtualItem *)otherItem;

+ (VirtualItem *) itemWithName:(NSString *)name;

@end
