//
//  NodeListTableViewController.h
//  QRQuest2
//
//  Created by Gail on 11-06-03.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NodeChoiceTableViewController.h"
#import "GameState.h"

@interface NodeListTableViewController : NodeChoiceTableViewController
<GameObserver>
{
    UIBarButtonItem *itemsFoundButton;
    UIBarButtonItem *continueStoryButton;
}

@property (nonatomic, retain) UIBarButtonItem *itemsFoundButton;
@property (nonatomic, retain) UIBarButtonItem *continueStoryButton;

@end
