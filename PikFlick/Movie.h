//
//  Movie.h
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/13/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THUMBNAIL_FOUND_NOTIFICATION @"ThumbnailFound"
#define GENRE_FOUND_NOTIFICATION @"GenreFound"
#define POSTER_FOUND_NOTIFICATION @"PosterFound"

@interface Movie : NSObject

@property (strong, nonatomic) NSString  *movieID;
@property (strong, nonatomic) NSString  *movieTitle;
@property (strong, nonatomic) NSString  *movieGenre;
@property (strong, nonatomic) NSString  *moviePeerRating;
@property (strong, nonatomic) NSString  *movieThumbnailURL;
@property (strong, nonatomic) UIImage   *movieThumbnail;
@property (strong, nonatomic) NSString  *moviePosterURL;
@property (strong, nonatomic) UIImage   *moviePoster;
@property (strong, nonatomic) NSString  *movieMPAA;
@property (strong, nonatomic) NSString  *movieTMSID;
@property (strong, nonatomic) NSString  *movieSynopsis;
@property (strong, nonatomic) NSString  *movieCriticsConsensus;
@property (strong, nonatomic) NSString  *movieRunTime;
@property BOOL  shortlisted;

// Overwrite init with a method to create our Movie object directly
// from the Movie Dictionary we retrieve from Rotten Tomatoes
- (instancetype)initWithMovieDictionary:(NSDictionary *)movieDictionary;
- (void)fetchPoster;

@end
