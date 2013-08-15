//
//  CustomCell.m
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomCell
{
    CAGradientLayer             * _gradientLayer;
    CGPoint                     _originalCellCenter;
    BOOL                        _deleteCellOnDragRelease;
    UIGestureRecognizer *recognizer;
//    UISwipeGestureRecognizer * swiper;
    
    __weak IBOutlet UIImageView *movieThumbnailImage;
    __weak IBOutlet UILabel     *moviePeerRating;
    __weak IBOutlet UILabel     *movieTitleLabel;
    __weak IBOutlet UILabel     *movieGenreLabel;
    __weak IBOutlet UILabel     *movieMPAALabel;

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        // add a layer that overlays the cell adding a subtle gradient effect
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:0.8f alpha:0.2f] CGColor],
                                  (id)[[UIColor colorWithWhite:0.6f alpha:0.1f] CGColor],
                                  (id)[[UIColor clearColor] CGColor],
                                  (id)[[UIColor colorWithWhite:0.4f alpha:1.0f] CGColor]];
        _gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        [self.layer insertSublayer:_gradientLayer atIndex:0];
        
        // add a pan recognizer
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        recognizer.delegate = self;
        
        [self addGestureRecognizer:recognizer];
        
    }
    
    return self;
}


#pragma mark - Assign LABEL Values
- (void)setCellImage:(UIImage *)cellImage
{
    movieThumbnailImage.image = cellImage;
}

- (void)setCellPeerRating:(NSString *)cellPeerRating
{
    moviePeerRating.text = [NSString stringWithFormat:@"Rating: %@", cellPeerRating];
}

- (void)setCellTitle:(NSString *)cellTitle
{
    movieTitleLabel.textColor = [UIColor whiteColor];
    movieTitleLabel.text = cellTitle;
}

- (void)setCellMPAA:(NSString *)cellMPAA
{
    movieMPAALabel.text = cellMPAA;
}

- (void)setCellGenre:(NSString *)cellGenre
{
    movieGenreLabel.text = cellGenre;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    // ensure the gradient layers occupies the full bounds
    _gradientLayer.frame = self.bounds;

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

-(void)handlePan:(UIPanGestureRecognizer *)_recognizer
{
    // If a gesture is recognized
    if (_recognizer.state == UIGestureRecognizerStateBegan) {
        // Record the original center point of the cell
        _originalCellCenter = self.center;
        
        // We need this information in order to determine how far a user
        // has slid the cell to the right or left
    }
    
    if (_recognizer.state == UIGestureRecognizerStateChanged) {
        // "Translate" the center point of the cell
        // In effect, reset the center point of the cell to the new center point
        // value as the cell is slid right or left
        CGPoint translation = [_recognizer translationInView:self];
        self.center = CGPointMake(_originalCellCenter.x + translation.x, _originalCellCenter.y);
        
        // Calculate if the cell has been dragged far enough to initiate a
        // delete / complete
        // Set the BOOL _deleteCellOnDragRelease to YES if the original x value
        // is less than (negative)CustomCell.frame.size.width (i.e. - 320) divided
        // by 2
        _deleteCellOnDragRelease = self.frame.origin.x < -self.frame.size.width / 2;
        
    }
    
    if (_recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y,
                                          self.bounds.size.width, self.bounds.size.height);
        if (!_deleteCellOnDragRelease) {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.frame = originalFrame;
                             }
             ];
        }
    }
}


@end

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
*/
