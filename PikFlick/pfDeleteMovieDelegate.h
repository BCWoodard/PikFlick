//
//  pkDeleteMovieDelegate.h
//  PikFlick
//
//  Created by Brad Woodard on 8/15/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

/*
    pfDeleteMovieDelegate is used by CustomCell to inform
    the app of state change.
*/

@protocol pfDeleteMovieDelegate <NSObject>

- (void)movieDeletedFromList:(Movie *)movie;

@end
