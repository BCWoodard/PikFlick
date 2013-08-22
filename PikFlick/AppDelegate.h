//
//  AppDelegate.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    CLLocationManager           *locationManager;
    CLLocation                  *currentLocation;
    
    NSString                    *latForQuery;
    NSString                    *lngForQuery;
    BOOL                        getTMSData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *latForQuery;
@property (strong, nonatomic) NSString *lngForQuery;
@property BOOL                         getTMSData;

@end