//
//  Item.m
//  Homepwner
//
//  Created by Ernald on 6/3/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "Item.h"

@implementation Item

// Insert code here to add functionality to your managed object subclass

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.dateCreated = [NSDate date];
    NSUUID *uuid = [NSUUID new];
    NSString *key = [uuid UUIDString];
    self.itemKey = key;
}

- (void)willTurnIntoFault
{
    NSLog(@"Turning into fault!");
}

- (void)didTurnIntoFault
{
    NSLog(@"Turned into fault!");
}


- (void)setThumbnailFromImage:(UIImage *) image
{
    CGSize origImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:0.5];
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    
    self.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
