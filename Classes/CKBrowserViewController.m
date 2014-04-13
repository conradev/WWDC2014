//
//  CKBrowserViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKBrowserViewController.h"

@interface CKBrowserViewController () <UIWebViewDelegate>
@end

@implementation CKBrowserViewController {
    UIWebView *_webView;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Loading...";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];

        _webView = [[UIWebView alloc] init];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.delegate = self;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    NSDictionary *views = NSDictionaryOfVariableBindings(_webView);
    [self.view addSubview:_webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:views]];
}

#pragma mark - CKBrowserViewController

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadRequest:(NSURLRequest *)request {
    [_webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
