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
#import "DetailedShakeView.h"
#import <QuartzCore/QuartzCore.h>

#import "pfDetailViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
{
    NSArray                     *moviesArray;
    NSArray                     *moviesShortlist;
    Movie                       *selectedMovie;
    CLLocationManager           *locationManager;
    NSString                    *startDate;
    
    
    __weak IBOutlet UITableView *moviesTable;
    __weak IBOutlet UIView *selectedMovieOverlay;
    __weak IBOutlet UIButton *selectedMovieCloseButton;
    __weak IBOutlet UIButton *startOverButton;
    __weak IBOutlet UILabel *selectedMovieTitle;
    __weak IBOutlet UILabel *announcementGreeting;
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
    [self getRottenTomatoesDATA];
    [self listenForNotifications];
    
    // UI Elements
    moviesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    moviesTable.backgroundColor = [UIColor blackColor];
    
    
    
    [startOverButton setHidden:YES];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height > 480) {
        moviesTable.frame = CGRectMake(0, 0, 320, 548);
        selectedMovieOverlay.frame = CGRectMake(0, 0, 320, 548);
    } else {
        moviesTable.frame = CGRectMake(0, 0, 320, 460);
        selectedMovieOverlay.frame = CGRectMake(0, 0, 320, 480);
    }
    
    selectedMoviePoster.layer.shadowColor = [UIColor whiteColor].CGColor;
    selectedMoviePoster.layer.shadowOpacity = 1;
    selectedMoviePoster.layer.shadowRadius = 15;
    
    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    [selectedMovieOverlay setHidden:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    incomingLatForQuery = [(AppDelegate *)[[UIApplication sharedApplication] delegate] latForQuery];
    incomingLngForQuery = [(AppDelegate *)[[UIApplication sharedApplication] delegate] lngForQuery];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getTMSTheaterData];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        
        if (([moviesShortlist count] > 0) && (selectedMovieOverlay.isHidden == YES)) {
            selectedMovie = [moviesShortlist objectAtIndex:arc4random() % [moviesShortlist count]];
            int movieIndex = [moviesShortlist indexOfObject:selectedMovie];
            selectedMovie.shortlisted = NO;
            NSLog(@"Selected Shortlist Movie: %@", selectedMovie.movieTitle);
            
            NSLog(@"movies array%@", moviesArray);
            NSLog(@"shortlist array%@", moviesShortlist);
            
            // Remove that movie from the shortlist array
            NSMutableArray *tempArray = [moviesShortlist mutableCopy];
            NSObject *removeObject = [tempArray objectAtIndex:movieIndex];
            [tempArray removeObjectAtIndex:movieIndex];
            moviesShortlist = tempArray;
            NSMutableArray *tempMovieArray = [moviesArray mutableCopy];
            [tempMovieArray removeObject:removeObject];
            moviesArray = tempMovieArray;
            
            [self initialAnimatedOverlay];
            [moviesTable reloadData];
            
        } else if (([moviesShortlist count] > 0) && (selectedMovieOverlay.isHidden == NO)) {
            
            selectedMovie = [moviesShortlist objectAtIndex:arc4random() % [moviesShortlist count]];
            int movieIndex = [moviesShortlist indexOfObject:selectedMovie];
            selectedMovie.shortlisted = NO;
            NSLog(@"Selected Shortlist Movie: %@", selectedMovie.movieTitle);
            
            // Remove that movie from the shortlist array
            NSMutableArray *tempArray = [moviesShortlist mutableCopy];
            NSObject *removeObject = [tempArray objectAtIndex:movieIndex];
            [tempArray removeObjectAtIndex:movieIndex];
            moviesShortlist = tempArray;
            NSMutableArray *tempMovieArray = [moviesArray mutableCopy];
            [tempMovieArray removeObject:removeObject];
            moviesArray = tempMovieArray;
            
            
            [self animatedOverlayRemoval];
            
            [moviesTable reloadData];
        }
        /*        else if (([moviesShortlist count] == 1) && (selectedMovieOverlay.isHidden == YES)) {
         selectedMovie = [moviesShortlist objectAtIndex:0];
         
         [self initialAnimatedOverlay];
         
         selectedMovie.shortlisted = NO;
         NSLog(@"Only shortlist movie remaining is %@", selectedMovie.movieTitle);
         
         // Throw up an alertView or other notification that this is the last movie
         // in their shortlist and prompt for returning to the full list.
         // Maybe we retrieve more movies if this happens?
         
         } else if (([moviesShortlist count] == 1) && (selectedMovieOverlay.isHidden == NO)) {
         
         selectedMovie = [moviesShortlist objectAtIndex:0];
         [self animatedOverlayRemoval];
         selectedMovie.shortlisted = NO;
         
         NSLog(@"Only shortlist movie remaining is %@", selectedMovie.movieTitle);
         
         } */
        else if (([moviesShortlist count] == 0) && ([moviesArray count] > 1)) {
            if (selectedMovieOverlay.isHidden == YES) {
                selectedMovie = [moviesArray objectAtIndex:arc4random() % [moviesArray count]];
                int movieIndex = [moviesArray indexOfObject:selectedMovie];
                NSLog(@"Selected Movie: %@", selectedMovie.movieTitle);
                
                // Remove that movie from the shortlist array
                NSMutableArray *tempArray = [moviesArray mutableCopy];
                [tempArray removeObjectAtIndex:movieIndex];
                moviesArray = tempArray;
                
                [self initialAnimatedOverlay];
                [moviesTable reloadData];
            } else {
                
                selectedMovie = [moviesArray objectAtIndex:arc4random() % [moviesArray count]];
                int movieIndex = [moviesArray indexOfObject:selectedMovie];
                NSLog(@"Selected Movie: %@", selectedMovie.movieTitle);
                
                // Remove that movie from the shortlist array
                NSMutableArray *tempArray = [moviesArray mutableCopy];
                [tempArray removeObjectAtIndex:movieIndex];
                moviesArray = tempArray;
                
                [self animatedOverlayRemoval];
                [moviesTable reloadData];
            }
        } else {
            if (selectedMovieOverlay.isHidden == YES) {
                
                selectedMovie = [moviesArray objectAtIndex:0];
                
                [startOverButton setHidden:NO];
                
                [self initialAnimatedOverlay];
                
                NSLog(@"The only remaining movie is %@", selectedMovie.movieTitle);
            } else {
                selectedMovie = [moviesArray objectAtIndex:0];
                
                [startOverButton setHidden:NO];
                
                [self animatedOverlayRemoval];
                
                NSLog(@"The only remaining movie is %@", selectedMovie.movieTitle);
            }
        }
    }
}

- (void)initialAnimatedOverlay {
    announcementGreeting.text = [self announcementMessage];
    selectedMoviePoster.image = selectedMovie.movieThumbnail;
    selectedMovieTitle.text = selectedMovie.movieTitle;
    
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
        [selectedMovieOverlay setHidden:NO];
    }];
}


- (void)animatedOverlayRemoval {
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [self initialAnimatedOverlay];
    }];
}


- (NSString *)announcementMessage {
    NSArray *announcementMessages = [[NSArray alloc] initWithObjects:@"It is decidedly so", @"It is certain", @"You will see", @"We have decided", @"Without a doubt", @"Take it or leave it", @"Most likely", @"Signs point to", @"Tonight you will see", @"Your fate is", @"Your key to success", @"", nil];
    int index = arc4random() % announcementMessages.count;
    return [announcementMessages objectAtIndex:index];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailView" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDetailView"]) {
        pfDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.incomingMovie = [moviesArray objectAtIndex:[moviesTable indexPathForSelectedRow].row];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


#pragma mark - Get DATA
- (void)getRottenTomatoesDATA
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=16&page=1&country=us&apikey=%@", ROTTEN_TOMATOES_API_KEY]];
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
        
        // Stop NetworkActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [moviesTable reloadData];
    }];
}


- (void)getTMSTheaterData
{
    // Activate the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Generate NSURL and perform TMS query
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.tmsapi.com/v1/theatres?lat=41.9&lng=-87.62&radius=10&units=mi&api_key=%@", TMS_API_KEY]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Retrieve theater data array from TMS
        NSArray *tmsTheatersArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray *tempTheaters = [[NSMutableArray alloc] initWithCapacity:15];

        for (NSDictionary *dictionary in tmsTheatersArray) {
            Theater *theater = [[Theater alloc] initWithTheaterDictionary:dictionary];
            [tempTheaters addObject:theater];
            NSLog(@"Theater Name: %@\nLat: %@", [theater valueForKey:@"title"], [theater valueForKey:@"theaterLatitude"]);
        }
                
        // stop the activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GenreFound" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ThumbnailFound" object:nil];
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
}

- (void)addMovieToShortlist:(Movie *)movie
{
    if ([moviesShortlist containsObject:movie]) {
        return;
    }
    
    NSMutableArray *tempArray = [moviesShortlist mutableCopy];
    [tempArray addObject:movie];
    moviesShortlist = [tempArray copy];
    NSLog(@"Movies to See: %i", [moviesShortlist count]);
}


- (IBAction)closeSelectedMovieOverlay:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [selectedMovieOverlay setHidden:YES];
    }];
}

- (IBAction)startOver:(id)sender {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getMovieGenre:)
     name:@"GenreFound"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getPosterThumbnail:)
     name:@"ThumbnailFound"
     object:nil];
    [self getRottenTomatoesDATA];
    [moviesTable reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [selectedMovieOverlay setHidden:YES];
        [startOverButton setHidden:YES];
    }];
}


#pragma mark - LISTEN for Notifications
- (void)listenForNotifications
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getMovieGenre:)
     name:@"GenreFound"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getPosterThumbnail:)
     name:@"ThumbnailFound"
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


@end


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
 
 
 
 // #1. Get todays date for TMS query
 - (NSString *)getTodaysDate
 {
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setDateFormat:@"yyyy-MM-dd"];
 startDate = [dateFormatter stringFromDate:[NSDate date]];

 return startDate;
 }
 
 */
