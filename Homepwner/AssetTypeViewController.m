//
//  AssetTypeViewController.m
//  Homepwner
//
//  Created by Ernald on 6/3/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "AssetTypeViewController.h"
#import "ItemStore.h"
#import <CoreData/CoreData.h>
#import "Item.h"

@implementation AssetTypeViewController

- (instancetype) init
{
    return [super initWithStyle:UITableViewStylePlain];
}

- (instancetype) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Asset Type", @"AssetTypeViewController title");
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    NSManagedObject *assetType = [[ItemStore sharedStore] allAssetTypes][indexPath.row];
    
    cell.textLabel.text = [assetType valueForKey:@"label"];
    
    if(self.item.assetType == assetType)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ItemStore sharedStore] allAssetTypes] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSManagedObject *assetType = [[ItemStore sharedStore] allAssetTypes][indexPath.row];
    
    self.item.assetType = assetType;
    
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
