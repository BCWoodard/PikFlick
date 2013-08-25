//
//  HomeViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/22/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "HomeViewController.h"
#import "Reachability.h"

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
	
    // Reachability check
    [self checkForInternet];
    
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


#pragma mark - REACHABILITY Methods
- (void)checkForInternet
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            [self showReachabilityAlertView];
            NSLog(@"There's no internet connection at all.");
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


- (void)showReachabilityAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!"
                                                        message:@"PikFlick is unable to reach the Internet. Please check your device settings or try later."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
}

@end
