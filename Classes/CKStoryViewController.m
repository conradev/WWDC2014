//
//  CKStoryViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "CKStoryViewController.h"

#import "CKStory.h"
#import "CKStoryHeaderView.h"

#import "UIWebView+Markdown.h"

@interface CKStoryViewController () <UIWebViewDelegate, UIAlertViewDelegate>
@end

static char urlKey;

@implementation CKStoryViewController {
    __weak CKStoryHeaderView *_headerView;
    __weak UIWebView *_webView;
}

#pragma mark - UIViewController

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
    webView.delegate = self;
    [webView loadMarkdownFile:_story.storyPath];
    [self.view addSubview:webView];
    _webView = webView;

    NSDictionary *views = NSDictionaryOfVariableBindings(headerView, webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerView(120)][webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views]];
}

#pragma mark - CKStoryViewController

- (void)setStory:(CKStory *)story {
    _story = story;

    _headerView.story = _story;
    [_webView loadMarkdownFile:_story.storyPath];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"file"])
        return YES;

    if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"External Link" message:@"Opening this link will leave the application. Do you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        objc_setAssociatedObject(alertView, &urlKey, request.URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [alertView show];
    }

    return NO;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [[UIApplication sharedApplication] openURL:objc_getAssociatedObject(alertView, &urlKey)];
    }
}

@end
