//
//  CKStoryHeaderView.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKStoryHeaderView.h"

#import "CKStory.h"

@implementation CKStoryHeaderView {
    __weak UIImageView *_imageView;
    __weak UILabel *_titleLabel;
    __weak UILabel *_subtitleLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.mask = [CAShapeLayer layer];
        imageView.image = [UIImage imageNamed:_story.imagePath];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:imageView];
        _imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:36.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = _story.name;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        NSDictionary *metrics = @{ @"margin": @15 };
        NSDictionary *views = NSDictionaryOfVariableBindings(imageView, titleLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[imageView]-(30)-[titleLabel]-(margin)-|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[imageView]-(margin)-|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[titleLabel]-(margin)-|" options:0 metrics:metrics views:views]];
        [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGPoint center = CGPointMake(CGRectGetMidX(_imageView.bounds), CGRectGetMidY(_imageView.bounds));
    CGFloat radius = (MIN(CGRectGetWidth(_imageView.bounds), CGRectGetHeight(_imageView.bounds)) / 2.0f);
    UIBezierPath *imageMaskPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0f endAngle:(2.0f * M_PI) clockwise:YES];
    [(CAShapeLayer *)_imageView.layer.mask setPath:imageMaskPath.CGPath];
}

- (void)setStory:(CKStory *)story {
    _story = story;
    _imageView.image = [UIImage imageNamed:_story.imagePath];
    _titleLabel.text = _story.name;
}

@end
