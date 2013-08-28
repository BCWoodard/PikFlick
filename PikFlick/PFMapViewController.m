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
    
    CLLocationCoordinate2D theaterCoord;
    
    // Setup theaters on the map
    // Get unique theaters from data results
    NSArray *uniqueTheaters = [[NSOrderedSet orderedSetWithArray:theatersShowingMovie] array];
    
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


- (NSArray *)getUniqueTheaterIDS
{
    /*
     NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:theatersArray];
     NSSet *uniqueTheaters = [orderedSet set];
     */
    
    /*
     NSArray* uniqueTheaters = [theatersArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
     NSLog(@"%@", uniqueTheaters);
     */
    /*
     NSMutableArray *uniqueTheaters = [[NSMutableArray alloc] initWithArray:[[NSSet setWithArray:theatersShowingMovie] allObjects]];
     NSLog(@"uniqueTheaters: %@", uniqueTheaters);
     return uniqueTheaters;
     */
    
    
    NSArray *uniqueTheaters = [[NSOrderedSet orderedSetWithArray:theatersShowingMovie] array];
    NSLog(@"UniqueTheaters: %@", uniqueTheaters);
    
    return uniqueTheaters;
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
    
    
    if (([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) || (![[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"])) {
        [self getLatAndLngForTMS];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%@&lng=%@&api_key=%@", incomingTMSID, startDate, incomingLatForQuery, incomingLngForQuery, TMS_API_KEY]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *showtimeDict, NSUInteger idx, BOOL *stop) {
                showtimeDict = [allDataArray objectAtIndex:idx];
                NSArray *showtimesArray = [showtimeDict objectForKey:@"showtimes"];
                [showtimesArray enumerateObjectsUsingBlock:^(NSDictionary *theatreDict, NSUInteger idx, BOOL *stop) {
                    theatreDict = [showtimesArray objectAtIndex:idx];
                    NSString *theaterID = [[theatreDict objectForKey:@"theatre"] valueForKey:@"id"];
                    
                    [theatersShowingMovie addObject:theaterID];
                    
                    
                }];
            }];
            
            // Send notification that our download is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
            
            // Stop activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {
        float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"];
        float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/%@/showings?startDate=%@&numDays=1&lat=%f&lng=%f&api_key=%@", incomingTMSID, startDate, latitude, longitude, TMS_API_KEY]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [allDataArray enumerateObjectsUsingBlock:^(NSDictionary *showtimeDict, NSUInteger idx, BOOL *stop) {
                showtimeDict = [allDataArray objectAtIndex:idx];
                NSArray *showtimesArray = [showtimeDict objectForKey:@"showtimes"];
                [showtimesArray enumerateObjectsUsingBlock:^(NSDictionary *theatreDict, NSUInteger idx, BOOL *stop) {
                    theatreDict = [showtimesArray objectAtIndex:idx];
                    NSString *theaterID = [[theatreDict objectForKey:@"theatre"] valueForKey:@"id"];
                    
                    [theatersShowingMovie addObject:theaterID];
                    
                    
                }];
            }];
            
            // Send notification that our download is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:self];
            
            // Stop activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}

@end
