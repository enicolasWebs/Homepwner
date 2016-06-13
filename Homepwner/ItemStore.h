//
//  ItemStore.h
//  Homepwner
//
//  Created by Ernald on 5/16/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface ItemStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allItems;
- (NSArray *) allAssetTypes;

+ (instancetype) sharedStore;
- (Item*) createItem;
- (void) removeItem: (Item *) item andImage: (BOOL) deleteImage;
- (void) addItem: (Item *) item;
- (void) moveItemAtIndex: (NSInteger) prevIndex toIndex: (NSInteger) targetIndex;
- (BOOL) saveChanges;
@end
