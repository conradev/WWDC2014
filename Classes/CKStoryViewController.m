//
//  CKDetailViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/9/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKStoryViewController.h"

#import "CKStory.h"
#import "CKStoryHeaderView.h"

#import "UIWebView+Markdown.h"

@implementation CKStoryViewController {
    __weak CKStoryHeaderView *_headerView;
    __weak UIWebView *_webView;
}

- (void)loadView {
    [super loadView];

    CKStoryHeaderView *headerView = [[CKStoryHeaderView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.story = _story;
    headerView.backgroundColor = _story.color;
    [self.view addSubview:headerView];
    _headerView = headerView;

    UIWebView *webView = [[UIWebView alloc] init];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.backgroundColor = [UIColor whiteColor];
    [webView loadMarkdownFile:_story.storyPath];
    [self.view addSubview:webView];
    _webView = webView;

    NSDictionary *views = NSDictionaryOfVariableBindings(headerView, webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerView(120)][webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views]];
}

- (void)setStory:(CKStory *)story {
    _story = story;

    _headerView.story = _story;
    [_webView loadMarkdownFile:_story.storyPath];
}

@end
