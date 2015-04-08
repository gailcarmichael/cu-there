//
//  SimpleGraphNodeViewController.h
//  QRQuest2
//
//  Created by Gail on 11-06-01.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameState.h"





@interface SimpleGraphNodeViewController : UIViewController
<GameObserver, UIWebViewDelegate>
{
    NSString *nodeID;
    
    // UI Elements
    UIWebView *webView;
    UIButton *scanButton;
    UIBarButtonItem *scanBarButton;
    
    bool needToPop;
    int popToIndex;
}

@property (nonatomic, retain) NSString *nodeID;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *scanBarButton;


- (id) initWithNodeID:(NSString *)newNodeID;

- (BOOL) setWebViewContent:(NSString *)fileName;
- (void) scanButtonTapped;

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType;

@end
