//
//  ViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//

#import "ViewController.h"
#import "Movie.h"
#import "CustomCell.h"
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
        NSLog(@"Did shake");
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
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];

    // Grab movie object and pass it to the custom cell
    Movie *movie = [moviesArray objectAtIndex:indexPath.row];
    
    [cell loadMovie:movie];
    
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
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=32&page=1&country=us&apikey=xx88qet7sppj6r7jp7wrnznd"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Retrieve all the Rotten Tomatoes movie data
        NSDictionary *rottenTomatoesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Create an array of movie data and 2 temp arrays -
        // One to hold movie objects - tempArray
        // One to hold poster images - tempPostersArray
        NSArray *dataMovieArray = [rottenTomatoesJSON objectForKey:@"movies"];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[dataMovieArray count]];
        // NSMutableArray *tempPostersArray = [NSMutableArray arrayWithCapacity:[dataMovieArray count]];
        
        for (NSDictionary *dictionary in dataMovieArray) {
            // Create a movie using our init override method in Movie.m
            Movie *movie = [[Movie alloc] initWithMovieDictionary:dictionary];
            /*
             NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:movie.movieThumbnailURL]];
             UIImage *moviePosterThumbnail = [UIImage imageWithData:data];
             [tempPostersArray addObject:moviePosterThumbnail];
             */
            [tempArray addObject:movie];
        }
        
        // Populate our NSArrays with temporary mutable arrays
        // Again, we do this to protect our arrays from accidental edits, etc.
        //moviePostersArray = [NSArray arrayWithArray:tempPostersArray];
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

- (UIColor *)colorForIndex:(NSInteger) index
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

@end
