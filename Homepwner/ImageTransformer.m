//
//  ImageTransformer.m
//  Homepwner
//
//  Created by Ernald on 6/2/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ImageTransformer.h"

@implementation ImageTransformer

+ (Class) transformedValueClass
{
    return [NSData class];
}

- (id) transformedValue:(id) value
{
    if(!value)
    {
        return nil;
    }
    
    if([value isKindOfClass:[NSData class]])
    {
        return value;
    }
    
    return UIImagePNGRepresentation(value);
}

- (id) reverseTransformedValue:(id) value
{
    return [[UIImage alloc]initWithData:value];
}

@end
