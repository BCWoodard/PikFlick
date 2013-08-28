//
//  HomeViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/22/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "HomeViewController.h"
#import "Reachability.h"
#import "ViewController.h"

@interface HomeViewController () {

    __weak IBOutlet UIImageView *homeImage;
    
}
- (IBAction)goToMoviesList:(id)sender;

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
    
    // UI elements
    [self selectHomeScreenImage];
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

#pragma mark - Hide NavBar

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


#pragma mark - Select Homescreen Image
- (void)selectHomeScreenImage
{
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    CGFloat windowWidth = windowRect.size.width;
    CGFloat windowHeight = windowRect.size.height;
    homeImage.frame = CGRectMake(0, 0, windowWidth, windowHeight);
    
    if (windowHeight == 480.0f) {
        homeImage.image = [UIImage imageNamed:@"Default"];
    } else {
        homeImage.image = [UIImage imageNamed:@"Default-568h"];
    }
}


#pragma mark - Transition to Movies List
- (IBAction)goToMoviesList:(id)sender
{
    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MoviesListViewController"];
    
    // hide back button
    viewController.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:viewController animated:YES];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
