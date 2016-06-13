//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Ernald on 5/16/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ItemsViewController.h"
#import "DetailViewController.h"
#import "ImageStore.h"
#import "ImageViewController.h"
#import "ItemStore.h"
#import "ItemCell.h"
#import "Item.h"

@interface ItemsViewController () <UITableViewDataSource, UIPopoverControllerDelegate, UIDataSourceModelAssociation>
@property (nonatomic, strong) UIPopoverController *imagePopOver;
@end

@implementation ItemsViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = NSLocalizedString(@"Homepwner", @"Name of Application");
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        navItem.rightBarButtonItem = bbi;
        navItem.leftBarButtonItem = self.editButtonItem;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeChanged) name:NSCurrentLocaleDidChangeNotification object:nil];
    }
    
    return self;
}

- (instancetype) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle: UITableViewStylePlain];
    
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc]init];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
    
    self.tableView.restorationIdentifier = @"ItemViewController";
    
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ItemCell"];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    
    [super decodeRestorableStateWithCoder:coder];
}

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    NSString *identifier = nil;
    
    if(idx && view)
    {
        Item* selectedItem = [[ItemStore sharedStore] allItems][idx.row];
        identifier = selectedItem.itemKey;
    }
    
    return identifier;
}

- (void) localeChanged: (NSNotification *) note
{
    [self.tableView reloadData];
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSIndexPath *path = nil;
    
    if(identifier && view)
    {
        NSArray *items = [[ItemStore sharedStore] allItems];
        
        for(Item* item in items)
        {
            if([identifier caseInsensitiveCompare:item.itemKey] == NSOrderedSame)
            {
                NSUInteger row = [[[ItemStore sharedStore] allItems] indexOfObjectIdenticalTo:item];
                path = [NSIndexPath indexPathForRow:row inSection:0];
                break;
            }
        }
    }
    
    return path;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    NSArray *items = [[ItemStore sharedStore] allItems];
    
    Item *item = (Item *)items[indexPath.row];
    cell.nameLabel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;
    
    static NSNumberFormatter *numberFormatter = nil;
    
    if(!numberFormatter)
    {
        numberFormatter =
            [NSNumberFormatter new];
        
        numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    
    NSString *valueText = [numberFormatter stringFromNumber:@(item.valueInDollars)];
    
    cell.valueLabel.text = valueText;
    
    cell.thumbnailView.image = item.thumbnail;
    
    __weak ItemCell *weakCell = cell;
    
    cell.actionBlock = ^() {
        NSLog(@"Going to show image for %@", item);
        
        ItemCell *strongCell = weakCell;
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            NSString *itemKey = item.itemKey;
            
            UIImage *image = [[ImageStore sharedStore] imageForKey:itemKey];
            
            if(!image)
            {
                return;
            }
            
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds toView:strongCell.thumbnailView];
            
            ImageViewController *ivc = [ImageViewController new];
            ivc.image = image;
            
            self.imagePopOver = [[UIPopoverController alloc] initWithContentViewController:ivc];
            
            self.imagePopOver.delegate = self;
            self.imagePopOver.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [[ItemStore sharedStore] allItems][indexPath.row];
    DetailViewController *detailsVC = [[DetailViewController alloc] initForNewItem:NO];
    detailsVC.item = item;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[ItemStore sharedStore] allItems] count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void) updateTableViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;
    
    if(!cellHeightDictionary)
    {
        cellHeightDictionary = @{
                                 UIContentSizeCategoryExtraSmall : @44,
                                 UIContentSizeCategorySmall : @44,
                                 UIContentSizeCategoryMedium : @44,
                                 UIContentSizeCategoryLarge : @44,
                                 UIContentSizeCategoryExtraLarge : @55,
                                 UIContentSizeCategoryExtraExtraLarge : @65,
                                 UIContentSizeCategoryExtraExtraExtraLarge : @75,
                                };
    }
    
    NSString *preferredSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *height = cellHeightDictionary[preferredSize];
    [self.tableView setRowHeight:height.floatValue];
    [self.tableView reloadData];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopOver = nil;
}

- (IBAction) addNewItem:(id) sender
{
    Item *newItem = [[ItemStore sharedStore] createItem];
    
    DetailViewController *itemDetailsVC = [[DetailViewController alloc] initForNewItem:YES];
    
    itemDetailsVC.item = newItem;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemDetailsVC];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    itemDetailsVC.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Item *item = [[ItemStore sharedStore] allItems][indexPath.row];
        [[ItemStore sharedStore] removeItem:item andImage:YES];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[ItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}
@end
