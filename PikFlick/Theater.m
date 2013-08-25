//
//  Theater.m
//  PikFlick
//
//  Created by Brad Woodard on 8/20/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "Theater.h"

@implementation Theater
@synthesize title = _title;
@synthesize theaterID = _theaterID;
@synthesize theaterStreet = _theaterStreet;
@synthesize theaterCity = _theaterCity;
@synthesize theaterState = _theaterState;
@synthesize theaterZip = _theaterZip;
@synthesize theaterLatitude = _theaterLatitude;
@synthesize theaterLongitude = _theaterLongitude;


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


@end
