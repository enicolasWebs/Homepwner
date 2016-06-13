//
//  DetailViewController.m
//  Homepwner
//
//  Created by Ernald on 5/18/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "DetailViewController.h"
#import "AssetTypeViewController.h"
#import "ItemStore.h"
#import "ImageStore.h"
#import "ImagePickerBackgroundView.h"
#import "AppDelegate.h"

@interface DetailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;
@property (weak, nonatomic) IBOutlet UILabel *currencySymbol;
@end

@implementation DetailViewController

- (instancetype)init
{
    return [self initWithItem:nil];
}

- (instancetype) initWithItem: (Item *) item
{
    self = [super init];
    
    if(self)
    {
        self.item = item;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    return self;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [NSException raise:@"Wrong initializer" format:@"Use initForNewItem:"];
    return nil;
}

- (instancetype) initForNewItem: (BOOL) isNewItem
{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self)
    {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        if(isNewItem)
        {
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            
            self.navigationItem.rightBarButtonItem = doneButton;
            
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            
            self.navigationItem.leftBarButtonItem = cancelButton;
        }
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) cancel: (id) sender
{
    [[ItemStore sharedStore] removeItem:self.item andImage:YES];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void) save: (id) sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    BOOL isNew = NO;
    
    if([identifierComponents count] == 3)
    {
        isNew = YES;
    }
    
    return [[self alloc] initForNewItem:isNew];
}

- (void) updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nameLabel.font = font;
    self.valueLabel.font = font;
    self.serialNumberLabel.font = font;
    self.dateLabel.font = font;
    
    self.nameField.font = font;
    self.valueField.font = font;
    self.serialNumberField.font = font;
    self.currencySymbol.font = font;
}

- (void)viewDidLoad
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:imageView];
    
    self.imageView = imageView;
    
    NSDictionary<NSString*, UIView*> *nameMap =
        @{@"dateLabel" : self.dateLabel,
          @"imageView" : self.imageView,
          @"toolbar" : self.toolbar};
    
    NSArray *imageViewHorizontalContraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-|" options:0 metrics:nil views:nameMap];

     NSArray *imageViewVerticalContraints =
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-8-[imageView]-8-[toolbar]" options:0 metrics:nil views:nameMap];
    
    [self.view addConstraints:imageViewHorizontalContraints];
    
    [self.view addConstraints:imageViewVerticalContraints];
    
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
    
    static NSNumberFormatter *numberFormatter = nil;
    
    if(!numberFormatter)
    {
        numberFormatter = [NSNumberFormatter new];
    }
    
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    
    self.currencySymbol.text = [NSString stringWithFormat:@"(%@)", [numberFormatter currencySymbol]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    self.navigationItem.title = self.item.itemName;
    
    self.nameField.text = self.item.itemName;
    self.serialNumberField.text = self.item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", self.item.valueInDollars];
    
    self.imageView.image = [[ImageStore sharedStore] imageForKey:self.item.itemKey];
    
    static NSDateFormatter *dateFormatter;
    
    if(!dateFormatter)
    {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate: self.item.dateCreated];
    
    NSString *typeLabel = [self.item.assetType valueForKey:@"label"];
    
    if(!typeLabel)
    {
        typeLabel = NSLocalizedString(@"None", @"Type label none");
    }
    
    self.assetTypeButton.title = ([NSString stringWithFormat:NSLocalizedString(@"Type: %@",  @"Asset type button"), typeLabel]);
    
    [self updateFonts];
}

- (IBAction) showAssetTypePicker:(id) sender
{
    [self.view endEditing:YES];
    
    AssetTypeViewController *assetTypeVC =
    [AssetTypeViewController new];
    
    assetTypeVC.item = self.item;
    
    [self.navigationController pushViewController:assetTypeVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    NSUInteger oldIndx = [[[ItemStore sharedStore] allItems] indexOfObject:_item];
    
    int newValue = [self.valueField.text intValue];
    
    if(newValue != self.item.valueInDollars)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:newValue forKey:NextItemValuePrefsKey];
    }
    
    if(oldIndx != NSNotFound)
    {
        _item.itemName = _nameField.text;
        _item.serialNumber = _serialNumberField.text;
        _item.valueInDollars = [_valueField.text intValue];
    }
}

- (void) prepareViewsForOrientation: (UIInterfaceOrientation) orientation
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        return;
    }
    
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    }
    else
    {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         
         [self prepareViewsForOrientation:orientation];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     { }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void) finishedTyping
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePickerVC.cameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, imagePickerVC.view.frame.origin.y + (imagePickerVC.view.frame.size.height / 2.0), self.view.bounds.size.width, 1)];
        imagePickerVC.cameraOverlayView.backgroundColor = [UIColor orangeColor];
        
        imagePickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // Place image picker on the screen
    // Check for iPad device before instantiating the popover controller
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        // Create a new popover controller that will display the imagePicker
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePickerVC];
        self.imagePickerPopover.delegate = self;
        self.imagePickerPopover.popoverBackgroundViewClass = [ImagePickerBackgroundView class];
        
        // Display the popover controller; sender
        // is the camera bar button item
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    self.imagePickerPopover = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
    
    [[ImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    
    [self.item setThumbnailFromImage: image];
    
    if(self.imagePickerPopover)
    {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"];
    
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    // Commit changes from cache to DB
    [[ItemStore sharedStore] saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    
    NSArray *items = [[ItemStore sharedStore] allItems];
    
    for(Item *curItem in items)
    {
        if([itemKey caseInsensitiveCompare:curItem.itemKey] == NSOrderedSame)
        {
            self.item = curItem;
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

@end
