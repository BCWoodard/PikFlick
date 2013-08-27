//
//  UserSettingsViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/26/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "UserSettingsViewController.h"

@interface UserSettingsViewController ()

- (IBAction)saveSettings:(id)sender;
- (IBAction)getHelp:(id)sender;


@end

@implementation UserSettingsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)getHelp:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
@end
