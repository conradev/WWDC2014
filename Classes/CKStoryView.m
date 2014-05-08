//
//  CKStoryView.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKStoryView.h"

@implementation CKStoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:36.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        UIWebView *webView = [[UIWebView alloc] init];
        webView.backgroundColor = [UIColor whiteColor];
        [self addSubview:webView];
        _webView = webView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect imageFrame, labelFrame, webFrame;
    CGRectDivide(self.bounds, &imageFrame, &webFrame, 120.0f, CGRectMinYEdge);
    CGRectDivide(imageFrame, &imageFrame, &labelFrame, 120.0f, CGRectMinXEdge);
    imageFrame = UIEdgeInsetsInsetRect(imageFrame, UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f));
    _titleLabel.frame = labelFrame;
    _webView.frame = webFrame;

    CGPoint imageCenter = CGPointMake(CGRectGetMidX(imageFrame), CGRectGetMidY(imageFrame));
    self.layer.anchorPoint = CGPointMake(imageCenter.x / CGRectGetWidth(self.bounds), imageCenter.y / CGRectGetHeight(self.bounds));
}

@end
