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
    NSString                                *userSetLocation;
    BOOL                                    distanceWasUpdated;
    BOOL                                    currentLocationWasUpdated;
    BOOL                                    customLocationWasUpdated;
    int                                     distanceToSave;
    float                                   latitudeToUpdate;
    float                                   longitudeToUpdate;
    MKCoordinateRegion                      region;
    __weak IBOutlet UISegmentedControl      *theatreDistanceControl;
    __weak IBOutlet UITextField             *locationField;
    
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
    currentLocationWasUpdated = YES;

    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
    
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        nil;
    //    }];
}

- (IBAction)useCustomLocation:(id)sender {
    
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:locationField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        
        BOOL locationChecksOut = NO;
        
        if (([placemark.country isEqualToString:@"United States"]) || [placemark.country isEqualToString:@"Canada"]) {
            
            if (placemark.locality != nil) {
                locationChecksOut = YES;
                NSLog(@"location checks out %i", locationChecksOut);
            }
        }
        
        if ((locationChecksOut) && (region.center.latitude != 0.000000)) {
            longitudeToUpdate = region.center.longitude;
            latitudeToUpdate = region.center.latitude;
            customLocationWasUpdated = YES;
            locationField.backgroundColor = [UIColor greenColor];
            locationField.text = [NSString stringWithFormat:@"%@ \u2713", locationField.text];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
            //            [self dismissViewControllerAnimated:YES completion:^{
            //                nil;
            //            }];
        } else if (!(locationChecksOut) && ([[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"] != 0.000000)) {
            locationField.backgroundColor = [UIColor whiteColor];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not A Valid Address" message:@"Location provided is not within a valid city or zip code.  Please enter a valid City/State or Zip Code." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            locationField.backgroundColor = [UIColor whiteColor];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Not Recognized" message:@"We were not able to recognize your location.  Please enter a valid City/State or Zip Code." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            locationField.backgroundColor = [UIColor whiteColor];
            [alertView show];
        }
    }];
}


#pragma mark - Pik Your Distance
- (IBAction)changeTheatreDistance:(id)sender {
    if (theatreDistanceControl.selectedSegmentIndex == 0) {
        distanceToSave = 5;
        distanceWasUpdated = YES;
    } else if (theatreDistanceControl.selectedSegmentIndex == 1) {
        distanceToSave = 10;
        distanceWasUpdated = YES;
    } else if (theatreDistanceControl.selectedSegmentIndex == 2) {
        distanceToSave = 20;
        distanceWasUpdated = YES;
    } else if (theatreDistanceControl.selectedSegmentIndex == 3) {
        distanceToSave = 40;
        distanceWasUpdated = YES;
    }
}


#pragma mark - SAVE and DISMISS MODAL
- (IBAction)saveSettings:(id)sender {
    BOOL sendSettingsSavedNotification = NO;
    if (distanceWasUpdated == YES) {
    [[NSUserDefaults standardUserDefaults] setInteger:distanceToSave forKey:@"userDistance"];
        distanceWasUpdated = NO;
        sendSettingsSavedNotification = YES;
    }
    if (customLocationWasUpdated == YES) {
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useCurrentLocation"];
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.longitude forKey:@"longitude"];
        [[NSUserDefaults standardUserDefaults] setFloat:region.center.latitude forKey:@"latitude"];
        customLocationWasUpdated = NO;
        sendSettingsSavedNotification = YES;
    }
    if (currentLocationWasUpdated == YES) {
        currentLocationWasUpdated = NO;

        [self getCurrentLocation];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useCurrentLocation"];

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsSaved" object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)cancelChanges:(id)sender
{
    distanceWasUpdated = NO;
    customLocationWasUpdated = NO;
    currentLocationWasUpdated = NO;
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
