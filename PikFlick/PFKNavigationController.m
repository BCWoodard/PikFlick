//
//  PFKNavigationController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/27/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "PFKNavigationController.h"

@interface PFKNavigationController ()

@end

@implementation PFKNavigationController

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
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"PikFlick-navbar-10"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
