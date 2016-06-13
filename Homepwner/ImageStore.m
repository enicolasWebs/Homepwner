//
//  ImageStore.m
//  Homepwner
//
//  Created by Ernald on 5/19/16.
//  Copyright © 2016 Big Nerd. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation ImageStore

+ (instancetype) sharedStore
{
    static ImageStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[ImageStore sharedStore]"];
    
    return nil;
}

- (instancetype) initPrivate
{
    self = [super init];
    
    if(self)
    {
        self.dictionary = [NSMutableDictionary new];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self
            selector:@selector(clearCache:)
            name:UIApplicationDidReceiveMemoryWarningNotification
            object:nil];
    }
    
    return self;
}

- (void) clearCache: (NSNotification *) n
{
    NSLog(@"flushing %lu images out of the cache", [self.dictionary count]);
    [self.dictionary removeAllObjects];
}

- (void) setImage: (UIImage *) image forKey: (NSString *) key
{
    self.dictionary[key] = image;
    
    NSString *imagePath = [self imagePathForKey:key];
    
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [imageData writeToFile:imagePath atomically:YES];
}

- (UIImage *) imageForKey: (NSString *) key
{
    UIImage * image = self.dictionary[key];
    
    if(!image)
    {
        NSString *imagePath = [self imagePathForKey:key];
        image = [UIImage imageWithContentsOfFile:imagePath];
        
        if(image)
        {
            self.dictionary[key] = image;
        }
        else
        {
            NSLog(@"Error: unable to find %@", imagePath);
        }
    }
    
    return image;
}

- (void) deleteImageForKey: (NSString *) key
{
    [self.dictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey: key];
    
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (NSString *) imagePathForKey: (NSString *) key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void) saveImage: (NSString *) key
{
    NSString *imagePath = [self imagePathForKey:key];
    
    [NSKeyedArchiver archiveRootObject:self.dictionary[key] toFile:imagePath];
}

@end
