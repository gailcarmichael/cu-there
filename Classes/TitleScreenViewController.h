//
//  TitleScreenViewController.h
//  QRQuest2
//
//  Created by Gail on 12-10-23.
//  Copyright 2012 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameState.h"


@interface TitleScreenViewController : UIViewController
<GameObserver>
{
    // UI Elements
    UILabel *welcomeLabel;
    UILabel *playerRoleLabel;
    UIButton *selectRoleButton;
    UIButton *startGameButton;
}

@property (nonatomic, retain) UILabel *welcomeLabel;
@property (nonatomic, retain) UILabel *playerRoleLabel;
@property (nonatomic, retain) UIButton *selectRoleButton;
@property (nonatomic, retain) UIButton *startGameButton;

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType;

@end
