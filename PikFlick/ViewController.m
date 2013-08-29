//
//  ViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Movie.h"
#import "Theater.h"
#import "Constants.h"
#import "pfCustomCell.h"
#import "Reachability.h"
#import "UserSettingsViewController.h"
#import "pfDetailViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>


@interface ViewController ()
{
    BOOL                        deleteSelectedMove;
    BOOL                        movieSelectedFromTable;
    NSArray                     *moviesArray;
    NSArray                     *moviesShortlist;
    NSArray                     *theatersArray;
    Movie                       *selectedMovie;
    CLLocationManager           *locationManager;
    NSString                    *startDate;
    
    __weak IBOutlet UIImageView *tutorialOverlay;
    __weak IBOutlet UITableView *moviesTable;
    __weak IBOutlet UIView      *selectedMovieOverlay;
    __weak IBOutlet UIButton    *selectedMovieCloseButton;
    __weak IBOutlet UIButton    *startOverButton;
    __weak IBOutlet UILabel     *selectedMovieTitle;
    __weak IBOutlet UILabel     *announcementGreeting;
    __weak IBOutlet UIImageView *selectedMoviePoster;
    
}
- (IBAction)closeSelectedMovieOverlay:(id)sender;
- (IBAction)startOver:(id)sender;

@end

@implementation ViewController
@synthesize incomingLatForQuery;
@synthesize incomingLngForQuery;


- (void)viewDidLoad
{
    // Alloc and init moviesToSeeArray
    moviesShortlist = [[NSArray alloc] init];
    
    [super viewDidLoad];
    
    // Utility methods
    [self checkForInternet];
    [self getRottenTomatoesDATA];
    [self getTMSTheaterData];
    [self listenForNotifications];
    
    // UI Elements
    moviesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    moviesTable.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [startOverButton setHidden:YES];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:selectedMovieOverlay];
    
    selectedMoviePoster.layer.shadowColor = [UIColor whiteColor].CGColor;
    selectedMoviePoster.layer.shadowOpacity = 1;
    selectedMoviePoster.layer.shadowRadius = 15;
    
    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    [selectedMovieOverlay setHidden:YES];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    moviesTable.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 64);
    
    deleteSelectedMove = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    //hide highlighting when returning to table
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [moviesTable indexPathForSelectedRow];
    [moviesTable deselectRowAtIndexPath:selectedIndexPath animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsSaved)
                                                 name:@"settingsSaved"
                                               object:nil];
}

- (void)settingsSaved {
    NSLog(@"settingsSaved method called");
    NSLog(@"current lat %@, long %@", incomingLatForQuery, incomingLngForQuery);
    NSLog(@"custom lat %f, long %f", [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"], [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"]);
    
    
    [self getRottenTomatoesDATA];
    [self getTMSTheaterData];
    [self listenForNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    //[self getTMSMovieInTheaterData];
    BOOL hasBeenLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstTime"];
    
    if (!hasBeenLaunched) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useCurrentLocation"];
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"userDistance"];
        [self tutorialOverlay];
    } else {
        [tutorialOverlay setHidden:YES];
    }
}

- (void)tutorialOverlay
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [tutorialOverlay setHidden:NO];
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    CGFloat windowWidth = windowRect.size.width;
    CGFloat windowHeight = windowRect.size.height;
    tutorialOverlay.frame = CGRectMake(0.0, -20.0f, windowWidth, windowHeight);
    
    if (windowHeight == 480.0f) {
//        tutorialOverlay.frame = CGRectMake(0, -10, windowWidth, windowHeight);
        tutorialOverlay.image = [UIImage imageNamed:@"overlay"];
        
    } else {
//        tutorialOverlay.frame = CGRectMake(0, -10, windowWidth, windowHeight);
        tutorialOverlay.image = [UIImage imageNamed:@"overlay-504h"];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstTime"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *dismissOverlay = [[event allTouches] anyObject];
    
    if (dismissOverlay) {
        [UIView animateWithDuration:0.3f animations:^{
            tutorialOverlay.transform = CGAffineTransformScale(tutorialOverlay.transform, 0.01f, 0.01f);
        } completion:^(BOOL finished) {
            tutorialOverlay.hidden = YES;
        }];
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark - Shaking and Movie Selection
- (void)preselectRandomMovie
{
    if ([moviesShortlist count]) {
        selectedMovie = [self randomMovieFromArray:moviesShortlist];
    } else if ([moviesArray count]) {
        selectedMovie = [self randomMovieFromArray:moviesArray];
    }
    
    [selectedMovie fetchPoster];
}

- (Movie *)randomMovieFromArray:(NSArray *)array
{
    if (![array count]) {
        return nil;
    }
    
    return [array objectAtIndex:arc4random() % [array count]];
}

- (void)removeSelectedMovieAndReloadTableView
{
    selectedMovie.shortlisted = NO;
    
    moviesShortlist = [self removeObject:selectedMovie fromArray:moviesShortlist];
    moviesArray = [self removeObject:selectedMovie fromArray:moviesArray];
    
    deleteSelectedMove = NO;
    
    [moviesTable reloadData];
    [self preselectRandomMovie];
}

- (NSArray *)removeObject:(id)objectToRemove fromArray:(NSArray *)array
{
    if (![array containsObject:objectToRemove]) {
        return array;
    }
    NSMutableArray *tempArray = [array mutableCopy];
    [tempArray removeObject:objectToRemove];
    return [tempArray copy];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion != UIEventSubtypeMotionShake) {
        return;
    }
    
    if (selectedMovieOverlay.isHidden == YES) {
        [self initialAnimatedOverlay];
    } else {
        [self animatedOverlayRemovalAndReplacement];
    }
    if ((moviesArray.count != 1) && (deleteSelectedMove == YES)) {
        [self removeSelectedMovieAndReloadTableView];
    }
}


- (void)initialAnimatedOverlay {
    if (!selectedMovie) {
        [self preselectRandomMovie];
    }
    if (moviesArray.count != 1) {
        announcementGreeting.text = [self announcementMessage];
    } else {
        announcementGreeting.text = @"Only Movie Left";
    }
    selectedMoviePoster.image = selectedMovie.moviePoster;
    selectedMovieTitle.text = selectedMovie.movieTitle;
    
    if (moviesArray.count == 1) {
        startOverButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        selectedMovieOverlay.transform = CGAffineTransformIdentity;
        if (screenSize.height > 480) {
            selectedMovieOverlay.frame = CGRectMake(0, 20, 320, screenSize.height - 20);
        } else {
            selectedMovieOverlay.frame = CGRectMake(0, 20, 320, screenSize.height - 20);
        }
        //self.view.bounds.size.height;
        [selectedMovieOverlay setHidden:NO];
    } completion:^(BOOL finished) {
        //        selectedMovieOverlay.frame = CGRectMake(0, 0, 320, 414);
    }];
}


- (void)animatedOverlayRemovalAndReplacement {
    deleteSelectedMove = YES;
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [self initialAnimatedOverlay];
    }];
}


- (NSString *)announcementMessage {
    //    NSArray *announcementMessages = [[NSArray alloc] initWithObjects:@"It is decidedly so", @"It is certain", @"You will see", @"We have decided", @"Without a doubt", @"Take it or leave it", @"Most likely", @"Signs point to", @"Tonight you will see", @"Your fate is", @"Your key to success", @"", nil];
    NSArray *announcementMessages = [[NSArray alloc] initWithObjects:@"It is so", @"It is certain", @"You will see", @"We have decided", @"Without a doubt", @"Most likely", @"Signs point to", @"Tonight is", @"Your fate is", nil];
    int index = arc4random() % announcementMessages.count;
    return [announcementMessages objectAtIndex:index];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma  mark - UITableViewDataSource
- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [moviesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    pfCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Need to set the background color to clear in order for gradient to show
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    // Grab movie object and pass it to the custom cell where the properties
    // are extracted by the method 'loadMovie:'
    Movie *movie = [moviesArray objectAtIndex:indexPath.row];
    [cell loadMovie:movie];
    
    // The ViewController ISA delegate of CustomCell
    cell.delegate = self;
    cell.movie = movie;
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey.jpg"]];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    movieSelectedFromTable = YES;
    [self performSegueWithIdentifier:@"toDetailView" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDetailView"]) {
        pfDetailViewController *detailViewController = segue.destinationViewController;
        if (movieSelectedFromTable == YES) {
            
            detailViewController.incomingMovie = [moviesArray objectAtIndex:[moviesTable indexPathForSelectedRow].row];
            detailViewController.incomingTheaters = theatersArray;
            
        } else if (movieSelectedFromTable == NO) {
            detailViewController.incomingMovie = selectedMovie;
            detailViewController.incomingTheaters = theatersArray;
            [self preselectRandomMovie];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


#pragma mark - Get DATA
- (void)getRottenTomatoesDATA
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=%i&page=1&country=us&apikey=%@", MOVIE_RETRIEVAL_LIMIT, ROTTEN_TOMATOES_API_KEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Retrieve all the Rotten Tomatoes movie data
        NSDictionary *rottenTomatoesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Create an array of movie data and a mutable temp array to hold movie objects
        NSArray *dataMovieArray = [rottenTomatoesJSON objectForKey:@"movies"];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[dataMovieArray count]];
        
        for (NSDictionary *dictionary in dataMovieArray) {
            // Create a movie using our init override method in Movie.m, set the shortlist value and add to our tempArray
            Movie *movie = [[Movie alloc] initWithMovieDictionary:dictionary];
            movie.shortlisted = NO;
            [tempArray addObject:movie];
        }
        
        // Populate moviesArray with tempArray
        // Again, we do this to protect our arrays from accidental edits, etc.
        moviesArray = [NSArray arrayWithArray:tempArray];
        [self preselectRandomMovie];
        
        if ([moviesArray count] == MOVIE_RETRIEVAL_LIMIT) {
            [self getTMSMovieInTheaterData];
        }
        
        
        // Stop NetworkActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [moviesTable reloadData];
    }];
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


- (void)getTMSMovieInTheaterData
{
    [self getLatAndLngForTMS];
    NSString *todaysDate = [self getTodaysDate];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/showings?startDate=%@&lat=%@&lng=%@&radius=%i&units=mi&api_key=%@", todaysDate, incomingLatForQuery, incomingLngForQuery, [[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"], TMS_API_KEY]];
        
        NSLog(@"%@", url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for (NSDictionary *tmsMovie in tempArray) {
                for (Movie *movie in moviesArray) {
                    if ([movie.movieTitle isEqualToString:[tmsMovie valueForKey:@"title"]]) {
                        movie.movieTMSID = [tmsMovie valueForKey:@"tmsId"];
                        NSLog(@"Movie Name: %@, TMSID: %@", movie.movieTitle, movie.movieTMSID);
                        break;
                    }
                }
            }
        }];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == NO) {
        float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"];
        float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/movies/showings?startDate=%@&lat=%f&lng=%f&radius=%i&units=mi&api_key=%@", todaysDate, latitude, longitude, [[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"], TMS_API_KEY]];
        
        NSLog(@"%@", url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for (NSDictionary *tmsMovie in tempArray) {
                for (Movie *movie in moviesArray) {
                    if ([movie.movieTitle isEqualToString:[tmsMovie valueForKey:@"title"]]) {
                        movie.movieTMSID = [tmsMovie valueForKey:@"tmsId"];
                        NSLog(@"Movie Name: %@, TMSID: %@", movie.movieTitle, movie.movieTMSID);
                        break;
                    }
                }
            }
        }];
    }
}


- (void)getTMSTheaterData
{
    // Activate the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == YES) {
        // Get latitude and longitude values
        [self getLatAndLngForTMS];
        
        // Generate NSURL and perform TMS query
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/theatres?lat=%@&lng=%@&radius=%i&units=mi&api_key=%@", incomingLatForQuery, incomingLngForQuery, [[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"], TMS_API_KEY]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Retrieve theater data array from TMS
            NSArray *tmsTheatersArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray *tempTheaters = [[NSMutableArray alloc] initWithCapacity:25];
            
            for (NSDictionary *dictionary in tmsTheatersArray) {
                Theater *theater = [[Theater alloc] initWithTheaterDictionary:dictionary];
                [tempTheaters addObject:theater];
            }
            
            theatersArray = tempTheaters;
            
            // stop the activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useCurrentLocation"] == NO) {
        float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"longitude"];
        float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latitude"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/theatres?lat=%f&lng=%f&radius=%i&units=mi&api_key=%@", latitude, longitude, [[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"], TMS_API_KEY]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Retrieve theater data array from TMS
            NSArray *tmsTheatersArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray *tempTheaters = [[NSMutableArray alloc] initWithCapacity:25];
            
            for (NSDictionary *dictionary in tmsTheatersArray) {
                Theater *theater = [[Theater alloc] initWithTheaterDictionary:dictionary];
                [tempTheaters addObject:theater];
            }
            
            theatersArray = tempTheaters;
            
            // stop the activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }];
    }
    
}

#pragma mark - COLOR THE CELLS
- (UIColor *)colorForIndex:(NSInteger)index
{
    NSUInteger itemCount = moviesArray.count - 1;
    float val = ((float)index / (float)itemCount) * 0.8;
    
    return [UIColor colorWithRed:1.0 green:val blue:0.1 alpha:0.8];
    
}

- (void)dealloc
{
    // dealloc our notification centers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GENRE_FOUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:THUMBNAIL_FOUND_NOTIFICATION object:nil];
    
}

#pragma mark - DELEGATE IMPLEMENTATION
- (void)deleteMovieFromLists:(Movie *)movie
{
    // Use the moviesTable to animate the removal of this row
    // We don't want the app to crash if someone deletes the last item from the
    // array, so add the 'if' conditional
    // 1. If the movie is shortlisted - delete from that array
    //      a. Make a mutable copy
    //      b. Identify the movie index in the array
    //      c. Remove the object at that index
    //      d. Set moviesShortlist equal to tempShortlist
    // 2. Make a mutable copy of moviesArray
    // 3. Get the index of the selected movie
    // 4. In order to make changes to the tableView on the fly and not crash, we must
    //    call 'beginUpdates' on moviesTable
    // 5. Remove the movie from tempArray
    // 6. Delete the row from the tableView with fade animation
    // 7. Refill moviesArray with our tempArray
    // 8. Must complete the beginUpdates with 'endUpdates'
    
    if ([moviesArray count] > 1) {
        
        if (movie.shortlisted) {    // 1
            NSMutableArray *tempShortlist = [moviesShortlist mutableCopy];
            NSUInteger tempShortlistIndex = [tempShortlist indexOfObject:movie];
            [tempShortlist removeObjectAtIndex:tempShortlistIndex];
            moviesShortlist = [tempShortlist copy];
        }
        
        NSMutableArray *tempArray = [moviesArray mutableCopy];  // 2
        NSUInteger index = [tempArray indexOfObject:movie];     // 3
        [moviesTable beginUpdates];                             // 4
        [tempArray removeObjectAtIndex:index];                  // 5
        [moviesTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:	UITableViewRowAnimationFade];   // 6
        moviesArray = tempArray;                                // 7
        [moviesTable endUpdates];                               // 8
    }
    [self preselectRandomMovie];
}

- (void)addMovieToShortlist:(Movie *)movie
{
    if ([moviesShortlist containsObject:movie]) {
        return;
    }
    
    NSMutableArray *tempArray = [moviesShortlist mutableCopy];
    [tempArray addObject:movie];
    moviesShortlist = [tempArray copy];
    
    [self preselectRandomMovie];
}


- (IBAction)closeSelectedMovieOverlay:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [selectedMovieOverlay setHidden:YES];
        [self preselectRandomMovie];
    }];
}

- (IBAction)startOver:(id)sender
{
    // Call existing method listenForNotifications
    [self listenForNotifications];
    
    [self getRottenTomatoesDATA];
    [moviesTable reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [selectedMovieOverlay setHidden:YES];
        [startOverButton setHidden:YES];
    }];
}


- (IBAction)showMovieDetails:(id)sender {
    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    [selectedMovieOverlay setHidden:YES];
    movieSelectedFromTable = NO;
    [self performSegueWithIdentifier:@"toDetailView" sender:self];
}

- (IBAction)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}


#pragma mark - LISTEN for Notifications
- (void)listenForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMovieGenre:)
                                                 name:GENRE_FOUND_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPosterThumbnail:)
                                                 name:THUMBNAIL_FOUND_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPosterThumbnail:)
                                                 name:POSTER_FOUND_NOTIFICATION
                                               object:nil];
}


#pragma mark - NOTIFICATION Received
- (void)getMovieGenre:(NSNotification *)note
{
    Movie *movie = note.object;
    NSUInteger movieIndex = [moviesArray indexOfObject:movie];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:movieIndex inSection:0];
    
    [moviesTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)getPosterThumbnail:(NSNotification *)note
{
    Movie *movie = note.object;
    NSUInteger movieIndex = [moviesArray indexOfObject:movie];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:movieIndex inSection:0];
    
    [moviesTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - REACHABILITY Methods
- (void)checkForInternet
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            [self showReachabilityAlertView];
            NSLog(@"There's no internet connection at all.");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            break;
            
        default:
            break;
    }
}


- (void)showReachabilityAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!"
                                                        message:@"PikFlick is unable to reach the Internet. Please check your device settings or try later."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
}


@end
