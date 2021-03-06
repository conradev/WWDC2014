//
//  CKForceLayoutAnimator.h
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

@import UIKit;

@interface CKForceLayoutAnimator : NSObject

@property (readonly, strong, nonatomic) UIView *referenceView;
@property (readonly, strong, nonatomic) NSSet *nodes;
@property (readonly, strong, nonatomic) NSSet *links;

@property (nonatomic) CGFloat linkDistance;
@property (nonatomic) CGFloat linkStrength;
@property (nonatomic) CGFloat friction;
@property (nonatomic) CGFloat charge;
@property (nonatomic) CGFloat chargeDistance;
@property (nonatomic) CGFloat theta;
@property (nonatomic) CGFloat gravity;
@property (nonatomic) CGFloat alpha;

@property (copy, nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;

- (instancetype)initWithReferenceView:(UIView *)referenceView;

- (void)addNode:(UIView *)node;
- (void)removeNode:(UIView *)node;
- (void)removeAllNodes;

- (void)linkNode:(UIView *)firstNode toNode:(UIView *)secondNode;
- (void)unlinkNode:(UIView *)firstNode fromNode:(UIView *)secondNode;

- (void)fixNode:(UIView *)node atPosition:(CGPoint)point;
- (void)releaseNode:(UIView *)node;

- (void)start;
- (void)stop;

@end
