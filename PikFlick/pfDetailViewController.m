//
//  pfDetailViewController.m
//  PikFlick
//
//  Created by Jessica Sturme on 19/08/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "pfDetailViewController.h"
#import "ViewController.h"
#import "PFMapViewController.h"
#import "Theater.h"

@interface pfDetailViewController ()
{
    UIActionSheet *shareActionSheet;
    UIActionSheet *contactUsActionSheet;
    __weak IBOutlet UITableView *myDetailTableView;
    __weak IBOutlet UIBarButtonItem *addToShortlistButton;
    __weak IBOutlet UIBarButtonItem *removeMovieButton;
    __weak IBOutlet UIBarButtonItem *shareMovieButton;
    __weak IBOutlet UIBarButtonItem *contactUsButton;
    int row;
}
- (IBAction)addToShortlist:(id)sender;
- (IBAction)removeMovie:(id)sender;
- (IBAction)shareMovie:(id)sender;
- (IBAction)contactUs:(id)sender;

@end

@implementation pfDetailViewController
@synthesize incomingMovie;
@synthesize incomingTheaters;

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
    
    addToShortlistButton.image = [UIImage imageNamed:@"buttonAdd"];
    removeMovieButton.title = @"Remove";
    shareMovieButton.title = @"Share";
    contactUsButton.title = @"Contact";
    
    shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Tell Your Friends!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Tweet", @"Text", @"Email", nil];
    
    contactUsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Send us an email." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Contact Us", nil];
    
    NSLog(@"TMSID: %@", incomingMovie.movieTMSID);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}


#pragma mark - UITableViewDataSource

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
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return self.incomingMovie.movieTitle;
        
    } else if (section ==3) {
        return @"Critics Consensus";
    } else {
        return nil;
    }
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section ==0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionZero" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"icon"];
        cell.imageView.frame = CGRectMake(0.0, 5.0f, 80.0, 80.0);
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        
        cell.textLabel.font = [UIFont fontWithName:@"Gill Sans" size:14.2f];
        
        cell.imageView.image = incomingMovie.movieThumbnail;
        cell.textLabel.text = [NSString stringWithFormat:@"Rated:  %@\nGenre:  %@\nPeer Rating:  %@\nMovie Length:  %@min", incomingMovie.movieMPAA, incomingMovie.movieGenre, incomingMovie.moviePeerRating, incomingMovie.movieRunTime];
        
    }
    else if (indexPath.section ==1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionOne" forIndexPath:indexPath];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.incomingMovie.movieSynopsis;
        
        //adjust the label to the new height.
        CGRect newFrame = cell.textLabel.frame;
        newFrame.size.height = [self getLabelHeightForIndexPath:indexPath andString:self.incomingMovie.movieSynopsis];
        cell.textLabel.frame = newFrame;
        cell.textLabel.font = [UIFont fontWithName:@"Gill Sans" size:14.2f];
        
    }
    else if (indexPath.section == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionTwo" forIndexPath:indexPath];
        
        if (indexPath.row == 1){
            cell.textLabel.text = @"Where and When";
        } else {
            cell.textLabel.text = @"Watch the Trailer";
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionThree" forIndexPath:indexPath];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.incomingMovie.movieCriticsConsensus;
        
        //adjust the label to the new height.
        CGRect newFrame = cell.textLabel.frame;
        newFrame.size.height = [self getLabelHeightForIndexPath:indexPath andString:self.incomingMovie.movieCriticsConsensus];
        cell.textLabel.frame = newFrame;
        cell.textLabel.font = [UIFont fontWithName:@"Gill Sans" size:14.2f];
        
        
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    row = indexPath.row;
    
    if ((indexPath.section == 2) && (indexPath.row == 0)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/v/oHg5SJYRHA0&f=gdata_videos&c=ytapi-my-clientID&d=AIzaSyDGU2EpXmKtonq8qc-P6Objjay0FdUsusw"]];
    } else if ((indexPath.section == 2) && (indexPath.row == 1)) {
        
        if (incomingMovie.movieTMSID == nil) {
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"] != 40) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Theaters Found" message:[NSString stringWithFormat:@"No showtimes within %i miles of your location.  You can increase distance under settings.", [[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"]] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"userDistance"] == 40) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Theaters Found" message:@"Sorry, there are no showtimes in your area." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else if (incomingMovie.movieTMSID != nil) {
            [self performSegueWithIdentifier:@"toMapView" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toMapView"]) {
        PFMapViewController *mapViewController = segue.destinationViewController;
        mapViewController.incomingTheaters = incomingTheaters;
        mapViewController.incomingTMSID = incomingMovie.movieTMSID;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        float rowHeight = [self getLabelHeightForIndexPath:indexPath andString:self.incomingMovie.movieSynopsis] + 40;
        
        return rowHeight;
        
    } else if (indexPath.section == 2) {
        
        return 44;
        
    } else {
        float rowHeight = [self getLabelHeightForIndexPath:indexPath andString:self.incomingMovie.movieCriticsConsensus] + 40;
        
        return rowHeight;
        
    }
}


-(CGFloat)getLabelHeightForIndexPath:(NSIndexPath*)indexPath andString:(NSString *)string
{
    if (indexPath.section == 1) {
        //passing a string from heightForRowAtIndexPath
        CGSize labelSize = [string sizeWithFont:[UIFont fontWithName:@"Gill Sans" size:14.2f]
                              constrainedToSize:CGSizeMake(300, 2000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat labelHeight = labelSize.height;        
        return labelHeight;
        
    }
    else if (indexPath.section == 2) {
        return 44;
        
    }
    
    else {
        CGSize labelSize = [string sizeWithFont:[UIFont fontWithName:@"Gill Sans" size:14.2f]
                              constrainedToSize:CGSizeMake(300, 2000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat labelHeight = labelSize.height;
        
        return labelHeight;
    }
    
    
}

#pragma mark - Toolbar and actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == shareActionSheet) {
        if (buttonIndex == 0) {
            [self postToFacebook];
        }
        if (buttonIndex ==  1) {
            [self postOnTwitter];
        }
        if (buttonIndex == 2) {
            [self shareThroughText];
        }
        if (buttonIndex == 3) {
            [self shareThroughEmail];
        }
    } else if (actionSheet == contactUsActionSheet) {
        if (buttonIndex == 0) {
            MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
            [mailComposeViewController setMailComposeDelegate:self];
            
            [mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"developer@developer.com"]];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    }
}


- (void) postToFacebook {
    SLComposeViewController *slComposerSheet;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        slComposerSheet = [SLComposeViewController new];
        slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [slComposerSheet addImage:incomingMovie.movieThumbnail];
        [slComposerSheet setInitialText:[NSString stringWithFormat:@"PikFlick chose \"%@\" for me.",  incomingMovie.movieTitle]];
        [self presentViewController:slComposerSheet animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Account Unavailable" message:@"Please add a Facebook account under Settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


- (void) postOnTwitter {
    SLComposeViewController *slComposerSheet;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        slComposerSheet = [SLComposeViewController new];
        slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [slComposerSheet addImage:incomingMovie.movieThumbnail];
        [slComposerSheet setInitialText:[NSString stringWithFormat:@"PikFlick chose \"%@\" for me.",  incomingMovie.movieTitle]];
        [self presentViewController:slComposerSheet animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Account Unavailable" message:@"Please add a Twitter account under Settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}


- (void) shareThroughText {
    MFMessageComposeViewController *composeViewController = [MFMessageComposeViewController new];
    [composeViewController setMessageComposeDelegate:self];
    
    if ([MFMessageComposeViewController canSendText]) {
        [composeViewController setBody:[NSString stringWithFormat:@"PikFlick chose \"%@\" for me.", incomingMovie.movieTitle]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}


- (void) shareThroughEmail {
    MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
    [mailComposeViewController setMailComposeDelegate:self];
    
    [mailComposeViewController setSubject:[NSString stringWithFormat:@"PikFlick chose \"%@\" for me.", incomingMovie.movieTitle]];
    [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"PikFlick helped me choose to see %@.", incomingMovie.movieTitle] isHTML:NO];
    [self presentViewController:mailComposeViewController animated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)addToShortlist:(id)sender {
}

- (IBAction)removeMovie:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareMovie:(id)sender {
    [shareActionSheet showInView:self.view];
}

- (IBAction)contactUs:(id)sender {
    [contactUsActionSheet showInView:self.view];
}
@end
