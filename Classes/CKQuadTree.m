//
//  CKQuadTree.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKQuadTree.h"

@implementation CKQuadTreeNode {
    CKQuadTreeNode *_topRight;
    CKQuadTreeNode *_topLeft;
    CKQuadTreeNode *_bottomLeft;
    CKQuadTreeNode *_bottomRight;
    NSMutableDictionary *_userInfo;
}

- (instancetype)init {
    self = [self initWithBounds:CGRectNull];
    return self;
}

- (instancetype)initWithBounds:(CGRect)bounds {
    NSParameterAssert(!CGRectIsNull(bounds));
    NSAssert(CGRectGetHeight(bounds) == CGRectGetWidth(bounds), @"The bounds must be square");
    self = [super init];
    if (self) {
        _bounds = bounds;
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    NSString *point = _point ? [NSString stringWithFormat:@", point: %@", NSStringFromCGPoint([_point CGPointValue])] : @"";
    return [NSString stringWithFormat:@"<%@: %p, %@ bounds: %@%@>", NSStringFromClass([self class]), self, _userInfo[@"CKQuadtreeNodeChargeTotal"], NSStringFromCGRect(_bounds), point];
}

- (NSString *)debugDescriptionWithLevel:(NSInteger)level {
    level += 1;
    NSMutableArray *nodes = [@[ [_topRight debugDescriptionWithLevel:level] ?: [NSNull null],
                                [_topLeft debugDescriptionWithLevel:level] ?: [NSNull null],
                                [_bottomLeft debugDescriptionWithLevel:level] ?: [NSNull null],
                                [_bottomRight debugDescriptionWithLevel:level] ?: [NSNull null] ] mutableCopy];
    [nodes removeObject:[NSNull null]];
    NSMutableString *description = [NSMutableString string];
    NSMutableString *separator = [NSMutableString stringWithString:@"\n"];
    for (NSInteger idx = 0; idx < level; idx++)
        [separator appendString:@"  | "];
    for (NSString *node in nodes)
        [description appendFormat:@"%@%@", separator, node];
    return [self.description stringByAppendingString:description];
}

- (NSString *)debugDescription {
    return [self debugDescriptionWithLevel:0];
}

- (NSArray *)nodes {
    NSMutableArray *nodes = [NSMutableArray arrayWithObjects:_topRight, nil];
    if (_topLeft)
        [nodes addObject:_topLeft];
    if (_bottomLeft)
        [nodes addObject:_bottomLeft];
    if (_bottomRight)
        [nodes addObject:_bottomRight];
    return [nodes copy];
}

- (BOOL)isLeaf {
    return !(_topLeft || _topRight || _bottomLeft || _bottomRight);
}

- (CKQuadTreeNode *)nodeForPoint:(CGPoint)point {
    CGRect topRight, topLeft, bottomLeft, bottomRight;
    CGRectDivide(_bounds, &topLeft, &topRight, CGRectGetWidth(_bounds) / 2.0f, CGRectMinXEdge);
    CGRectDivide(topLeft, &topLeft, &bottomLeft, CGRectGetHeight(_bounds) / 2.0f, CGRectMinYEdge);
    CGRectDivide(topRight, &topRight, &bottomRight, CGRectGetHeight(_bounds) / 2.0f, CGRectMinYEdge);

    CKQuadTreeNode *node = nil;
    if (CGRectContainsPoint(topRight, point))
        node = _topRight = _topRight ?: [[CKQuadTreeNode alloc] initWithBounds:topRight];
    else if (CGRectContainsPoint(topLeft, point))
        node = _topLeft = _topLeft ?: [[CKQuadTreeNode alloc] initWithBounds:topLeft];
    else if (CGRectContainsPoint(bottomLeft, point))
        node = _bottomLeft = _bottomLeft ?: [[CKQuadTreeNode alloc] initWithBounds:bottomLeft];
    else if (CGRectContainsPoint(bottomRight, point))
        node = _bottomRight = _bottomRight ?: [[CKQuadTreeNode alloc] initWithBounds:bottomRight];
    return node;
}

- (void)insertPoint:(CGPoint)point {
    NSAssert(CGRectContainsPoint(_bounds, point), @"You can only insert points within the calculated bounds");
    if (_point || !self.leaf) {
        CGPoint localPoint = [_point CGPointValue];
        if (self.leaf && fabs(point.x - localPoint.x) + fabs(point.y - localPoint.y) > 0.01f) {
            [[self nodeForPoint:localPoint] insertPoint:localPoint];
            _point = nil;
        }
        [[self nodeForPoint:point] insertPoint:point];
    } else {
        _point = [NSValue valueWithCGPoint:point];
    }
}

- (void)visit:(BOOL (^)(CKQuadTreeNode *node))block {
    BOOL stop = YES;
    if (block)
        stop = block(self);
    if (stop)
        return;
    for (CKQuadTreeNode *node in self.nodes)
        [node visit:block];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey {
    [_userInfo setObject:object forKey:aKey];
}

- (id)objectForKey:(id)aKey {
    return [_userInfo objectForKey:aKey];
}

@end

@implementation CKQuadTree

- (instancetype)initWithPoints:(NSArray *)points {
    self = [self init];
    if (self) {
        // Calculate the bounds
        CGFloat minX = CGFLOAT_MAX, minY = CGFLOAT_MAX;
        CGFloat maxX = CGFLOAT_MIN, maxY = CGFLOAT_MIN;
        for (NSValue *value in points) {
            CGPoint point = [value CGPointValue];
            if (point.x > maxX)
                maxX = point.x;
            if (point.x < minX)
                minX = point.x;
            if (point.y > maxY)
                maxY = point.y;
            if (point.y < minY)
                minY = point.y;
        }

        // Squarify the bounds
        CGFloat size = ceil(MAX(maxX - minX, maxY - minY) + 1);
        _rootNode = [[CKQuadTreeNode alloc] initWithBounds:CGRectMake(floor(minX), floor(minY), size, size)];

        // Fill the tree
        for (NSValue *value in points)
            [_rootNode insertPoint:[value CGPointValue]];
    }
    return self;
}

- (void)visit:(BOOL (^)(CKQuadTreeNode *node))block {
    [_rootNode visit:block];
}

@end
