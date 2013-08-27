//
//  UserSettingsViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/26/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "ViewController.h"

@interface UserSettingsViewController () {
    __weak IBOutlet UISegmentedControl *theatreDistanceControl;
    
}

- (IBAction)saveSettings:(id)sender;
- (IBAction)getHelp:(id)sender;
- (IBAction)changeTheatreDistance:(id)sender;


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


- (void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int distance =  [userDefaults integerForKey:@"userDistance"];
    if (distance == 5) {
        theatreDistanceControl.selectedSegmentIndex = 0;
    } else if (distance == 10) {
        theatreDistanceControl.selectedSegmentIndex = 1;
    } else if (distance == 20) {
        theatreDistanceControl.selectedSegmentIndex = 2;
    } else if (distance == 40)
        theatreDistanceControl.selectedSegmentIndex = 3;
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
    ViewController *viewController = [[ViewController alloc] init];
    
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)changeTheatreDistance:(id)sender {
    if (theatreDistanceControl.selectedSegmentIndex == 0) {
        //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"userDistance"];
    } else if (theatreDistanceControl.selectedSegmentIndex == 3) {
        [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"userDistance"];
    }
}
@end
