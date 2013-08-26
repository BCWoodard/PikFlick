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
    
    addToShortlistButton.title = @"Add";
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
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
        
        //
        //    CGRect newFrame = cell.textLabel.frame;
        //    newFrame.size.height = [self getLabelHeightForIndex:self.incomingMovie.movieCriticsConsensus];
        //    cell.textLabel.frame = newFrame;
        
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!incomingMovie.movieTMSID) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Showing Near You" message:[NSString stringWithFormat:@"\"%@\" is not showing within %i miles of you", incomingMovie.movieTitle, DISTANCE_FROM_USER] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    
    row = indexPath.row;
    [self performSegueWithIdentifier:@"toMapView" sender:self];
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
        NSLog(@"Row Height: %f", rowHeight);
        
        return rowHeight;
        
    } else if (indexPath.section == 2) {
        
        return 44;
        
    } else {
        float rowHeight = [self getLabelHeightForIndexPath:indexPath andString:self.incomingMovie.movieCriticsConsensus] + 40;
        NSLog(@"Row Height: %f", rowHeight);
        
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
        NSLog(@"labelHeight: %f", labelHeight);
        
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
        NSLog(@"labelHeight: %f", labelHeight);
        
        return labelHeight;
    }
    
    
}


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
        [slComposerSheet setInitialText:[NSString stringWithFormat:@"PickFlick help me choose to see %@.",  incomingMovie.movieTitle]];
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
        [slComposerSheet setInitialText:[NSString stringWithFormat:@"PickFlick help me choose to see %@.",  incomingMovie.movieTitle]];
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
        [composeViewController setBody:[NSString stringWithFormat:@"PickFlick helped me choose to see %@.", incomingMovie.movieTitle]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}


- (void) shareThroughEmail {
    MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
    [mailComposeViewController setMailComposeDelegate:self];
    
    [mailComposeViewController setSubject:[NSString stringWithFormat:@"Going to see %@", incomingMovie.movieTitle]];
    [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"PickFlick helped me choose to see %@.", incomingMovie.movieTitle] isHTML:NO];
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
