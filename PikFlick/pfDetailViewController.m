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
    
}


@end

@implementation pfDetailViewController
@synthesize incomingMovie;

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
    return 3;
}


#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.incomingMovie.movieTitle;
    } else if (section ==1) {
        return nil;
        
    } else  {
        return @"Critics Consensus";
        }
    }

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section ==1) {
        return 2;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section  == 0)
    {
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionZero" forIndexPath:indexPath];
    
    //UILabel* myUILabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 296, 0)];
    
      cell.textLabel.text = @"Section One";
        
        return cell;
        
//        UILabel *mylabel = [[UILabel alloc] initWithFrame:CGRectMake(5,5, 150, 40)];
//        [cell.contentView addSubview:mylabel];
//        
//        //cell.textLabel = myUILabel;
//       // cell.textLabel.text = sampleText;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.textLabel.numberOfLines = 0;
//        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
//        //[myUILabel sizeToFit];
//        
//        CGSize constraintSize = CGSizeMake(255.0f, MAXFLOAT);
//        CGSize labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
       // mylabel = labelSize;
        
        
        
    } else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionOne" forIndexPath:indexPath];
        
        if (indexPath.row == 0){
            cell.textLabel.text = @"Where and When";
        } else {
        cell.textLabel.text = @"Watch the Trailer";
        }
        return  cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionTwo" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Section Three";
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toMapView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toMapView"]) {
        PFMapViewController *mapViewController = segue.destinationViewController;

    }
    
}

//-(CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
//{
//    
//    CGSize size = [sampleText sizeWithFont: [UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(255.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    //        NSLog(@"text: %@, index: %@, size.height: %f, size.width: %f", text2, indexPath, size.height, size.width);
//    
//    if((size.height+30.0f) < 80.0)
//        return 80.0f;
//    else
//        return (size.height + 30.0f);
//}


//tableView:heightForRowAtIndexPath:sizeWithFont:constrainedToSize:

@end
