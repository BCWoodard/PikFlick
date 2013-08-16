//
//  ViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//

#import "ViewController.h"
#import "Movie.h"
#import "pfCustomCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
{
    NSArray                     *moviesArray;
    NSArray                     *moviePostersArray;
    __weak IBOutlet UITableView *moviesTable;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
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
        
    [super viewDidLoad];
    
    [self getRottenTomatoesDATA];
    
    
    // UI Elements
    moviesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    moviesTable.backgroundColor = [UIColor blackColor];

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSMutableArray *randomizer = [moviesArray mutableCopy];
        
        if ([randomizer count] > 1) {
            [randomizer removeObjectAtIndex:arc4random() % [randomizer count]];
            
            NSLog(@"Randomizer Count: %i", [randomizer count]);
            NSLog(@"%@", randomizer);
            
            moviesArray = randomizer;
            [moviesTable reloadData];
        }
        
            
    }
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}



- (void)getRottenTomatoesDATA
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=8&page=1&country=us&apikey=xx88qet7sppj6r7jp7wrnznd"];
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
            // Create a movie using our init override method in Movie.m
            Movie *movie = [[Movie alloc] initWithMovieDictionary:dictionary];

            [tempArray addObject:movie];
        }
        
        // Populate our NSArrays with temporary mutable arrays
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GenreFound" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ThumbnailFound" object:nil];
}

#pragma mark - DELEGATE IMPLEMENTATION
- (void)movieDeletedFromList:(Movie *)movie
{
    // Use the moviesTable to animate the removal of this row
    // We don't want the app to crash if someone deletes the last item from the
    // array, so add the 'if' conditional
    // 1. Make a mutable copy of moviesArray
    // 2. Get the index of the selected movie
    // 3. In order to make changes to the tableView on the fly, and not crash, we must
    //    call 'beginUpdates' on moviesTable
    // 4. Remove the movie from tempArray
    // 5. Delete the row from the tableView with fade animation
    // 6. Refill moviesArray with our tempArray
    // 7. Must complete the beginUpdates with 'endUpdates'
    
    if ([moviesArray count] > 1) {

        NSMutableArray *tempArray = [moviesArray mutableCopy];  // 1
        NSUInteger index = [tempArray indexOfObject:movie];     // 2
        [moviesTable beginUpdates];                             // 3
        [tempArray removeObjectAtIndex:index];                  // 4
        [moviesTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];   // 5
        moviesArray = tempArray;                                // 6
        [moviesTable endUpdates];                               // 7
    }
}

@end
