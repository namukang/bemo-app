//
//  MapViewController.m
//  Bemo
//
//  Created by Lumo Labs on 4/10/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "MapViewController.h"
#import "Pin.h"
#import "LocationRelay.h"
#import "BemoAppDelegate.h"
#import "CallManager.h"

@interface MapViewController ()
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) Pin *contactPin;
@property (nonatomic, strong) NSTimer *partnerTimer;
@property (nonatomic, assign) BOOL partnerFound;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize contactPin = _contactPin;
@synthesize partnerTimer = _partnerTimer;
@synthesize partnerFound = _partnerFound;

- (Pin *)contactPin {
    if (!_contactPin) {
        _contactPin = [[Pin alloc] init];
        
        // Put pin on map
        [self.mapView addAnnotation:_contactPin];
    }
    return _contactPin;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:(BOOL)animated];
    myAppDelegate.appState = MAP_STATE;
    
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"MAP"];
#endif

#ifdef MIXPANEL
    [[MixpanelAPI sharedAPI] track:@"MAP"];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerLocationOnMap) name:PARTNER_LOC_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnection) name:CONN_WAITING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected) name:DISCONNECTED object:nil];

    [myAppDelegate.locationRelay startSelfUpdates];
    [myAppDelegate.locationRelay startPartnerUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:(BOOL)animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [myAppDelegate.locationRelay stopSelfUpdates];
    [myAppDelegate.locationRelay stopPartnerUpdates];

    // Reset partner's location
    // This ensures that the contact pin is not placed at (0,0) if recenter is pressed before getting partner's location
    myAppDelegate.locationRelay.partnerLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    self.partnerFound = NO;
}

- (void)receiveConnection {
    [CallManager receiveConnection];
}

- (void)updatePartnerLocationOnMap {
    // Show partner's location on map
    self.contactPin.coordinate = myAppDelegate.locationRelay.partnerLocation.coordinate;
    // Center map between contacts when pin is first placed
    if (!self.partnerFound) {
        self.partnerFound = YES;
        [self recenter:nil];
    }
}

- (void)disconnected {
    NSString *message = [NSString stringWithFormat:@"%@ ended the connection", [myAppDelegate.callManager.partnerInfo valueForKey:@"name"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bemo Ended"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self performSegueWithIdentifier:@"mapShowContacts" sender:nil];
}

- (IBAction)endConnectionButton:(id)sender {
    [CallManager endConnection];
    [self performSegueWithIdentifier:@"mapShowContacts" sender:nil];
}

// Called each time an annotation is added to the map
- (MKAnnotationView *)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *contactPinID = @"contactPin";
    MKPinAnnotationView *annotView = nil;
    
    if ([annotation isKindOfClass:[Pin class]]) {
        annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:contactPinID];
        if (!annotView) {
            annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:contactPinID];   
        } else {
            annotView.annotation = annotation;   
        }
    }
    
    if (annotView) {
        annotView.enabled = YES;
        annotView.canShowCallout = YES;
        annotView.image = [UIImage imageNamed:@"dot.png"];
        annotView.centerOffset = CGPointMake(-3,6);
        return annotView;
    }
    return nil;
}

// Method called on press of recenter button
// See: http://stackoverflow.com/questions/1336370/positioning-mkmapview-to-show-multiple-annotations-at-once

- (IBAction)recenter:(id)sender {
    // Return if we don't have a location for partner
    CLLocation *partnerLocation = myAppDelegate.locationRelay.partnerLocation;
    if (partnerLocation.coordinate.latitude == 0.0 && partnerLocation.coordinate.longitude == 0.0)
        return;

    CLLocation *currentLocation = myAppDelegate.locationRelay.currentLocation;
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    southWest.latitude = MIN(currentLocation.coordinate.latitude, self.contactPin.coordinate.latitude);
    southWest.longitude = MIN(currentLocation.coordinate.longitude, self.contactPin.coordinate.longitude);
    
    northEast.latitude = MAX(currentLocation.coordinate.latitude, self.contactPin.coordinate.latitude);
    northEast.longitude = MAX(currentLocation.coordinate.longitude, self.contactPin.coordinate.longitude);
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion region;
    region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    region.span.latitudeDelta = meters / 111319.5;
    region.span.longitudeDelta = 0.0;
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
