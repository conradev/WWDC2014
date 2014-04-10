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
    __weak UIImageView *_imageView;
    __weak CKShapeView *_circleView;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.mask = [CAShapeLayer layer];

        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _imageView = imageView;

        CKShapeView *circleView = [[CKShapeView alloc] init];
        circleView.strokeColor = [UIColor darkGrayColor];
        circleView.fillColor = [UIColor clearColor];
        circleView.lineWidth = 10.0f;
        [self addSubview:circleView];
        _circleView = circleView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.0f);
    _circleView.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0f endAngle:(2.0f * M_PI) clockwise:YES];
    [(CAShapeLayer *)self.layer.mask setPath:_circleView.path.CGPath];
    _circleView.frame = self.bounds;
    _imageView.frame = self.bounds;
}

#pragma mark - CKStoryView

- (void)setStory:(CKStory *)story {
    _story = story;

    self.backgroundColor = _story.color;
    _imageView.image = [UIImage imageNamed:story.imagePath];
}

@end
