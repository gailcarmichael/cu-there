//
//  GraphNodeViewController.h
//  QRQuest2
//
//  Created by Gail on 11-04-25.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleGraphNodeViewController.h"

@interface GraphNodeViewController : SimpleGraphNodeViewController 
<UIAlertViewDelegate>
{    
    // UI Elements
    UIBarButtonItem *resetButton;
    UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *endButton;
    UIBarButtonItem *seeChoicesButton;
    UIBarButtonItem *seeListButton;
}

// UI Elements
@property (nonatomic, retain) UIBarButtonItem *resetButton;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, retain) UIBarButtonItem *endButton;
@property (nonatomic, retain) UIBarButtonItem *seeChoicesButton;
@property (nonatomic, retain) UIBarButtonItem *seeListButton;

- (id) initWithNodeID:(NSString *)newNodeID;


@end
