//
//  Movie.m
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/13/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithMovieDictionary:(NSDictionary *)movieDictionary
{
    self = [super init];
    
    if (self) {
        _movieID = [movieDictionary valueForKey:@"id"];
        _movieTitle = [movieDictionary valueForKey:@"title"];
        _moviePeerRating = [[movieDictionary valueForKeyPath:@"ratings.audience_score"] stringValue];
        _movieThumbnailURL = [movieDictionary valueForKeyPath:@"posters.thumbnail"];
        _moviePosterURL = [movieDictionary valueForKeyPath:@"posters.detailed"];
        _movieMPAA = [movieDictionary objectForKey:@"mpaa_rating"];
        _movieSynopsis = [movieDictionary objectForKey:@"synopsis"];
        _movieCriticsConsensus = [movieDictionary objectForKey:@"critics_consensus"];
        _movieRunTime = [movieDictionary objectForKey:@"runtime"];

        [self fetchGenre];
        [self fetchThumbnail];
    }
    
    return self;
}

- (void)fetchGenre
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/movies/%@.json?apikey=xx88qet7sppj6r7jp7wrnznd", self.movieID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // Access the movie info dictionary on Rotten Tomatoes and set the
        // movie genre to the first element in the "genres" array
        NSDictionary *movieInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *movieGenresArray = [movieInfoDictionary objectForKey:@"genres"];
        _movieGenre = [movieGenresArray objectAtIndex:0];
        
        // Stop the Network Activity Indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:GENRE_FOUND_NOTIFICATION object:self];
    }];
}


- (void)fetchThumbnail
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.movieThumbnailURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        _movieThumbnail = [UIImage imageWithData:data];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:THUMBNAIL_FOUND_NOTIFICATION object:self];
    }];
    
    _movieGenre = @"Loading…";

}


- (void)fetchPoster
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.moviePosterURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        _moviePoster = [UIImage imageWithData:data];
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:POSTER_FOUND_NOTIFICATION object:self];
    }];
}

- (UIImage *)movieThumbnail
{
    if (_movieThumbnail) {
        return _movieThumbnail;
    }
    _movieThumbnail = [Movie placeholderImage];
    return _movieThumbnail;
}

- (UIImage *)moviePoster
{
    if (_moviePoster) {
        return _moviePoster;
    }
    _moviePoster = [Movie placeholderImage];
    return _moviePoster;
}

+ (UIImage *)placeholderImage
{
    return [UIImage imageNamed:@"icon"];
}

@end
