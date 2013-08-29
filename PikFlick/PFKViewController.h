//
//  ViewController.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pfDeleteMovieDelegate.h"

@interface PFKViewController : UIViewController <PFKDeleteMovieDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *incomingLatForQuery;
@property (strong, nonatomic) NSString *incomingLngForQuery;


@end
