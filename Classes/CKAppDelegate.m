//
//  CKAppDelegate.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKAppDelegate.h"

#import "CKStoriesViewController.h"
#import "CKStory.h"

@implementation CKAppDelegate {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    UIWindow *_window;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ConradWWDC" withExtension:@"momd"];
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    [_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];

    CKStory *headStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    headStory.name = @"Me";
    headStory.color = [UIColor lightGrayColor];
    headStory.imagePath = @"Me.png";
    headStory.storyPath = @"test.md";

    CKStory *mlhStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    mlhStory.name = @"Major League Hacking";
    mlhStory.color = [UIColor whiteColor];
    mlhStory.imagePath = @"MLH.png";
    [headStory linkToNeighbor:mlhStory];

    CKStory *pennAppsStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    pennAppsStory.name = @"PennApps Fall 2013";
    pennAppsStory.color = [UIColor blackColor];
    pennAppsStory.imagePath = @"PennApps.png";
    pennAppsStory.storyPath = @"test.md";
    [mlhStory linkToNeighbor:pennAppsStory];

    CKStory *mhacksStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    mhacksStory.name = @"MHacks III";
    mhacksStory.color = [UIColor colorWithRed:1.0f green:0.78f blue:0.19f alpha:1.0f];
    mhacksStory.imagePath = @"MHacks.png";
    mhacksStory.storyPath = @"test.md";
    [mlhStory linkToNeighbor:mhacksStory];

    CKStory *hacknyStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    hacknyStory.name = @"hackNY Fall 2013";
    hacknyStory.color = [UIColor colorWithRed:0.89f green:0.16f blue:0.18f alpha:1.0f];
    hacknyStory.imagePath = @"hackNY.png";
    hacknyStory.storyPath = @"test.md";
    [mlhStory linkToNeighbor:hacknyStory];

    CKStory *appStoreStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    appStoreStory.name = @"App Store";
    appStoreStory.color = [UIColor blueColor];
    appStoreStory.imagePath = @"AppStore.png";
    [headStory linkToNeighbor:appStoreStory];

    CKStory *deskConnectStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    deskConnectStory.name = @"DeskConnect";
    deskConnectStory.color = [UIColor blueColor];
    deskConnectStory.imagePath = @"DeskConnect.png";
    [appStoreStory linkToNeighbor:deskConnectStory];

    CKStory *workflowStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    workflowStory.name = @"Workflow";
    workflowStory.color = [UIColor blueColor];
    workflowStory.imagePath = @"Workflow.png";
    [appStoreStory linkToNeighbor:workflowStory];
    [mhacksStory linkToNeighbor:workflowStory];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CKStoriesViewController *storiesViewController = [[CKStoriesViewController alloc] init];
    storiesViewController.managedObjectContext = _managedObjectContext;

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = storiesViewController;
    [_window makeKeyAndVisible];

    return YES;
}

@end
