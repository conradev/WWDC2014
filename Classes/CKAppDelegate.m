//
//  CKAppDelegate.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

@import CoreData;

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
    headStory.name = @"Conrad Kramer";
    headStory.color = [UIColor colorWithRed:0.0f green:0.67f blue:0.0f alpha:1.0f];
    headStory.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    headStory.imagePath = @"Me.png";
    headStory.storyPath = @"Me.md";

    CKStory *mlhStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    mlhStory.color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    mlhStory.imagePath = @"MLH.png";
    [headStory linkToNeighbor:mlhStory];

    CKStory *pennAppsStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    pennAppsStory.name = @"PennApps Fall 2013";
    pennAppsStory.color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    pennAppsStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    pennAppsStory.imagePath = @"PennApps.png";
    pennAppsStory.storyPath = @"PennApps.md";
    [mlhStory linkToNeighbor:pennAppsStory];

    CKStory *mhacksStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    mhacksStory.name = @"MHacks III";
    mhacksStory.color = [UIColor colorWithRed:1.0f green:0.78f blue:0.19f alpha:1.0f];
    mhacksStory.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    mhacksStory.imagePath = @"MHacks.png";
    mhacksStory.storyPath = @"MHacks.md";
    [mlhStory linkToNeighbor:mhacksStory];

    CKStory *hacknyStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    hacknyStory.name = @"hackNY Fall 2013";
    hacknyStory.color = [UIColor colorWithRed:0.89f green:0.16f blue:0.18f alpha:1.0f];
    hacknyStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    hacknyStory.imagePath = @"hackNY.png";
    hacknyStory.storyPath = @"hackNY.md";
    [mlhStory linkToNeighbor:hacknyStory];

    CKStory *hackmitStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    hackmitStory.name = @"HackMIT Fall 2013";
    hackmitStory.color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    hackmitStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    hackmitStory.imagePath = @"HackMIT.png";
    hackmitStory.storyPath = @"HackMIT.md";
    [mlhStory linkToNeighbor:hackmitStory];

    CKStory *appStoreStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    appStoreStory.color = [UIColor blueColor];
    appStoreStory.imagePath = @"AppStore.png";
    [headStory linkToNeighbor:appStoreStory];

    CKStory *deskConnectStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    deskConnectStory.name = @"DeskConnect";
    deskConnectStory.color = [UIColor colorWithRed:0.0f green:0.2f blue:0.34f alpha:1.0f];
    deskConnectStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    deskConnectStory.imagePath = @"DeskConnect.png";
    deskConnectStory.storyPath = @"DeskConnect.md";
    [appStoreStory linkToNeighbor:deskConnectStory];

    CKStory *workflowStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    workflowStory.name = @"Workflow";
    workflowStory.color = [UIColor colorWithRed:0.412f green:0.580f blue:0.910f alpha:1.0f];
    workflowStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    workflowStory.imagePath = @"Workflow.png";
    workflowStory.storyPath = @"Workflow.md";
    [appStoreStory linkToNeighbor:workflowStory];
    [mhacksStory linkToNeighbor:workflowStory];

    CKStory *airbnbStory = [CKStory insertInManagedObjectContext:_managedObjectContext];
    airbnbStory.name = @"Airbnb";
    airbnbStory.color = [UIColor colorWithRed:0.12f green:0.69f blue:0.98f alpha:1.0f];
    airbnbStory.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    airbnbStory.imagePath = @"Airbnb.png";
    airbnbStory.storyPath = @"Airbnb.md";
    [appStoreStory linkToNeighbor:airbnbStory];

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
