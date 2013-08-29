//
//  PFKInfoDetailViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/29/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "PFKInfoDetailViewController.h"

@interface PFKInfoDetailViewController ()
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITextView *bioTextField;
    
}
@end

@implementation PFKInfoDetailViewController
@synthesize incomingTitle;

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

    // UI Elements
    titleLabel.text = self.incomingTitle;
    bioTextField.text = self.incomingText;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
