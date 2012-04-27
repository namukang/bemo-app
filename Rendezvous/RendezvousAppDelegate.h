//
//  RendezvousAppDelegate.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

#define myAppDelegate ((RendezvousAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface RendezvousAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) NSDictionary* contactArray;
@property (strong, nonatomic) NSDictionary* myFBinfo;
@property (strong, nonatomic) NSDictionary* contactFBinfo;

@end
