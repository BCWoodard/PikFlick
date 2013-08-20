//
//  AppDelegate.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    CLLocationManager           *locationManager;
    CLLocation                  *currentLocation;
    
    NSString                    *latForQuery;
    NSString                    *lngForQuery;
}

@property (strong, nonatomic) UIWindow *window;

@end