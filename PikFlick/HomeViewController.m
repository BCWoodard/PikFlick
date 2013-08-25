//
//  HomeViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/22/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () {
    
    __weak IBOutlet UITextField *cityTextField;
    __weak IBOutlet UITextField *stateTextField;
    __weak IBOutlet UITextField *zipTextField;
    __weak IBOutlet UITextField *useMapsAutoCompleteSearch;
}
- (IBAction)findCurrentLocation:(id)sender;
- (IBAction)enterCurrentLocation:(id)sender;
- (IBAction)submitCustomLocation:(id)sender;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self checkForNetwork];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *viewController = segue.destinationViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findCurrentLocation:(id)sender {
    [self performSegueWithIdentifier:@"Use Current Location" sender:self];
}

- (IBAction)enterCurrentLocation:(id)sender {
}

- (IBAction)submitCustomLocation:(id)sender {
}

#pragma mark - REACHABILITY
- (void)checkForNetwork
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            [self showReachabilityAlert];
            NSLog(@"There's no internet connection at all. Display error message now.");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            break;
            
        default:
            break;
    }
}


- (void)showReachabilityAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection!"
                                                        message:@"PikFlick is unable to make a network connection. Please check your settings or try again later."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


@end
