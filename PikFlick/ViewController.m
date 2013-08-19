//
//  ViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//

#import "ViewController.h"
#import "Movie.h"
#import "pfCustomCell.h"
#import "DetailedShakeView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
{
    NSArray                     *moviesArray;
    NSArray                     *moviesShortlist;
    //    DetailedShakeView           *detailedShakeView;
    __weak IBOutlet UITableView *moviesTable;
    __weak IBOutlet UIView *selectedMovieOverlay;
    __weak IBOutlet UIButton *selectedMovieCloseButton;
    __weak IBOutlet UILabel *selectedMovieTitle;
    __weak IBOutlet UILabel *announcementGreeting;
    __weak IBOutlet UIImageView *selectedMoviePoster;
    
}
- (IBAction)closeSelectedMovieOverlay:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    // Alloc and init moviesToSeeArray
    moviesShortlist = [[NSArray alloc] init];
    
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
    
    [super viewDidLoad];
    
    [self getRottenTomatoesDATA];
    
    // UI Elements
    moviesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    moviesTable.backgroundColor = [UIColor blackColor];
    
    
    
    //  detailedShakeView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedShakeView" owner:nil options:nil] objectAtIndex:0];
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        
        if (([moviesShortlist count] > 1) && (selectedMovieOverlay.isHidden == YES)) {
            Movie *selectedMovie = [moviesShortlist objectAtIndex:arc4random() % [moviesShortlist count]];
            int movieIndex = [moviesShortlist indexOfObject:selectedMovie];
            selectedMovie.shortlisted = NO;
            NSLog(@"Selected Shortlist Movie: %@", selectedMovie.movieTitle);
            
            // Remove that movie from the shortlist array
            NSMutableArray *tempArray = [moviesShortlist mutableCopy];
            [tempArray removeObjectAtIndex:movieIndex];
            moviesShortlist = tempArray;
            
            announcementGreeting.text = [self announcementMessage];
            selectedMoviePoster.image = selectedMovie.movieThumbnail;
            selectedMovieTitle.text = selectedMovie.movieTitle;
            
            [self initialAnimatedOverlay];
            
            [moviesTable reloadData];
            
        } else if (([moviesShortlist count] > 1) && (selectedMovieOverlay.isHidden == NO)) {

                Movie *selectedMovie = [moviesShortlist objectAtIndex:arc4random() % [moviesShortlist count]];
                int movieIndex = [moviesShortlist indexOfObject:selectedMovie];
                selectedMovie.shortlisted = NO;
                NSLog(@"Selected Shortlist Movie: %@", selectedMovie.movieTitle);
                
                // Remove that movie from the shortlist array
                NSMutableArray *tempArray = [moviesShortlist mutableCopy];
                [tempArray removeObjectAtIndex:movieIndex];
                moviesShortlist = tempArray;
                
                selectedMoviePoster.image = selectedMovie.movieThumbnail;
                selectedMovieTitle.text = selectedMovie.movieTitle;

            [self initialAnimatedOverlay];
            
            
            [moviesTable reloadData];
        }
        else if (([moviesShortlist count] == 1) && (selectedMovieOverlay.isHidden == YES)) {
            Movie *selectedMovie = [moviesShortlist objectAtIndex:0];
            
            selectedMoviePoster.image = selectedMovie.movieThumbnail;
            selectedMovieTitle.text = selectedMovie.movieTitle;
            [UIView animateWithDuration:0.3 animations:^{
                selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                [selectedMovieOverlay setHidden:NO];
            }];
            
            selectedMovie.shortlisted = NO;
            NSLog(@"Only shortlist movie remaining is %@", selectedMovie.movieTitle);
            
            // Throw up an alertView or other notification that this is the last movie
            // in their shortlist and prompt for returning to the full list.
            // Maybe we retrieve more movies if this happens?
            
        } else if (([moviesShortlist count] == 1) && (selectedMovieOverlay.isHidden == NO)) {
            [UIView animateWithDuration:0.3 animations:^{
                selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
            } completion:^(BOOL finished) {
                Movie *selectedMovie = [moviesShortlist objectAtIndex:0];
                
                selectedMoviePoster.image = selectedMovie.movieThumbnail;
                selectedMovieTitle.text = selectedMovie.movieTitle;
                [UIView animateWithDuration:0.3 animations:^{
                    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                    [selectedMovieOverlay setHidden:NO];
                }];
                
                selectedMovie.shortlisted = NO;
                NSLog(@"Only shortlist movie remaining is %@", selectedMovie.movieTitle);
            }];
        }
        else if (([moviesShortlist count] == 0) && ([moviesArray count] > 1)) {
            if (selectedMovieOverlay.isHidden == YES) {
                Movie *selectedMovie = [moviesArray objectAtIndex:arc4random() % [moviesArray count]];
                int movieIndex = [moviesArray indexOfObject:selectedMovie];
                NSLog(@"Selected Movie: %@", selectedMovie.movieTitle);
                
                // Remove that movie from the shortlist array
                NSMutableArray *tempArray = [moviesArray mutableCopy];
                [tempArray removeObjectAtIndex:movieIndex];
                moviesArray = tempArray;
                
                selectedMoviePoster.image = selectedMovie.movieThumbnail;
                selectedMovieTitle.text = selectedMovie.movieTitle;
                [UIView animateWithDuration:0.3 animations:^{
                    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                    [selectedMovieOverlay setHidden:NO];
                }];
                
                [moviesTable reloadData];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
                } completion:^(BOOL finished) {
                    Movie *selectedMovie = [moviesArray objectAtIndex:arc4random() % [moviesArray count]];
                    int movieIndex = [moviesArray indexOfObject:selectedMovie];
                    NSLog(@"Selected Movie: %@", selectedMovie.movieTitle);
                    
                    // Remove that movie from the shortlist array
                    NSMutableArray *tempArray = [moviesArray mutableCopy];
                    [tempArray removeObjectAtIndex:movieIndex];
                    moviesArray = tempArray;
                    
                    selectedMoviePoster.image = selectedMovie.movieThumbnail;
                    selectedMovieTitle.text = selectedMovie.movieTitle;
                    [UIView animateWithDuration:0.3 animations:^{
                        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                        [selectedMovieOverlay setHidden:NO];
                    }];
                    
                    [moviesTable reloadData];
                }];
            }
        } else {
            if (selectedMovieOverlay.isHidden == YES) {
                
                Movie *selectedMovie = [moviesArray objectAtIndex:0];
                
                selectedMoviePoster.image = selectedMovie.movieThumbnail;
                selectedMovieTitle.text = selectedMovie.movieTitle;
                [UIView animateWithDuration:0.3 animations:^{
                    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                    [selectedMovieOverlay setHidden:NO];
                }];
                
                NSLog(@"The only remaining movie is %@", selectedMovie.movieTitle);
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
                } completion:^(BOOL finished) {
                    Movie *selectedMovie = [moviesArray objectAtIndex:0];
                    
                    selectedMoviePoster.image = selectedMovie.movieThumbnail;
                    selectedMovieTitle.text = selectedMovie.movieTitle;
                    [UIView animateWithDuration:0.3 animations:^{
                        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
                        [selectedMovieOverlay setHidden:NO];
                    }];
                    
                    NSLog(@"The only remaining movie is %@", selectedMovie.movieTitle);
                }];
            }
        }
    }
}

- (void)initialAnimatedOverlay {
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 100, 100);
        [selectedMovieOverlay setHidden:NO];
    }];
}


- (void)animatedOverlayRemoval {
    [UIView animateWithDuration:0.3 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    }];
    [selectedMovieOverlay setHidden:YES];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


#pragma mark - Get DATA and Utility Methods
- (void)getRottenTomatoesDATA
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=16&page=1&country=us&apikey=xx88qet7sppj6r7jp7wrnznd"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Retrieve all the Rotten Tomatoes movie data
        NSDictionary *rottenTomatoesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Create an array of movie data and 2 temp arrays -
        // One to hold movie objects - tempArray
        // One to hold poster images - tempPostersArray
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
            moviesShortlist = tempShortlist;
            
        }
        
        NSMutableArray *tempArray = [moviesArray mutableCopy];  // 2
        NSUInteger index = [tempArray indexOfObject:movie];     // 3
        [moviesTable beginUpdates];                             // 4
        [tempArray removeObjectAtIndex:index];                  // 5
        [moviesTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];   // 6
        moviesArray = tempArray;                                // 7
        [moviesTable endUpdates];                               // 8
        
    }
}

- (void)addMovieToShortlist:(Movie *)movie
{
    NSMutableArray *tempArray = [moviesShortlist mutableCopy];
    [tempArray addObject:movie];
    moviesShortlist = tempArray;
    NSLog(@"Movies to See: %i", [moviesShortlist count]);
}


- (IBAction)closeSelectedMovieOverlay:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        selectedMovieOverlay.transform = CGAffineTransformScale(selectedMovieOverlay.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [selectedMovieOverlay setHidden:YES];
    }];
}
@end
