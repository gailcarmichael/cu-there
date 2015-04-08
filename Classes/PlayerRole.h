//
//  PlayerRole.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlayerRole : NSObject
{
	NSString *roleName;
}

@property (nonatomic, readonly) NSString *roleName;

- (BOOL) isEqualToRole:(PlayerRole *)otherRole;

+ (PlayerRole *) roleWithName:(NSString *)name;

@end
