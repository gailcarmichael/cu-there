//
//  ScanCodeViewController.m
//  QRQuest2
//
//  Created by Gail on 2014-07-14.
//  Copyright (c) 2014 GailCarmichael. All rights reserved.
//

#import "ScanCodeViewController.h"

#import "GameState.h"


@implementation ScanCodeViewController


@synthesize cancelButton;
@synthesize nodeID;
@synthesize soundFileURLRef, shutterSoundObject;


- (id) initWithNodeID:(NSString *)newNodeID
{
    self = [super init];
    if (self)
    {
        nodeID = newNodeID;
        [nodeID retain];
        
        cancelButton = nil;
    }
    return self;
}


- (void)dealloc
{
    [self stopReading];
    [nodeID release];
    [cancelButton release];
    [super dealloc];
}

#pragma mark - QR Code Scanning


- (void) setupScanView
{
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    qrCaptureSession = [[AVCaptureSession alloc] init];
    [qrCaptureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [qrCaptureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    qrVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:qrCaptureSession];
    [qrVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [qrVideoPreviewLayer setFrame:self.view.layer.bounds];
    
    [self.view.layer addSublayer:qrVideoPreviewLayer];
    
    [qrCaptureSession startRunning];
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            [self stopReading];
            
            [self performSelectorOnMainThread:@selector(checkCodeAndPop:)
                                   withObject:[metadataObj stringValue]
                                waitUntilDone:NO];
        }
    }
}


- (void) checkCodeAndPop:(NSString *)text
{
    AudioServicesPlaySystemSound(shutterSoundObject);
    
    [[GameState currentGame] playerFoundNewData:text forNodeID:self.nodeID];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) stopReading
{
    if (qrCaptureSession != nil)
    {
        [qrCaptureSession stopRunning];
        
        [qrCaptureSession release];
        qrCaptureSession = nil;
        
        [qrVideoPreviewLayer removeFromSuperlayer];
    }
}


#pragma mark - UI event handlers


- (void) cancelButtonTapped
{
    [self stopReading];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    ////
    // Set an informative title
    
    self.title = @"Scan the next QR code";
    
    
    ////
    // Hide the back button
    
    [self.navigationItem setHidesBackButton:YES];
    
    
    ////
    // Set up the scanning view
    
    [self setupScanView];
    
    
    ////
    // Put a cancel button in the middle
    
    UIBarButtonItem *flexiblespace =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                   target:nil
                                                   action:nil] autorelease];
    
    self.cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(cancelButtonTapped)] autorelease];
    
    NSArray *items =
    [[[NSArray alloc] initWithObjects:
      flexiblespace,
      self.cancelButton,
      flexiblespace,
      nil]
     autorelease];
	
    [self setToolbarItems:items animated:YES];
    
    
    ////
    // Create the system sound for the shutter
    
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/photoShutter.caf"];
    
    self.soundFileURLRef = (CFURLRef) [fileURL retain];
    
    AudioServicesCreateSystemSoundID(soundFileURLRef, &shutterSoundObject);
    
}


@end
