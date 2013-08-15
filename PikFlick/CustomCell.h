//
//  CustomCell.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie;

@interface CustomCell : UITableViewCell <UIGestureRecognizerDelegate>

- (void)loadMovie:(Movie *)movie;


@end
