//
//  LumoViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ContactsViewController.h"
#import "MapViewController.h"
#import "LumoAppDelegate.h"
#import "CallManager.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ContactsViewController
@synthesize spinner = _spinner;
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotContacts) name:GET_FRIENDS_SUCCESS object:nil];
    
    // Listen for received calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnScreen) name:CONN_RECEIVED object:nil];
}

- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotContacts {
    [self.tableView reloadData];
}

/******************************************************************************
 * Table view setup functions
 ******************************************************************************/

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    // If we want all indices
    return [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    // If we only want existing indices
    //return [[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView = tableView; // Super hacky. Is there a better way?
    NSInteger count = [[myAppDelegate.contactsManager.sections allKeys] count];
    if (count > 0) [self.spinner stopAnimating];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];   
    }
    cell.textLabel.text = [[[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myAppDelegate.callManager.partnerInfo = [[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self showConnScreen];
}

- (void)showConnScreen {
    [self performSegueWithIdentifier:@"gotoConnecting" sender:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
