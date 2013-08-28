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
    // Set up map and span
    CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(41.90, -87.65);
    MKCoordinateSpan startSpan = MKCoordinateSpanMake(0.3, 0.3);
    MKCoordinateRegion startRegion = MKCoordinateRegionMake(startCoordinate, startSpan);
    
    mapViewOutlet.showsUserLocation = YES;
    mapViewOutlet.region = startRegion;
    mapViewOutlet.delegate = self;
    
    CLLocationCoordinate2D theaterCoord;
    
    // Setup theaters on the map
    // Get unique theaters from data results
    //NSArray *uniqueTheaters = [[NSOrderedSet orderedSetWithArray:theatersShowingMovie] array];
    NSArray *uniqueTheaters = [self createUniqueTheatersArray:theatersShowingMovie];
    NSLog(@"Unique theaters: %@", uniqueTheaters);
    for (int index = 0; index < [incomingTheaters count]; index++) {        
        Theater *tempTheater = [incomingTheaters objectAtIndex:index];
        
        for (NSString *theaterID in uniqueTheaters) {
            if ([theaterID isEqualToString:tempTheater.theaterID]) {
                theaterCoord.latitude = [tempTheater.theaterLatitude doubleValue];
                theaterCoord.longitude = [tempTheater.theaterLongitude doubleValue];
                
                MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
                annotationPoint.coordinate = theaterCoord;
                annotationPoint.title = [[incomingTheaters objectAtIndex:index] title];
                annotationPoint.subtitle = [NSString stringWithFormat:@"%@ %@, %@", tempTheater.theaterStreet, tempTheater.theaterCity, tempTheater.theaterState];
                
                [mapViewOutlet addAnnotation:annotationPoint];
                break;
            }
        }
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
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
    // Go to edit view
    
    NSLog(@"Theater ID: %@\nTheater URL: %@", [theaterIDAndURI valueForKey:@"id"], [theaterIDAndURI valueForKey:@"url"]);
    
    
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
    [self getTodaysDate];
    [self getLatAndLngForTMS];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%@&lng=%@&api_key=%@", incomingTMSID, startDate, incomingLatForQuery, incomingLngForQuery, TMS_API_KEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *allMovieShowtimesDataDict, NSUInteger idx, BOOL *stop) {
            allMovieShowtimesDataDict = [allDataArray objectAtIndex:idx];
            NSArray *showtimesArray = [allMovieShowtimesDataDict objectForKey:@"showtimes"];

            [showtimesArray enumerateObjectsUsingBlock:^(NSDictionary *theatreDict, NSUInteger idx, BOOL *stop) {
                
                theatreDict = [showtimesArray objectAtIndex:idx];
                NSString *theaterID = [theatreDict valueForKeyPath:@"theatre.id"];
                NSString *theaterURL = [theatreDict valueForKey:@"ticketURI"];
                
                [theatersShowingMovie addObject:theaterID];
                
                for (int index = 0; index < [incomingTheaters count]; index++) {
                    Theater *tempTheater = [incomingTheaters objectAtIndex:index];
                    
                    for (NSString *theaterID in theatersShowingMovie) {
                        if ([theaterID isEqualToString:tempTheater.theaterID]) {
                            tempTheater.theaterTicketURI = [theatreDict valueForKey:@"ticketURI"];
                            NSMutableDictionary *tempIDandURLDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theaterID, @"id", theaterURL, @"url", nil];
                            theaterIDAndURI = tempIDandURLDict;

                            break;
                        }
                        NSLog(@"theaterDict: %@", theaterIDAndURI);
                    }
                }
            }];
        }];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
        
        // Stop activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (NSArray *)createUniqueTheatersArray:(NSArray *)array
{
    // Get unique theaters from data results
    NSArray *tempArray = [[NSOrderedSet orderedSetWithArray:theatersShowingMovie] array];
    
    return tempArray;
}

@end
