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
        _movieThumbnailURL = [[movieDictionary objectForKey:@"posters"] valueForKey:@"detailed"];
        _movieMPAA = [movieDictionary objectForKey:@"mpaa_rating"];
        _movieSynopsis = [movieDictionary objectForKey:@"synopsis"];
        _movieCriticsConsensus = [movieDictionary objectForKey:@"critics_consensus"];
        _movieRunTime = [movieDictionary objectForKey:@"runtime"];
    }
    
    return self;
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
