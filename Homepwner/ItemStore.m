//
//  ItemStore.m
//  Homepwner
//
//  Created by Ernald on 5/16/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ItemStore.h"
#import "ImageStore.h"
#import "Item.h"
#import "AppDelegate.h"

@import CoreData;

@interface ItemStore ()

@property (nonatomic) NSMutableArray *privateItems;

@property (nonatomic, strong) NSMutableArray *allAssetTypes;

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation ItemStore

+ (instancetype) sharedStore
{
    static ItemStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype) init
{
    [NSException raise:@"Singleton" format:@"Use +[ItemStore sharedStore]"];
    return nil;
}

- (instancetype) initPrivate
{
    self = [super init];
    
    if(self)
    {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _model];
        
        NSString *path = self.itemArchivePath;
        NSURL *storeUrl = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            @throw [NSException exceptionWithName:@"OpenFailure" reason:[error localizedDescription] userInfo:nil];
        }
        
        _context = [NSManagedObjectContext new];
        _context.persistentStoreCoordinator = psc;
        
        [self loadAllItems];
    }
    
    return self;
}

- (NSArray *) allItems
{
    return [self.privateItems copy];
}

- (void) loadAllItems
{
    if(!self.privateItems)
    {
        NSFetchRequest *request = [NSFetchRequest new];
        
        [request setReturnsObjectsAsFaults:NO];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.context];
        
        request.entity = e;
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        
        request.sortDescriptors = @[sd];
        
        NSError *error;
        
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if(!result)
        {
            [NSException raise:@"Fetch failed" format:@"Reason %@", [error localizedDescription]];
        }
        
        self.privateItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (Item *) createItem
{
    double order;
    
    if([self.privateItems count] == 0)
    {
        order = 0;
    }
    else
    {
        order = [[self.privateItems lastObject] orderingValue] + 1.0;
    }
    
    NSLog(@"Adding after %lu items, order %.2f", (unsigned long)[self.privateItems count], order);
    
    Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.context];
    
    newItem.orderingValue= order;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    newItem.valueInDollars = [defaults integerForKey:NextItemValuePrefsKey];
    newItem.itemName = [defaults objectForKey:NextItemNamePrefsKey];
    
    NSLog(@"%@", [defaults dictionaryRepresentation]);
    
    [self.privateItems addObject:newItem];
    
    return newItem;
}

- (void) removeItem: (Item *) item  andImage:(BOOL) deleteImage
{
    NSString *key = item.itemKey;
    
    if(deleteImage)
    {
        [[ImageStore sharedStore] deleteImageForKey:key];
    }
    
    [self.context deleteObject:item];
    
    [self.privateItems removeObject:item];
}

- (NSArray *)allAssetTypes
{
    if(!_allAssetTypes)
    {
        NSFetchRequest *request = [NSFetchRequest new];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"AssetType" inManagedObjectContext:self.context];
        
        request.entity = e;
        
        NSError *error = nil;
        
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if(!result)
        {
            [NSException raise:@"Fetch Failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        _allAssetTypes = [result mutableCopy];
    }
    
    if([_allAssetTypes count] == 0)
    {
        NSManagedObject *type;
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context];
        
        [type setValue:@"Furniture" forKey:@"label"];
        [_allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context];
        
        [type setValue:@"Jewelry" forKey:@"label"];
        [_allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context];
        
        [type setValue:@"Electronics" forKey:@"label"];
        [_allAssetTypes addObject:type];
    }
    
    return _allAssetTypes;
}

- (void) addItem: (Item *) item
{
    [self.privateItems addObject:item];
    //[self saveChanges];
}

- (void) moveItemAtIndex: (NSInteger) prevIndex toIndex: (NSInteger) targetIndex
{
    if(prevIndex == targetIndex)
    {
        return;
    }
    
    Item* item = self.privateItems[prevIndex];
    [self.privateItems removeObjectAtIndex:prevIndex];
    [self.privateItems insertObject:item atIndex:targetIndex];
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0, upperBound = 0;
    
    if(targetIndex > 0)
    {
        lowerBound = [self.privateItems[targetIndex - 1] orderingValue];
    }
    else
    {
        lowerBound = [self.privateItems[targetIndex + 1] orderingValue] - 2.0;;
    }
    
    if(targetIndex < [self.privateItems count] - 1)
    {
        upperBound = [self.privateItems[targetIndex + 1] orderingValue];
    }
    else
    {
        upperBound = [self.privateItems[targetIndex - 1] orderingValue] + 2.0;
    }
}

- (NSString *) itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (BOOL) saveChanges
{
    NSError *error;
    
    BOOL successful = [self.context save:&error];
    
    if(!successful)
    {
        NSLog(@"Error saving:%@", [error localizedDescription]);
    }
    
    return successful;
}

@end
