//
//  Theater.h
//  PikFlick
//
//  Created by Brad Woodard on 8/20/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Theater : NSObject <MKAnnotation>


@property (strong, nonatomic) NSString  *theaterID;
@property (strong, nonatomic) NSString  *title;     // theater name
@property (strong, nonatomic) NSString  *theaterStreet;
@property (strong, nonatomic) NSString  *theaterCity;
@property (strong, nonatomic) NSString  *theaterState;
@property (strong, nonatomic) NSString  *theaterZip;
@property (strong, nonatomic) NSString  *theaterLatitude;
@property (strong, nonatomic) NSString  *theaterLongitude;
@property (strong, nonatomic) NSString  *theaterTicketURI;

- (instancetype)initWithTheaterDictionary:(NSDictionary *)theaterDictionary;

@end
