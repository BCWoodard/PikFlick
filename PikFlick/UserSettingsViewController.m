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
    NSString *userSetLocation;
    __weak IBOutlet UISegmentedControl *theatreDistanceControl;
    __weak IBOutlet UITextField *locationField;
    
}
- (IBAction)useCurrentLocation:(id)sender;
- (IBAction)useCustomLocation:(id)sender;
- (IBAction)cancelChanges:(id)sender;

- (IBAction)saveSettings:(id)sender;

- (IBAction)getHelp:(id)sender;
- (IBAction)changeTheatreDistance:(id)sender;


@end

@implementation UserSettingsViewController

@synthesize latForQuery;
@synthesize lngForQuery;

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

- (void)getCurrentLocation
{
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    self.latForQuery = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    self.lngForQuery = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    
    [locationManager stopUpdatingLocation];
    
}

#pragma mark - Pik Your Location
- (IBAction)useCurrentLocation:(id)sender {
    
    [self getCurrentLocation];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useCurrentLocation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
    
//    [self dismissViewControllerAnimated:YES completion:^{
//        nil;
//    }];
}

- (IBAction)useCustomLocation:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:locationField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.longitude forKey:@"longitude"];
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.latitude forKey:@"latitude"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
        
        if (([[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"] != 0.000000) && ([[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"] != 0.000000)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
//            [self dismissViewControllerAnimated:YES completion:^{
//                nil;
//            }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Not Recognized" message:@"We were not able to regognize your location." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}


#pragma mark - Pik Your Distance
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


#pragma mark - SAVE and DISMISS MODAL
- (IBAction)saveSettings:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)cancelChanges:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - How to PikFlick
- (IBAction)getHelp:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}



@end
