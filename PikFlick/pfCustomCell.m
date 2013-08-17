//
//  CustomCell.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "pfCustomCell.h"
#import "Movie.h"
#import <QuartzCore/QuartzCore.h>

@interface pfCustomCell ()

@property (weak, nonatomic) IBOutlet UIImageView *cellImage;

@property (strong, nonatomic) IBOutlet UILabel      *cellPeerRating;
@property (strong, nonatomic) IBOutlet UILabel      *cellTitle;
@property (strong, nonatomic) IBOutlet UILabel      *cellMPAA;
@property (strong, nonatomic) IBOutlet UILabel      *cellGenre;

@end

@implementation pfCustomCell
{
    CAGradientLayer             *_gradientLayer;
    CALayer                     *_movieToSeeLayer;
    CGPoint                     _originalCellCenter;
    BOOL                        _deleteCellOnDragRelease;
    BOOL                        _addToMovieQueueOnDragRelease;
    UIGestureRecognizer         *recognizer;
    UILabel                     *deleteMovieLabel;
    UILabel                     *movieToSeeLabel;
    
}
@synthesize delegate;

- (void)loadMovie:(Movie *)movie {
    self.cellImage.image = movie.movieThumbnail;
    self.cellPeerRating.text = movie.moviePeerRating;
    self.cellTitle.textColor = [UIColor whiteColor];
    self.cellTitle.text = movie.movieTitle;
    self.cellMPAA.text = movie.movieMPAA;
    self.cellGenre.text = movie.movieGenre;
    
    // Show the cell as SHORTLISTED or NOT
    if (movie.shortlisted) {
        _movieToSeeLayer.hidden = NO;
    } else {
        _movieToSeeLayer.hidden = YES;
    }
}

const float UI_CUES_MARGIN = 10.0f;
const float UI_CUES_WIDTH = 120.0f;

- (void)awakeFromNib {

    // add a layer that overlays the cell adding a subtle gradient effect
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
                              (id)[[UIColor colorWithWhite:0.8f alpha:0.1f] CGColor],
                              (id)[[UIColor clearColor] CGColor],
                              (id)[[UIColor colorWithWhite:0.2f alpha:1.0f] CGColor]];
    _gradientLayer.locations = @[@0.00f, @0.01f, @0.99f, @1.00f];
    [self.layer insertSublayer:_gradientLayer atIndex:0];

    // Add the DELETE context and SHORTLIST context
    movieToSeeLabel = [self createCueLabel];
    movieToSeeLabel.numberOfLines = 0;
    movieToSeeLabel.text = @"Definite\nMaybe\n\u2713";
    movieToSeeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:movieToSeeLabel];
    deleteMovieLabel = [self createCueLabel];
    deleteMovieLabel.numberOfLines = 0;
    deleteMovieLabel.text = @"No\nWay!\n\u2717";
    deleteMovieLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:deleteMovieLabel];
    
    _movieToSeeLayer = [CALayer layer];
    _movieToSeeLayer.backgroundColor = [[[UIColor alloc] initWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f] CGColor];
    _movieToSeeLayer.hidden = YES;
    [self.layer insertSublayer:_movieToSeeLayer atIndex:0];

    // add a pan recognizer
    recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    
    [self addGestureRecognizer:recognizer];
}


-(void) layoutSubviews {
    [super layoutSubviews];
    // ensure the gradient movieToSee layers occupies the full bounds
    _gradientLayer.frame = self.bounds;
    _movieToSeeLayer.frame = self.bounds;
    
    // Contextual cues
    movieToSeeLabel.frame = CGRectMake(-UI_CUES_WIDTH - UI_CUES_MARGIN, 0,
                                  UI_CUES_WIDTH, self.bounds.size.height);
    deleteMovieLabel.frame = CGRectMake(self.bounds.size.width + UI_CUES_MARGIN, 0,
                                   UI_CUES_WIDTH, self.bounds.size.height);

}

// Create the contextual cues
-(UILabel*) createCueLabel {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.backgroundColor = [UIColor clearColor];
    return label;
}


#pragma mark - Horizontal PAN Gesture Handler
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    
    // Check for horizontal gesture
    // The fabs() function computes the absolute value of a floating-point number x.
    // The fabsf() function is a single-precision version of fabs().
    
    // So, is the movement along the x-axis greater than along the y-axis?
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer
{
    // If a gesture is recognized
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Record the original center point of the cell so we can determine how far
        // a user has slid the cell to the right or left
        _originalCellCenter = self.center;
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // We need to determine if the cell is slid to the right or left
        //
        // 1. Reset the center point of the cell to the new center point
        //    value as the cell is slid right or left.
        // 2. If the x origin is > than the center of the cell, ADD to queue.
        // 3. If x origin is more than half off the view to the left, delete the cell.
        
        CGPoint translation = [panRecognizer translationInView:self];
        self.center = CGPointMake(_originalCellCenter.x + translation.x, _originalCellCenter.y);                                            // 1
        
        _addToMovieQueueOnDragRelease = self.frame.origin.x > self.frame.size.width / 2;    // 2
        _deleteCellOnDragRelease = self.frame.origin.x < -self.frame.size.width / 2;    // 3
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y,
                                          self.bounds.size.width, self.bounds.size.height);
        
        // if the item is not being deleted, snap back to the original location        
        if (!_deleteCellOnDragRelease) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.frame = originalFrame;
            }];
        }
        
        // notify the delegate that this item should be deleted
        if (_deleteCellOnDragRelease) {
            [delegate deleteMovieFromLists:self.movie];

		}

        // If the item is not being added to the shortlist, snap back to the original location
        if (!_addToMovieQueueOnDragRelease) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.frame = originalFrame;
                             }];
        }
        // Add the movie to the shortlist and update the UI state
        if (_addToMovieQueueOnDragRelease) {
            [self.movie setShortlisted:YES];
            [delegate addMovieToShortlist:self.movie];
            _movieToSeeLayer.hidden = NO;
            
        }
    }
}



@end
