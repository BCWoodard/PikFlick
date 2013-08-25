//
//  pfDetailViewController.m
//  PikFlick
//
//  Created by Jessica Sturme on 19/08/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "pfDetailViewController.h"
#import "ViewController.h"
#import "PFMapViewController.h"

@interface pfDetailViewController ()
{
    __weak IBOutlet UITableView *myDetailTableView;
    int row;
    
}


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


@end
