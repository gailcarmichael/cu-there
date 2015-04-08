//
//  ScanCodeViewController.h
//  QRQuest2
//
//  Created by Gail on 2014-07-14.
//  Copyright (c) 2014 GailCarmichael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>


@interface ScanCodeViewController : UIViewController
<AVCaptureMetadataOutputObjectsDelegate>
{
    NSString *nodeID;
    
    UIBarButtonItem *cancelButton;
    
    AVCaptureSession *qrCaptureSession;
    AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
    
    CFURLRef soundFileURLRef;
    SystemSoundID shutterSoundObject;
}

@property (nonatomic, retain) NSString *nodeID;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;

@property (readwrite) CFURLRef soundFileURLRef;
@property (readonly) SystemSoundID shutterSoundObject;

- (id) initWithNodeID:(NSString *)newNodeID;
    

@end
