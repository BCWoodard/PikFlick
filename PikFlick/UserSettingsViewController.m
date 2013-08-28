//
//  UserSettingsViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/26/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface UserSettingsViewController () {
    __weak IBOutlet UISegmentedControl *theatreDistanceControl;
    __weak IBOutlet UITextField *locationField;
    
}
- (IBAction)useCurrentLocation:(id)sender;
- (IBAction)useCustomLocation:(id)sender;

- (IBAction)saveSettings:(id)sender;
- (IBAction)getHelp:(id)sender;
- (IBAction)changeTheatreDistance:(id)sender;


@end

@implementation UserSettingsViewController

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
}


- (void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int distance =  [userDefaults integerForKey:@"userDistance"];
    if (distance == 5) {
        theatreDistanceControl.selectedSegmentIndex = 0;
    } else if (distance == 10) {
        theatreDistanceControl.selectedSegmentIndex = 1;
    } else if (distance == 20) {
        theatreDistanceControl.selectedSegmentIndex = 2;
    } else if (distance == 40)
        theatreDistanceControl.selectedSegmentIndex = 3;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useCurrentLocation:(id)sender {
    if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"]) || ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES)) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useCurrentLocation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            nil;
        }];
    }
}

- (IBAction)useCustomLocation:(id)sender {
    NSString *userSetLocation = locationField.text;
    if (userSetLocation != [[NSUserDefaults standardUserDefaults] valueForKey:@"customLocationName"]) {
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@", userSetLocation] forKey:@"customLocationName"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
    NSLog(@"pressed submit custom location");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:locationField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.longitude forKey:@"longitude"];
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.latitude forKey:@"latitude"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            nil;
        }];
    }];
}
}

- (IBAction)saveSettings:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)getHelp:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)changeTheatreDistance:(id)sender {
    if (theatreDistanceControl.selectedSegmentIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 3) {
        [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"userDistance"];
    }
}
@end
