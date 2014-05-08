//
//  CKQuadTree.h
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

@import UIKit;

@interface CKQuadTreeNode : NSObject

@property (readonly, nonatomic) CGRect bounds;
@property (readonly, nonatomic, getter = isLeaf) BOOL leaf;
@property (readonly, copy, nonatomic) NSArray *nodes;
@property (strong, nonatomic) NSValue *point;

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey;
- (id)objectForKey:(id)key;

@end

@interface CKQuadTree : NSObject

@property (readonly, nonatomic) CKQuadTreeNode *rootNode;

- (instancetype)initWithPoints:(NSArray *)points;

- (void)visit:(BOOL (^)(CKQuadTreeNode *node))block;

@end
