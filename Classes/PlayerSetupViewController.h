//
//  PlayerRoleChoiceViewController.h
//  QRQuest2
//
//  Created by Gail on 11-07-22.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayerSetupViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
{
    
}

- (id) initWithParentController:(UIViewController *)parentController;
- (void) presentPlayerSetupActionSheet:(UIViewController *)sender;

@end
