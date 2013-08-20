//
//  pfDetailViewController.m
//  PikFlick
//
//  Created by Jessica Sturme on 19/08/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "pfDetailViewController.h"
#import "ViewController.h"
#import "PFMapViewController.h"

@interface pfDetailViewController ()
{
    CLLocationManager           *locationManager;
    CLLocation                  *currentLocation;
    NSString                    *startDate;
    NSString                    *latForQuery;
    NSString                    *lngForQuery;
        
    __weak IBOutlet UITableView *myDetailTableView;
}


@end

@implementation pfDetailViewController
@synthesize incomingMovie;

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
    // Alloc & init
    locationManager = [[CLLocationManager alloc] init];
    
    [super viewDidLoad];

    // Get current date and location so we can retrieve theater and showtime info
    [self getTodaysDate];
//    [self getCurrentLocation];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getTMSData];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.incomingMovie.movieTitle;
    } else if (section ==1) {
        return nil;
        
    } else  {
        return @"Critics Consensus";
        }
    }

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section ==1) {
        return 2;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section  == 0)
    {
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionZero" forIndexPath:indexPath];
    
    //UILabel* myUILabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 296, 0)];
    
      cell.textLabel.text = @"Section One";
        
        return cell;
        
//        UILabel *mylabel = [[UILabel alloc] initWithFrame:CGRectMake(5,5, 150, 40)];
//        [cell.contentView addSubview:mylabel];
//        
//        //cell.textLabel = myUILabel;
//       // cell.textLabel.text = sampleText;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.textLabel.numberOfLines = 0;
//        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
//        //[myUILabel sizeToFit];
//        
//        CGSize constraintSize = CGSizeMake(255.0f, MAXFLOAT);
//        CGSize labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
       // mylabel = labelSize;
        
        
        
    } else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionOne" forIndexPath:indexPath];
        
        if (indexPath.row == 0){
            cell.textLabel.text = @"Where and When";
        } else {
        cell.textLabel.text = @"Watch the Trailer";
        }
        return  cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionTwo" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Section Three";
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toMapView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toMapView"]) {
        PFMapViewController *mapViewController = segue.destinationViewController;

    }
    
}

//-(CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
//{
//    
//    CGSize size = [sampleText sizeWithFont: [UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(255.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    //        NSLog(@"text: %@, index: %@, size.height: %f, size.width: %f", text2, indexPath, size.height, size.width);
//    
//    if((size.height+30.0f) < 80.0)
//        return 80.0f;
//    else
//        return (size.height + 30.0f);
//}


//tableView:heightForRowAtIndexPath:sizeWithFont:constrainedToSize:

#pragma mark - TMS Data Retrieval -
/*
    TMS Connection Info
    Username: bcwoodard
    Password: MobileMakers2013
    API Key:  bbxfsp9fbvywdtwparw9hugt
 
    First Feed: "Movies Playing in Local Theaters"
    Data to Grab:
    - Match movie.movieTitle to key "title"
    - Get TMSID
    - Get Theater ID
 
    Must pass:
    - Start date: yyyy-mm-dd
    - numDays
    - Latitude
    - Longitude
 
    Example Query: 
    http://data.tmsapi.com/v1/movies/showings?startDate=2013-08-19&numDays=5&lat=41.8491&lng=-87.6353&api_key=bbxfsp9fbvywdtwparw9hugt
 
*/

// #1. Get todays date for TMS query
- (NSString *)getTodaysDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    startDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"Todays Date: %@", startDate);
    return startDate;
}

//// #2. Get Current Location
//- (void)getCurrentLocation
//{
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//    [locationManager startUpdatingLocation];
//    
//}
//
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    currentLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
//    
//    latForQuery = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
//    lngForQuery = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
//    
//    [locationManager stopUpdatingLocation];
//    
//}


- (void)getTMSData
{
    // Activate the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Generate NSURL and perform TMS query
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/showings?startDate=%@&numDays=1&lat=%@&lng=%@&radius=10&units=mi&api_key=%@", startDate, latForQuery, lngForQuery, TMS_API_KEY]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Retrieve the data array from TMS
        NSArray *tmsMovieArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Use NSPredicate so we retrieve data for the movie with the
        // key = incomingMovie.movieTitle

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title == %@)", self.incomingMovie.movieTitle];
        
        // Filter the array so we grab the single object with the same title as
        // our movie object
        NSArray *filteredArray = [tmsMovieArray filteredArrayUsingPredicate:predicate];
        NSLog(@"filteredArray: %@", filteredArray);
        // Set our incomingMovie property equal to tmsId from TMS data
        incomingMovie.movieTMSID = [[filteredArray objectAtIndex:0] valueForKey:@"tmsId"];
        NSDictionary *filteredMovieDictionary = [filteredArray lastObject];
        if (filteredMovieDictionary) {
            self.incomingMovie.movieTMSID = filteredMovieDictionary[@"tmsId"];
        }
        NSLog(@"tmsID: %@", self.incomingMovie.movieTMSID);
        
        // stop the activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

@end
