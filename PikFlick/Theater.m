//
//  Theater.m
//  PikFlick
//
//  Created by Brad Woodard on 8/20/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "Theater.h"

#import <CoreLocation/CoreLocation.h>

@implementation Theater
@synthesize title = _title;
@synthesize theaterID = _theaterID;
@synthesize theaterStreet = _theaterStreet;
@synthesize theaterCity = _theaterCity;
@synthesize theaterState = _theaterState;
@synthesize theaterZip = _theaterZip;
@synthesize theaterLatitude = _theaterLatitude;
@synthesize theaterLongitude = _theaterLongitude;
@synthesize theaterTicketURI = _theaterTicketURI;


- (instancetype)initWithTheaterDictionary:(NSDictionary *)theaterDictionary
{
    self = [super init];
    
    if (self) {
        _theaterID = [theaterDictionary valueForKey:@"theatreId"];  // NOTE spelling of theatre
        _title = [theaterDictionary valueForKey:@"name"];
        _theaterLatitude = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"geoCode"] valueForKey:@"latitude"];
        _theaterLongitude = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"geoCode"] valueForKey:@"longitude"];
        _theaterStreet = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"address"] valueForKey:@"street"];
        _theaterCity = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"address"] valueForKey:@"city"];
        _theaterState = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"address"] valueForKey:@"state"];
        _theaterZip = [[[theaterDictionary objectForKey:@"location"] objectForKey:@"address"] valueForKey:@"postalCode"];
    }
    
    return self;
}


#pragma mark - MKAnnotation
- (NSString *)title
{
    return _title;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%@, %@ %@", _theaterStreet, _theaterCity, _theaterState];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([_theaterLatitude floatValue], [_theaterLongitude floatValue]);
}
@end
