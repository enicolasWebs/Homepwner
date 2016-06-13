//
//  ItemCell.m
//  Homepwner
//
//  Created by Ernald on 5/30/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation ItemCell

- (IBAction) showImage:(id) sender
{
    if(self.actionBlock)
    {
        self.actionBlock();
    }
}

- (void) updateInterfaceForDynamicTypeSize
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    
    static NSDictionary *imageSizeDictionary;
    
    if(!imageSizeDictionary)
    {
        imageSizeDictionary = @{
                                UIContentSizeCategoryExtraSmall : @40,
                                UIContentSizeCategorySmall : @40,
                                UIContentSizeCategoryMedium : @40,
                                UIContentSizeCategoryLarge : @40,
                                UIContentSizeCategoryExtraLarge : @45,
                                UIContentSizeCategoryExtraExtraLarge : @55,
                                UIContentSizeCategoryExtraExtraExtraLarge : @65
                                };
    }
    
    NSString *preferedSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *floatSize = imageSizeDictionary[preferedSize];
    _imageViewHeightConstraint.constant = floatSize.floatValue;
}

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.thumbnailView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    [self.thumbnailView addConstraint:constraint];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
