//
//  ImageStore.h
//  Homepwner
//
//  Created by Ernald on 5/19/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageStore : NSObject

+ (instancetype) sharedStore;

- (void) setImage: (UIImage *) image forKey: (NSString *) key;
- (UIImage *) imageForKey: (NSString *) key;
- (void) deleteImageForKey: (NSString *) key;

@end
