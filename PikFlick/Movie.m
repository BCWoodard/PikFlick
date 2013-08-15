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
        _moviePeerRating = [[[movieDictionary objectForKey:@"ratings"] valueForKey:@"audience_score"] stringValue];
        _movieThumbnailURL = [[movieDictionary objectForKey:@"posters"] valueForKey:@"profile"];
        _movieMPAA = [movieDictionary objectForKey:@"mpaa_rating"];
    }
    
    return self;
}


- (NSString *)movieGenre
{
    if (_movieGenre) {
        return _movieGenre;
    }
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GenreFound" object:self];
    }];
    
    _movieGenre = @"Loading…";
    return _movieGenre;
}


- (UIImage *)movieThumbnail
{
    if (_movieThumbnail) {
        return _movieThumbnail;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.movieThumbnailURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        _movieThumbnail = [UIImage imageWithData:data];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ThumbnailFound" object:self];
    }];
    
    _movieThumbnail = [UIImage imageNamed:@"icon"];
    return _movieThumbnail;
}


@end
