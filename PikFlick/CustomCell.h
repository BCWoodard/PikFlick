//
//  CustomCell.h
//  PikFlick
//
//  Created by Brad Woodard on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage       *cellImage;
@property (strong, nonatomic) NSString      *cellPeerRating;
@property (strong, nonatomic) NSString      *cellTitle;
@property (strong, nonatomic) NSString      *cellMPAA;
@property (strong, nonatomic) NSString      *cellGenre;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
