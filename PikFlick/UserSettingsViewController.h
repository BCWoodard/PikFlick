//
//  UserSettingsViewController.h
//  PikFlick
//
//  Created by Jeremy Herrero on 8/26/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface UserSettingsViewController : UIViewController <CLLocationManagerDelegate> {
CLLocationManager           *locationManager;
CLLocation                  *currentLocation;
}

@property (strong, nonatomic) NSString *latForQuery;
@property (strong, nonatomic) NSString *lngForQuery;
@property (nonatomic, strong) MKPlacemark *placemark;


@end
