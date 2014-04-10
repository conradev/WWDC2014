//
//  CKStory.h
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/9/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface CKStory : NSManagedObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *storyPath;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSSet *neighbors;

+ (NSString *)entityName;
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)context;

- (void)linkToNeighbor:(CKStory *)story;
- (void)unlinkFromNeighbor:(CKStory *)story;

@end
