//
//  CKStoryView.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <CKShapeView.h>

#import "CKStoryView.h"

#import "CKStory.h"

@implementation CKStoryView {
    __weak UIView *_maskView;
    __weak UIImageView *_imageView;
    __weak CKShapeView *_circleView;
    __weak CKShapeView *_glowView;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIView *maskView = [[UIView alloc] init];
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.layer.mask = [CAShapeLayer layer];
        [self addSubview:maskView];
        _maskView = maskView;

        UIImageView *imageView = [[UIImageView alloc] init];
        [maskView addSubview:imageView];
        _imageView = imageView;

        CKShapeView *circleView = [[CKShapeView alloc] init];
        circleView.strokeColor = [UIColor darkGrayColor];
        circleView.fillColor = [UIColor clearColor];
        [self addSubview:circleView];
        _circleView = circleView;

        CKShapeView *glowView = [[CKShapeView alloc] init];
        glowView.strokeColor = [UIColor blueColor];
        glowView.fillColor = [UIColor clearColor];
        [self addSubview:glowView];
        _glowView = glowView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.0f);
    _circleView.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0f endAngle:(2.0f * M_PI) clockwise:YES];
    [(CAShapeLayer *)_maskView.layer.mask setPath:_circleView.path.CGPath];

    _maskView.frame = self.bounds;
    _circleView.frame = self.bounds;
    _imageView.frame = _maskView.bounds;
}

#pragma mark - CKStoryView

- (void)setStory:(CKStory *)story {
    _story = story;

    _maskView.backgroundColor = _story.color;
    _imageView.image = [UIImage imageNamed:story.imagePath];
}

@end
