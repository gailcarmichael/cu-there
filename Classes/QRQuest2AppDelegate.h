//
//  QRQuest2AppDelegate.h
//  QRQuest2
//
//  Created by Gail Carmichael on 11-04-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRQuest2AppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    UINavigationController *nav;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

