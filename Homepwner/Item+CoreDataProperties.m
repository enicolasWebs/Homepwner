//
//  Item+CoreDataProperties.m
//  Homepwner
//
//  Created by Ernald on 6/3/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic itemKey;
@dynamic thumbnail;
@dynamic orderingValue;
@dynamic assetType;

@end
