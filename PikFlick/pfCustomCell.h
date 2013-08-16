//
//  CustomCell.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pfDeleteMovieDelegate.h"

@class Movie;

@interface pfCustomCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) Movie *movie;
@property (nonatomic, assign) id<pfDeleteMovieDelegate> delegate;

// This method receives the movie from the array and extracts the
// properties for display in the list
- (void)loadMovie:(Movie *)movie;


@end
