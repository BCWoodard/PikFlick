//
//  PFKInfoViewController.m
//  PikFlick
//
//  Created by Brad Woodard on 8/29/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "PFKInfoViewController.h"
#import "PFKInfoDetailViewController.h"

@interface PFKInfoViewController ()

@end

@implementation PFKInfoViewController
{
    int                 selectedSection;
    int                 selectedRow;
    __weak IBOutlet UITableView *infoTableView;
}



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
}


- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [infoTableView indexPathForSelectedRow];
    [infoTableView
     deselectRowAtIndexPath:selectedIndexPath animated:NO];

}

#pragma mark - TableViewDataSource
- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 0, 280, 44);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = sectionTitle;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 1;
    label.textAlignment = NSTextAlignmentLeft;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"About PikFlick";
    } else if (section == 1) {
        return @"About the Developers";
    } else {
        return @"Contact the Developers";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
            }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"About the App";
        cell.detailTextLabel.text = @"Why PikFlick?";
        
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Jeremy Herrero";
                cell.detailTextLabel.text = @"Chicago, Illinois";
                break;
                
            case 1:
                cell.textLabel.text = @"Jessica Sturme";
                cell.detailTextLabel.text = @"Taupo, New Zealand";
                break;
                
            case 2:
                cell.textLabel.text = @"Brad Woodard";
                cell.detailTextLabel.text = @"Chicago, Illinois";
                break;
                
            default:
                break;
            }
        
        } else {
            cell.textLabel.text = @"PikFlick@gmail.com";
            cell.detailTextLabel.text = @"Let us know what you think";
    }

    return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == 0) || (section == 2)) {
        return 1;
    } else {
        return 3;
    }
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        selectedRow = 0;
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                selectedRow = 1;
                break;
            case 1:
                selectedRow = 2;
                break;
            case 2:
                selectedRow = 3;
                break;
                
            default:
                break;
        }
    } else {
        selectedRow = 4;
    }
    
    [self performSegueWithIdentifier:@"toInfoDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PFKInfoDetailViewController *detailViewController = segue.destinationViewController;
    
    switch (selectedRow) {
        case 0:
            detailViewController.incomingTitle = @"About the App";
            detailViewController.incomingText = @"Have you ever wanted to see a movie but been overwhelmed by the choices out there? Or have you been with a group of friends and you just can’t decide which movie to see? Maybe getting into a fight during the process?\n\nPikFlick is the answer. PickFlick is a fun, easy way to decide which movie to see. It allows you to filter out which films you definitely DON’T want to see and rate the remaining movies so you can cut through the clutter and make a choice – easily and quickly. No muss. No fuss.";
            break;
        case 1:
            detailViewController.incomingTitle = @"Jeremy Herrero";
            detailViewController.incomingText = @"My passions in life are traveling, teaching, and programming.  I have experienced many things around the world and started life after college as a special eductation teacher.\n\nNow I have entered the life as a software developer and love it.  As I continue to code I will discover how to connect these passions together.\n\n\nLinkedIn: http://www.linkedin.com/in/jerherrero/\n\nGitHub: https://github.com/jerherrero";
            break;
        case 2:
            detailViewController.incomingTitle = @"Jessica Sturme";
            detailViewController.incomingText = @"Jessica is a fledging coder learning iOS development, and comes from a successful entrepreneurial background in business management and development.\n\nFavorite Quote -\n\n\"Five frogs are sitting on a log. Four decide to jump off. How many are left?\nFive, because deciding is different to doing.\"\n\nLinkedIn: http://nz.linkedin.com/in/jessicasturme/";

            break;
        case 3:
            detailViewController.incomingTitle = @"Brad Woodard";
            detailViewController.incomingText = @"Brad is an iOS developer with two apps currently in the App Store - WTTW's \"Chicago's Loop\" (a self-guided walking tour of downtown Chicago) and \"PikFlick\". He consults and develops on a number of other mobile apps.\n\nBrad also has significant experience as a Digital Strategist and provides strategic direction, creative insight and day-to-day management of digital marketing efforts for a variety clients.\n\nLinkedIn: http://www.linkedin.com/in/bradwoodard\nGitHub: https://www.github.com/bcwoodard";
            break;
        case 4:
            detailViewController.incomingTitle = @"Contact Us";
            detailViewController.incomingText = @"We'd love to hear what you think about the app or about other business opportunities. You can reach all of us at: PikFlick@gmail.com";
            
        default:
            break;
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dismiss Modal View
- (IBAction)dismissInfoView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
