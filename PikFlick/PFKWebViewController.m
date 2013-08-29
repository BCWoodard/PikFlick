//
//  PFKWebViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/28/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "PFKWebViewController.h"

@interface PFKWebViewController ()
{
    __weak IBOutlet UIWebView *webView;
}

@end

@implementation PFKWebViewController
@synthesize incomingTheaterURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView.delegate = self;
    
    if (!incomingTheaterURL) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:incomingTheaterURL];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestURL];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
