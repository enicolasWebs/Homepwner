//
//  DetailViewController.h
//  Homepwner
//
//  Created by Ernald on 5/18/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface DetailViewController : UIViewController<UIViewControllerRestoration>

- (instancetype) initForNewItem: (BOOL) isNewItem;
- (instancetype) initWithItem: (Item *) item;

@property (nonatomic, strong) void (^ dismissBlock) (void);
@property (nonatomic, strong) Item *item;

@end
