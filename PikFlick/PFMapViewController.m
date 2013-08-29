//
//  PFMapViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/20/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "PFMapViewController.h"
#import "Movie.h"
#import "Theater.h"


@interface PFMapViewController ()
{
    __weak IBOutlet MKMapView   *mapViewOutlet;
    
    NSString                    *startDate;
    NSMutableArray              *theatersShowingMovie;
    NSDictionary                *theaterIDAndURI;
}

@end

@implementation PFMapViewController
@synthesize incomingTheaters;
@synthesize incomingLatForQuery;
@synthesize incomingLngForQuery;
@synthesize incomingTMSID;

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
    theatersShowingMovie = [[NSMutableArray alloc] initWithCapacity:15];
    theaterIDAndURI = [[NSDictionary alloc] init];
    
    [super viewDidLoad];
    
    
    // Get data to show specific theaters
    [self getTheatersShowingMovie];
    
    // Listen for notification that download is complete
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(setupInitialMap)
     name:@"DownloadComplete"
     object:nil];
}

/*
 - (void)viewDidAppear:(BOOL)animated
 {
 [self getUniqueTheaterIDS:theatersShowingMovie];
 }
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - Setup Initial Map
- (void)setupInitialMap
{
    MKCoordinateSpan startSpan;
    MKCoordinateRegion startRegion;
    
    // Set up map and span
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(incomingLatForQuery.floatValue, incomingLngForQuery.floatValue);
        startSpan = MKCoordinateSpanMake(0.3, 0.3);
        startRegion = MKCoordinateRegionMake(startCoordinate, startSpan);
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == NO) {
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake([[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"], [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"]);
        startSpan = MKCoordinateSpanMake(0.3, 0.3);
        startRegion = MKCoordinateRegionMake(startCoordinate, startSpan);
    } else {
        NSLog(@"error passing coordinates to mapView");
    }
    
    mapViewOutlet.showsUserLocation = YES;
    mapViewOutlet.region = startRegion;
    mapViewOutlet.delegate = self;
    
    [mapViewOutlet addAnnotations:self.incomingTheaters];
    
//    CLLocationCoordinate2D theaterCoord;
//    NSArray *uniqueTheaters = [self createUniqueTheatersArray:theatersShowingMovie];
//    NSLog(@"Unique theaters: %@", uniqueTheaters);
//    for (int index = 0; index < [incomingTheaters count]; index++) {
//        Theater *tempTheater = [incomingTheaters objectAtIndex:index];
//        
//        for (NSString *theaterID in uniqueTheaters) {
//            if ([theaterID isEqualToString:tempTheater.theaterID]) {
//                theaterCoord.latitude = [tempTheater.theaterLatitude doubleValue];
//                theaterCoord.longitude = [tempTheater.theaterLongitude doubleValue];
//                
//                MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
//                annotationPoint.coordinate = theaterCoord;
//                annotationPoint.title = [[incomingTheaters objectAtIndex:index] title];
//                annotationPoint.subtitle = [NSString stringWithFormat:@"%@ %@, %@", tempTheater.theaterStreet, tempTheater.theaterCity, tempTheater.theaterState];
//                
//                [mapViewOutlet addAnnotation:annotationPoint];
//                break;
//            }
//        }
//    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewgForAnnotation:(id <MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:[Theater class]]) {
        return nil;
    }
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Theater"];
    if(!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Theater"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
    } else {
        annotationView.annotation = annotation;
        
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Theater *selectedTheater = (Theater *)view.annotation;
    NSLog(@"YOU SELECTED: %@", selectedTheater.theaterTicketURI);
}


// Get todays date for TMS query
- (NSString *)getTodaysDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    startDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return startDate;
}

- (void)getLatAndLngForTMS
{
    // Get Latitude and Longitude for device
    incomingLatForQuery = [(AppDelegate *)[[UIApplication sharedApplication] delegate] latForQuery];
    incomingLngForQuery = [(AppDelegate *)[[UIApplication sharedApplication] delegate] lngForQuery];
}

- (void)getTheatersShowingMovie
{
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {

    [self getTodaysDate];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {

    [self getLatAndLngForTMS];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%@&lng=%@&api_key=%@", incomingTMSID, startDate, incomingLatForQuery, incomingLngForQuery, TMS_API_KEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    PFMapViewController __weak *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *allMovieShowtimesDataDict, NSUInteger idx, BOOL *stop) {
            allMovieShowtimesDataDict = [allDataArray objectAtIndex:idx];
            NSArray *showtimesArray = [allMovieShowtimesDataDict objectForKey:@"showtimes"];

            NSMutableArray *filteredIncoming = [@[] mutableCopy];
            for (NSDictionary *dictionary in showtimesArray) {
                
                NSPredicate *theaterIDPredicate = [NSPredicate predicateWithFormat:@"theaterID == %@", dictionary[@"theatre"][@"id"]];
                Theater *existingTheater = [[incomingTheaters filteredArrayUsingPredicate:theaterIDPredicate] lastObject];
                if (existingTheater && [filteredIncoming containsObject:existingTheater] == NO) {
                    existingTheater.theaterTicketURI = dictionary[@"ticketURI"];
                    [filteredIncoming addObject:existingTheater];
                }
            }
            weakSelf.incomingTheaters = [NSArray arrayWithArray:filteredIncoming];
        }];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
        
        // Stop activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
//    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == NO) {
//        float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"];
//        float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%f&lng=%f&api_key=%@", incomingTMSID, startDate, latitude, longitude, TMS_API_KEY]];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//            
//            // Activity indicator
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//            
//            NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *allMovieShowtimesDataDict, NSUInteger idx, BOOL *stop) {
//                allMovieShowtimesDataDict = [allDataArray objectAtIndex:idx];
//                NSArray *showtimesArray = [allMovieShowtimesDataDict objectForKey:@"showtimes"];
//                
//                [showtimesArray enumerateObjectsUsingBlock:^(NSDictionary *theatreDict, NSUInteger idx, BOOL *stop) {
//                    
//                    theatreDict = [showtimesArray objectAtIndex:idx];
//                    NSString *theaterID = [theatreDict valueForKeyPath:@"theatre.id"];
//                    NSString *theaterURL = [theatreDict valueForKey:@"ticketURI"];
//                    
//                    [theatersShowingMovie addObject:theaterID];
//                    
//                    for (int index = 0; index < [incomingTheaters count]; index++) {
//                        Theater *tempTheater = [incomingTheaters objectAtIndex:index];
//                        
//                        for (NSString *theaterID in theatersShowingMovie) {
//                            if ([theaterID isEqualToString:tempTheater.theaterID]) {
//                                tempTheater.theaterTicketURI = [theatreDict valueForKey:@"ticketURI"];
//                                NSMutableDictionary *tempIDandURLDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theaterID, @"id", theaterURL, @"url", nil];
//                                theaterIDAndURI = tempIDandURLDict;
//                                
//                                break;
//                            }
//                            NSLog(@"theaterDict: %@", theaterIDAndURI);
//                        }
//                    }
//                }];
//            }];
//            
//            // Send notification that our download is complete
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
//            
//            // Stop activity indicator
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        }];
//    }
    }   else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == NO) {
        float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"];
        float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%f&lng=%f&api_key=%@", incomingTMSID, startDate, latitude, longitude, TMS_API_KEY]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        PFMapViewController __weak *weakSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *allMovieShowtimesDataDict, NSUInteger idx, BOOL *stop) {
                allMovieShowtimesDataDict = [allDataArray objectAtIndex:idx];
                NSArray *showtimesArray = [allMovieShowtimesDataDict objectForKey:@"showtimes"];
                
                NSMutableArray *filteredIncoming = [@[] mutableCopy];
                for (NSDictionary *dictionary in showtimesArray) {
                    
                    NSPredicate *theaterIDPredicate = [NSPredicate predicateWithFormat:@"theaterID == %@", dictionary[@"theatre"][@"id"]];
                    Theater *existingTheater = [[incomingTheaters filteredArrayUsingPredicate:theaterIDPredicate] lastObject];
                    if (existingTheater && [filteredIncoming containsObject:existingTheater] == NO) {
                        existingTheater.theaterTicketURI = dictionary[@"ticketURI"];
                        [filteredIncoming addObject:existingTheater];
                    }
                }
                weakSelf.incomingTheaters = [NSArray arrayWithArray:filteredIncoming];
            }];
            
            // Send notification that our download is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
            
            // Stop activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    
}
}


//- (NSArray *)createUniqueTheatersArray:(NSArray *)array
//{
//    // Get unique theaters from data results
//    NSArray *tempArray = [[NSOrderedSet orderedSetWithArray:theatersShowingMovie] array];
//    
//    return tempArray;
//}

@end
