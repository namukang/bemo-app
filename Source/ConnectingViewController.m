//
//  ConnectingViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/27/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ConnectingViewController.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"

@interface ConnectingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) NSTimer *pollTimer;

@end

@implementation ConnectingViewController
@synthesize contactName = _contactName;
@synthesize pollTimer = _pollTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.contactName.text = [myAppDelegate.contactInfo objectForKey:@"name"];
    
    // Set notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMapView) name:@"connected" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pollLocation) name:@"waiting" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectLumo) name:@"disconnected" object:nil];
    
    // Set polling timer
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pollLocation) userInfo:nil repeats:YES];
}

- (void)viewDidUnload {
    [self setContactName:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.pollTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:@"connected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"disconnected"];
}

- (void)pollLocation {
    NSLog(@"ConnectingViewController | pollLocation() polling.");
    [myAppDelegate.locationRelay pollForLocation];
}

- (void)gotoMapView {
    [self performSegueWithIdentifier:@"gotoMapView" sender:nil];
}

- (void)disconnectLumo {
    NSLog(@"ConnectingViewController | disconnectLumo(): timeout or declined.");
    [self cancelLumo];
}

- (IBAction)cancelLumo {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
