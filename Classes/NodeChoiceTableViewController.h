//
//  NodeChoiceTableViewController.h
//  QRQuest2
//
//  Created by Gail on 11-05-13.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameState.h"


@interface NodeChoiceTableViewController : UITableViewController
<GameObserver>
{
    
}

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType;

@end
