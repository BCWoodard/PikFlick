//
//  HomeViewController.m
//  PikFlick
//
//  Created by Jeremy Herrero on 8/22/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () {
    
    __weak IBOutlet UITextField *cityTextField;
    __weak IBOutlet UITextField *stateTextField;
    __weak IBOutlet UITextField *zipTextField;
    __weak IBOutlet UITextField *useMapsAutoCompleteSearch;
}
- (IBAction)findCurrentLocation:(id)sender;
- (IBAction)enterCurrentLocation:(id)sender;
- (IBAction)submitCustomLocation:(id)sender;

@end

@implementation HomeViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *viewController = segue.destinationViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findCurrentLocation:(id)sender {
    [self performSegueWithIdentifier:@"Use Current Location" sender:self];
}

- (IBAction)enterCurrentLocation:(id)sender {
}

- (IBAction)submitCustomLocation:(id)sender {
}
@end
