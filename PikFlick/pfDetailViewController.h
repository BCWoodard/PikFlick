//
//  pfDetailViewController.h
//  PikFlick
//
//  Created by Jessica Sturme on 19/08/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Movie.h"
#import "pfDeleteMovieDelegate.h"

@class Movie;

@interface pfDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) Movie *incomingMovie;
@property (strong, nonatomic) Movie *movie;
@property (nonatomic, assign) id<pfDeleteMovieDelegate> delegate;

- (void)loadMovie:(Movie *)movie;

@end
