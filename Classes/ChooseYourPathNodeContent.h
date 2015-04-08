//
//  ChooseYourPathNodeContent.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GraphNodeContent.h"


@interface ChooseYourPathNodeContent : GraphNodeContent
{
    NSString *idOfChosenNode;
    
    // Protected members
    BOOL hasFoundOneOfChoices;
    NSString * lastNodeIDSelectedByPlayer;
}

@property (nonatomic, retain) NSString *idOfChosenNode;
@property (nonatomic, retain) NSString *lastNodeIDSelectedByPlayer;

- (void) playerSelected:(NSString *)nodeID;

@end