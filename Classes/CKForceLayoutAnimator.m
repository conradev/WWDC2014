//
//  CKForceLayoutAnimator.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKForceLayoutAnimator.h"

#import "CKQuadTree.h"

static NSString * const CKQuadtreeNodeChargeTotal = @"charge";
static NSString * const CKQuadtreeNodeChargeX = @"chargeX";
static NSString * const CKQuadtreeNodeChargeY = @"chargeY";

@implementation CKForceLayoutAnimator {
    CADisplayLink *_displayLink;
    NSMutableSet *_nodes;
    NSMutableSet *_links;
    NSMapTable *_weights;
    NSMapTable *_previousCenters;
    NSMapTable *_fixedNodes;
    CAShapeLayer *_linesLayer;
}

#pragma mark - NSObject

- (instancetype)init {
    self = [self initWithReferenceView:nil];
    return self;
}

- (instancetype)initWithReferenceView:(UIView *)referenceView {
    NSParameterAssert(referenceView);
    self = [super init];
    if (self) {
        _referenceView = referenceView;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
        _nodes = [NSMutableSet set];
        _links = [NSMutableSet set];
        _weights = [NSMapTable weakToStrongObjectsMapTable];
        _previousCenters = [NSMapTable weakToStrongObjectsMapTable];
        _fixedNodes = [NSMapTable weakToStrongObjectsMapTable];

        _linkDistance = 150.0f;
        _linkStrength = 1.0f;
        _friction = 0.9f;
        _charge = -5000.0f;
        _chargeDistance = CGFLOAT_MAX;
        _theta = 0.8f;
        _gravity = 0.1f;

        _linesLayer = [CAShapeLayer layer];
        _linesLayer.strokeColor = [[UIColor grayColor] CGColor];
        _linesLayer.fillColor = [[UIColor clearColor] CGColor];
    }
    return self;
}

#pragma mark - CKForceLayoutAnimator

- (void)setLineColor:(UIColor *)lineColor {
    _linesLayer.strokeColor = [lineColor CGColor];
}

- (UIColor *)lineColor {
    return [UIColor colorWithCGColor:_linesLayer.strokeColor];
}

- (CGFloat)lineWidth {
    return _linesLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _linesLayer.lineWidth = lineWidth;
}

- (void)addNode:(UIView *)node {
    NSParameterAssert(node);
    NSAssert([node.superview isEqual:_referenceView], @"Nodes must be direct children of the reference view");
    [_nodes addObject:node];
}

- (void)removeNode:(UIView *)node {
    [_links minusSet:[_links objectsPassingTest:^BOOL(NSSet *link, BOOL *stop) {
        return [link containsObject:node];
    }]];
    [_nodes removeObject:node];
}

- (void)removeAllNodes {
    [_links removeAllObjects];
    [_nodes removeAllObjects];
}

- (void)linkNode:(UIView *)firstNode toNode:(UIView *)secondNode {
    NSParameterAssert(firstNode);
    NSParameterAssert(secondNode);
    [_links addObject:[NSSet setWithObjects:firstNode, secondNode, nil]];
}

- (void)unlinkNode:(UIView *)firstNode fromNode:(UIView *)secondNode {
    [_links removeObject:[NSSet setWithObjects:firstNode, secondNode, nil]];
}

- (void)fixNode:(UIView *)node atPosition:(CGPoint)point {
    [_fixedNodes setObject:@YES forKey:node];
    [_previousCenters setObject:[NSValue valueWithCGPoint:point] forKey:node];
}

- (void)releaseNode:(UIView *)node {
    [_fixedNodes removeObjectForKey:node];
}

- (void)setAlpha:(CGFloat)alpha {
    if (_alpha) {
        _alpha = MAX(0, alpha);
    } else if (alpha > 0) {
        _alpha = alpha;
        _displayLink.paused = NO;
    }
}

- (void)start {
    // Calculate node weights
    [_weights removeAllObjects];
    [_links enumerateObjectsUsingBlock:^(NSSet *link, BOOL *stop) {
        NSArray *linkArray = link.allObjects;
        UIView *source = linkArray.firstObject;
        UIView *target = linkArray.lastObject;
        [_weights setObject:@([[_weights objectForKey:source] integerValue] + 1) forKey:source];
        [_weights setObject:@([[_weights objectForKey:target] integerValue] + 1) forKey:target];
    }];

    // Set previous centers
    [_previousCenters removeAllObjects];
    [_nodes enumerateObjectsUsingBlock:^(UIView *node, BOOL *stop) {
        [_previousCenters setObject:[NSValue valueWithCGPoint:node.center] forKey:node];
    }];

    _alpha = MAX(0.1f, _alpha);
    [_referenceView.layer insertSublayer:_linesLayer atIndex:0];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    _alpha = 0.0f;
    [_displayLink invalidate];
    [_linesLayer removeFromSuperlayer];
}

- (void)tick {
    // Simulated annealing
    _alpha *= 0.99f;
    if (_alpha < 0.005f) {
        _alpha = 0.0f;
        _displayLink.paused = YES;
        return;
    }

    // Gauss-Seidel relaxation for links
    [_links enumerateObjectsUsingBlock:^(NSSet *link, BOOL *stop) {
        NSArray *linkArray = link.allObjects;
        UIView *source = linkArray.firstObject;
        UIView *target = linkArray.lastObject;
        CGFloat dx = target.center.x - source.center.x;
        CGFloat dy = target.center.y - source.center.y;
        CGFloat distance = sqrt(dx * dx + dy * dy);
        if (distance == 0) return;
        distance = _alpha * _linkStrength * (distance - _linkDistance) / distance;
        dx *= distance;
        dy *= distance;
        CGFloat targetWeight = [[_weights objectForKey:target] doubleValue];
        CGFloat sourceWeight = [[_weights objectForKey:source] doubleValue];
        CGFloat targetProportion = sourceWeight / (targetWeight + sourceWeight);
        CGFloat sourceProportion = 1.0f - targetProportion;
        target.center = CGPointMake(target.center.x - (dx * targetProportion), target.center.y - (dy * targetProportion));
        source.center = CGPointMake(source.center.x + (dx * sourceProportion), source.center.y + (dy * sourceProportion));
    }];

    // Apply pseudo-gravity forces
    CGFloat currentGravity = _alpha * _gravity;
    if (currentGravity) {
        CGPoint center = CGPointMake(CGRectGetMidX(_referenceView.bounds), CGRectGetMidY(_referenceView.bounds));
        [_nodes enumerateObjectsUsingBlock:^(UIView *node, BOOL *stop) {
            node.center = CGPointMake(node.center.x + ((center.x - node.center.x) * currentGravity), node.center.y + ((center.y - node.center.y) * currentGravity));
        }];
    }

    // Construct a quadtree and recursively accumulate charge
    CKQuadTree *tree = [[CKQuadTree alloc] initWithPoints:[_nodes.allObjects valueForKey:@"center"]];
    __block __weak void (^weakAccumulateCharge)(CKQuadTreeNode *node) = nil;
    void (^accumulateCharge)(CKQuadTreeNode *node) = nil;
    weakAccumulateCharge = accumulateCharge = ^(CKQuadTreeNode *node) {
        CGFloat charge = 0.0f, cx = 0.0f, cy = 0.0f;
        for (CKQuadTreeNode *subNode in node.nodes) {
            weakAccumulateCharge(subNode);
            CGFloat nodeCharge = [[subNode objectForKey:CKQuadtreeNodeChargeTotal] doubleValue];
            charge += nodeCharge;
            cx += nodeCharge * [[subNode objectForKey:CKQuadtreeNodeChargeX] doubleValue];
            cy += nodeCharge * [[subNode objectForKey:CKQuadtreeNodeChargeY] doubleValue];
        }
        if (node.point) {
            CGPoint point = [node.point CGPointValue];
            CGFloat pointCharge = _alpha * _charge;
            charge += pointCharge;
            cx += pointCharge * point.x;
            cy += pointCharge * point.y;
        }
        cx /= charge;
        cy /= charge;
        [node setObject:@(charge) forKey:CKQuadtreeNodeChargeTotal];
        [node setObject:@(cx) forKey:CKQuadtreeNodeChargeX];
        [node setObject:@(cy) forKey:CKQuadtreeNodeChargeY];
    };
    accumulateCharge(tree.rootNode);

    // Apply charge forces
    [_nodes enumerateObjectsUsingBlock:^(UIView *node, BOOL *stop) {
        if ([[_fixedNodes objectForKey:node] boolValue])
            return;
        [tree visit:^BOOL(CKQuadTreeNode *treeNode) {
            CGFloat charge = [[treeNode objectForKey:CKQuadtreeNodeChargeTotal] doubleValue];
            CGFloat cx = [[treeNode objectForKey:CKQuadtreeNodeChargeX] doubleValue];
            CGFloat cy = [[treeNode objectForKey:CKQuadtreeNodeChargeY] doubleValue];
            if (!treeNode.point || !CGPointEqualToPoint(node.center, [treeNode.point CGPointValue])) {
                CGFloat dx = cx - node.center.x, dy = cy - node.center.y;
                CGFloat dw = CGRectGetWidth(treeNode.bounds);
                CGFloat dn = dx * dx + dy * dy;
                CGFloat chargeDistance2 = pow(_chargeDistance, 2);
                chargeDistance2 = isnan(chargeDistance2) ? CGFLOAT_MAX : chargeDistance2;

                // Barnes-Hut criterion
                if (dw * dw / pow(_theta, 2) < dn) {
                    if (dn < chargeDistance2) {
                        CGPoint previous = [[_previousCenters objectForKey:node] CGPointValue];
                        CGFloat constant = charge / dn;
                        previous.x -= dx * constant;
                        previous.y -= dy * constant;
                        [_previousCenters setObject:[NSValue valueWithCGPoint:previous] forKey:node];
                    }

                    return YES;
                }

                if (treeNode.point && dn && dn < chargeDistance2) {
                    CGPoint previous = [[_previousCenters objectForKey:node] CGPointValue];
                    CGFloat constant = _alpha * _charge / dn;
                    previous.x -= dx * constant;
                    previous.y -= dy * constant;
                    [_previousCenters setObject:[NSValue valueWithCGPoint:previous] forKey:node];
                }
            }
            return (charge == 0);
        }];
    }];

    // Verlet integration
    [_nodes enumerateObjectsUsingBlock:^(UIView *node, BOOL *stop) {
        CGPoint previous = [[_previousCenters objectForKey:node] CGPointValue];
        CGPoint center = node.center;
        if ([[_fixedNodes objectForKey:node] boolValue]) {
            center = previous;
        } else {
            center.x -= (previous.x - center.x) * _friction;
            center.y -= (previous.y - center.y) * _friction;
        }
        node.center = center;
        [_previousCenters setObject:[NSValue valueWithCGPoint:center] forKey:node];
    }];


    // Draw links
    CGMutablePathRef path = CGPathCreateMutable();
    [_links enumerateObjectsUsingBlock:^(NSSet *link, BOOL *stop) {
        NSArray *linkArray = link.allObjects;
        UIView *source = linkArray.firstObject;
        UIView *target = linkArray.lastObject;
        CGPathMoveToPoint(path, NULL, source.center.x, source.center.y);
        CGPathAddLineToPoint(path, NULL, target.center.x, target.center.y);
    }];

    _linesLayer.path = path;
    CGPathRelease(path);
}

@end
