//
//  CKBubbleView.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKBubbleView.h"

#import "CKStory.h"

@implementation CKBubbleView {
    __weak CAShapeLayer *_outlineLayer;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.mask = [CAShapeLayer layer];
        [self addSubview:imageView];
        _imageView = imageView;

        CAShapeLayer *outlineLayer = [CAShapeLayer layer];
        outlineLayer.fillColor = [[UIColor clearColor] CGColor];
        outlineLayer.strokeColor = [[UIColor colorWithRed:0.333f green:0.333f blue:0.333f alpha:1.0f] CGColor];
        outlineLayer.lineWidth = 1.0f;
        [self.layer addSublayer:outlineLayer];
        _outlineLayer = outlineLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _imageView.frame = self.bounds;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint center = CGPointMake(CGRectGetMidX(_imageView.bounds), CGRectGetMidY(_imageView.bounds));
    CGFloat radius = MIN(CGRectGetWidth(_imageView.bounds), CGRectGetHeight(_imageView.bounds)) / 2.0f;
    CGPathAddArc(path, NULL, center.x, center.y, radius, 0.0f, (2.0f * M_PI), true);
    [(CAShapeLayer *)_imageView.layer.mask setPath:path];
    _outlineLayer.path = path;
    CGPathRelease(path);
}

@end
