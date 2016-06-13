//
//  ImagePickerBackgroundView.m
//  Homepwner
//
//  Created by Ernald on 5/26/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ImagePickerBackgroundView.h"

@interface ImagePickerBackgroundView () <UIPopoverBackgroundViewMethods>
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property CGFloat arrowOffset;
@property UIPopoverArrowDirection arrowDirection;
@end

@implementation ImagePickerBackgroundView
{
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        UIImage *popoverBackgroundImage
        = [[UIImage imageNamed:@"Default-568h@2x.png"]
           resizableImageWithCapInsets:UIEdgeInsetsMake(49, 46, 49, 45)];
        
        self.backgroundImageView
        = [[UIImageView alloc] initWithImage:popoverBackgroundImage];

    }
    
    return self;
}

+ (CGFloat)arrowBase
{
    return 100.0;
}

+ (CGFloat)arrowHeight
{
    return 100.0;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)arrowOffset
{
    return _arrowOffset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

- (UIPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
