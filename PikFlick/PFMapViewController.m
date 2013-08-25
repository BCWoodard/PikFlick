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
    __weak IBOutlet MKMapView *mapViewOutlet;
}

@end

@implementation PFMapViewController
@synthesize incomingTheaters;

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
    [super viewDidLoad];

    if (incomingTheaters) {
        [self setupInitialMap];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup Initial Map
- (void)setupInitialMap
{
    CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(41.90, -87.65);
    MKCoordinateSpan startSpan = MKCoordinateSpanMake(0.3, 0.3);
    MKCoordinateRegion startRegion = MKCoordinateRegionMake(startCoordinate, startSpan);
    
    mapViewOutlet.showsUserLocation = YES;
    mapViewOutlet.region = startRegion;
    
    CLLocationCoordinate2D theaterCoord;
    
    for (int index = 0; index < [incomingTheaters count]; index++) {
        
        Theater *tempTheater = [incomingTheaters objectAtIndex:index];
        
        theaterCoord.latitude = [tempTheater.theaterLatitude doubleValue];
        theaterCoord.longitude = [tempTheater.theaterLongitude doubleValue];
        
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate = theaterCoord;
        annotationPoint.title = [[incomingTheaters objectAtIndex:index] title];
        annotationPoint.subtitle = [NSString stringWithFormat:@"%@ %@, %@", tempTheater.theaterStreet, tempTheater.theaterCity, tempTheater.theaterState];
        
        NSLog(@"Theater ID: %@", tempTheater.theaterID);
        
        [mapViewOutlet addAnnotation:annotationPoint];
    }
    
}

/*
- (void)getTMSMovieInTheaterData
{
    NSString *latitude = [(AppDelegate *)[[UIApplication sharedApplication] delegate] latForQuery];
    NSString *longitude = [(AppDelegate *)[[UIApplication sharedApplication] delegate] lngForQuery];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/showings?startDate=2013-08-21&lat=%@&lng=%@&radius=1&units=mi&api_key=%@", latitude, longitude, TMS_API_KEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // code
        Movie *movie = [[Movie alloc] init];
        NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSLog(@"tempArr Count: %i", tempArray.count);
        for (int index = 0; index < [tempArray count]; index++) {
            movie.movieTMSID = [[tempArray objectAtIndex:index] valueForKey:@"tmsId"];
            NSLog(@"tmsId: %@", movie.movieTMSID);
        }
    }];
}
*/
@end
