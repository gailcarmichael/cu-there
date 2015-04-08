//
//  SimpleGraphNodeViewController.m
//  QRQuest2
//
//  Created by Gail on 11-06-01.
//  Copyright 2011 GailCarmichael. All rights reserved.
//

#import "SimpleGraphNodeViewController.h"
#import "GameState.h"
#import "PlayerSetupViewController.h"
#import "ScanCodeViewController.h"


@implementation SimpleGraphNodeViewController

@synthesize nodeID;
@synthesize webView, scanBarButton;


- (id) initWithNodeID:(NSString *)newNodeID
{
    self = [super init];
    if (self)
    {
        nodeID = newNodeID;
        [nodeID retain];
        
        scanButton = nil;
        scanBarButton = nil;
        webView = nil;
        
        needToPop = NO;
    }
    return self;
}

- (void)dealloc
{
    [nodeID release];
    [webView release];
    [scanBarButton release];
    [super dealloc];
}

#pragma mark - UI event handlers

- (void) scanButtonTapped
{
    
    ScanCodeViewController *controller = [[ScanCodeViewController alloc] initWithNodeID:self.nodeID];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}



- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Open clicked links in safari
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}


#pragma mark - View updating


- (void) setupToolbarAnimated:(BOOL)animated
{
    UIBarButtonItem *flexiblespace =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                   target:nil
                                                   action:nil] autorelease];
    
    NSArray *items =
    [[[NSArray alloc] initWithObjects:
      flexiblespace,
      self.scanBarButton,
      flexiblespace,
      nil]
     autorelease];
	
    [self setToolbarItems:items animated:animated];
}


- (BOOL) setWebViewContent:(NSString *)fileName
{
    
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
    //NSLog(@"%@", path);
	
	if (fileName != nil && [[NSFileManager defaultManager] fileExistsAtPath:path])
	{
        [self.webView setHidden:YES];
		NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
		[self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
		return YES;
	}
	else
	{
		return NO;
	}
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView setHidden:NO];
}



#pragma mark - Model updating

- (BOOL) modelDidChange:(e_ModelUpdate_Type)updateType
{
    BOOL shouldCancelRemaining = NO;
    
    if (updateType == e_ModelUpdate_ResetGame)
    {
        // Make sure we are at the bottom level of the stack
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
    if (updateType == e_ModelUpdate_CurrentStoryNode)
    {
        // If the game has advanced, and this is a choice node, we need to pop
        // back to the root story node view (not the true root view, since that's
        // the title view).  This is already taken care of elsewhere for other
        // node types.
        
        GameState *game = [GameState currentGame];
        e_NodeContent_Type nodeType = [game contentTypeForPreviousNode:[game activeNodeIdentifier]];
        
        if (nodeType == e_NodeContent_ChooseYourPath)
        {
            needToPop = YES;
            popToIndex = 1;
        }
    }
    
    
    if (updateType == e_ModelUpdate_FoundScavengerItem)
    {
        needToPop = YES;
        popToIndex = [self.navigationController.viewControllers count] - 3;
    }
    
    
    if (updateType == e_ModelUpdate_FoundIncorrectCode)
    {
        UIAlertView *wrongCode = [[UIAlertView alloc] initWithTitle: @"Sorry!"
                                                            message: @"This is not the code you were looking for. Keep trying!" 
                                                           delegate: self 
                                                  cancelButtonTitle: @"OK" 
                                                  otherButtonTitles: nil];
        [wrongCode show];
        [wrongCode release];
        
        shouldCancelRemaining = YES;
    }
    
    return shouldCancelRemaining;
}


#pragma mark - View lifecycle


- (void) loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"SimpleGraphNodeViewController" owner:self options:nil] lastObject];
    
    self.webView = (UIWebView *)[self.view viewWithTag:101];
    
    [self.webView setOpaque:NO];
    self.webView.backgroundColor = [UIColor clearColor];
    

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Set this class to be the web view's delegate so we can send link clicks to Safari
    webView.delegate = self;
    
    
    GameState *game = [GameState currentGame];
    
    // Add ourselves as an observer
    [game registerObserver:self];
    
    self.title = [game optionalNodeTitle:self.nodeID];
    
    
    
    // Get the center button ready...
    
    UIButton *scanButtonTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *scanButtonImageNormal = [UIImage imageNamed:@"CenterButton-Scan.png"];
    UIImage *scanButtonImageDisabled = [UIImage imageNamed:@"CenterButton-ScanDisabled.png"];
    
    [scanButtonTemp setImage:scanButtonImageNormal forState:UIControlStateNormal];
    [scanButtonTemp setImage:scanButtonImageDisabled forState:UIControlStateDisabled];
    
    scanButtonTemp.frame = CGRectMake(0, 0, scanButtonImageNormal.size.width, scanButtonImageNormal.size.height);
    [scanButtonTemp addTarget:self action:@selector(scanButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *scanButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanButtonImageNormal.size.width, scanButtonImageNormal.size.height)];
    
    [scanButtonView addSubview:scanButtonTemp];
    
    scanButton = scanButtonTemp;
    self.scanBarButton = [[UIBarButtonItem alloc] initWithCustomView:scanButtonView];
    
    
    // Make sure the new button will be allowed to spill over in size
    self.navigationController.toolbar.clipsToBounds = NO;
    
    
    // Put it all together...
    
    [self setupToolbarAnimated:YES];
}


- (void)viewDidUnload
{
    // Remove ourselves as an observer
    [[GameState currentGame] deregisterObserver:self];
    
    self.scanBarButton = nil;
    self.webView = nil;
    
    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // The scan button should not be active unless the active node is the last one visited;
    // it should also be inactive if the item in a scavenger hunt has already been found
    
    GameState *game = [GameState currentGame];
    
    NSString *lastNodeID = [game lastNodeSoFarIdentifier];
    e_NodeContent_Type lastNodeType = [game contentTypeForNode:lastNodeID];
    
    BOOL enabled = NO;    
    
    if ([game isNodeLastSoFar:[game activeNodeIdentifier]])
    {
        if (lastNodeType == e_NodeContent_ScavengerList)
        {            
            enabled = !([game scavengerItem:self.nodeID wasFoundForNode:lastNodeID]);
        }
        else
        {
            enabled = YES;
        }
    }
    
    self.scanBarButton.enabled = enabled;
    scanButton.enabled = enabled;
    
    // Update the web view
    [self setWebViewContent:[game descriptionFileNameForNode:self.nodeID]];
    
    // Make sure the toolbar is ready to go
    [self setupToolbarAnimated:NO];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (needToPop)
    {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:popToIndex]
                                              animated:YES];
        needToPop = NO;
    }
}


- (void) viewWillDisappear:(BOOL)animated
{

    
}


@end
