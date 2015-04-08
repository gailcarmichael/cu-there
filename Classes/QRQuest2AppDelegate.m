//
//  QRQuest2AppDelegate.m
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QRQuest2AppDelegate.h"
#import "GraphNodeViewController.h"
#import "PlayerSetupViewController.h"
#import "TitleScreenViewController.h"

@implementation QRQuest2AppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    GameState *game = [GameState getGameFromPlist:@"StoryFiles/CarletonQuest.plist"];
    [GameState setCurrentGame:game];    
    
    nav =
    [[UINavigationController alloc] initWithRootViewController:
        [[TitleScreenViewController alloc] init]];
    
    
    [nav.navigationBar setTintColor:[UIColor colorWithRed:0.875f green:0.376f blue:0.376f alpha:1]];
    [nav.toolbar setTintColor:[UIColor colorWithRed:0.875f green:0.376f blue:0.376f alpha:1]];
    
    //nav.toolbarHidden = YES;
    //nav.toolbar.barStyle = UIBarStyleBlack;
    
    //nav.navigationBar.hidden = YES;
    //nav.navigationBar.barStyle = UIBarStyleBlack;
     
    [window addSubview:nav.view];

    	
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    
    // Nothing to do for this app, since everything is touch driven anyway...
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    // Only save the game if it has actually started
    if ([[GameState currentGame] isGameInProgress])
    {
        [[GameState currentGame] saveToPlist:@"SavedGame.plist"];
        NSLog(@"Saving game state in applicationDidEnterBackground");
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    [[GameState currentGame] loadFromPlistAndOverwriteCurrentState:@"SavedGame.plist"];
    NSLog(@"Loading game state in applicationDidBecomeActive");
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[GameState currentGame] loadFromPlistAndOverwriteCurrentState:@"SavedGame.plist"];
    NSLog(@"Loading game state in applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    
    // Only save the game if it has actually started
    if ([[GameState currentGame] isGameInProgress])
    {
        [[GameState currentGame] saveToPlist:@"SavedGame.plist"];
        NSLog(@"Saving game state in applicationWillTerminate");
    }
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc 
{
    [window release];
    [nav release];
    [super dealloc];
}


@end
