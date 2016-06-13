//
//  Item.h
//  Homepwner
//
//  Created by Ernald on 6/3/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void) setThumbnailFromImage:(UIImage * _Nullable) thumbnail;
@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"
