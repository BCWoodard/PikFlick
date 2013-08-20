//
//  PFMapViewController.h
//  PikFlick
//
//  Created by Brad Woodard on 8/20/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface PFMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@end