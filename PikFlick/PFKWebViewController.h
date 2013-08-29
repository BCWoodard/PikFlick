//
//  PFKWebViewController.h
//  PikFlick
//
//  Created by Brad Woodard on 8/28/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFKWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *incomingTheaterURL;

@end
