//
//  CKStoryViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <stdio.h>
#import <mkdio.h>

#import "CKStoryViewController.h"

#import "CKStory.h"
#import "CKStoryHeaderView.h"
#import "CKBrowserViewController.h"
#import "NSData+FILE.h"

@interface CKStoryViewController () <UIWebViewDelegate, UIAlertViewDelegate>
@end

@implementation CKStoryViewController {
    __weak CKStoryHeaderView *_headerView;
    __weak UIWebView *_webView;
    __weak UITapGestureRecognizer *_tapRecognizer;
}

#pragma mark - UIViewController

- (void)dealloc {
    [_tapRecognizer.view removeGestureRecognizer:_tapRecognizer];
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
    webView.delegate = self;
    [self.view addSubview:webView];
    _webView = webView;

    NSDictionary *views = NSDictionaryOfVariableBindings(headerView, webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerView(120)][webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_tapRecognizer == nil) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.cancelsTouchesInView = NO;
        [self.view.window addGestureRecognizer:tapRecognizer];
        _tapRecognizer = tapRecognizer;
    }
}

#pragma mark - CKStoryViewController

- (void)tap:(UITapGestureRecognizer *)tapRecognizer {
    if (![self.view pointInside:[tapRecognizer locationInView:self.view] withEvent:nil]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setStory:(CKStory *)story {
    _story = story;

    _headerView.story = _story;
    [self loadWebView];
}

- (void)loadWebView {
    NSURL *storiesURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Stories"];
    NSURL *url = [storiesURL URLByAppendingPathComponent:_story.storyPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path])
        return;
    NSMutableData *data = [NSMutableData data];
    FILE *input = fopen([url fileSystemRepresentation], "r");
    FILE *output = CKOpenData(data);
    MMIOT *document = mkd_in(input, 0);
    markdown(document, output, 0);
    mkd_cleanup(document);
    fclose(input);
    fclose(output);
    UInt32 color = ((_story.colorValue.integerValue & 0xFFFFFF00) >> 8);
    NSString *css = [NSString stringWithFormat:@"<link href=\"story.css\" type=\"text/css\" rel=\"stylesheet\"></link><style type=\"text/css\">a {color:#%06x;}</style>", color];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", css, body];
    [_webView loadHTMLString:html baseURL:storiesURL];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL isFileURL])
        return YES;

    if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]) {
        CKBrowserViewController *broswerViewController = [[CKBrowserViewController alloc] init];
        broswerViewController.navigationItem.rightBarButtonItem.tintColor = _story.textColor;
        [broswerViewController loadRequest:request];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:broswerViewController];
        navController.navigationBar.barTintColor = _story.color;
        navController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: _story.textColor };
        [self presentViewController:navController animated:YES completion:nil];
        return NO;
    }

    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] openURL:request.URL];
    }];

    return NO;
}

@end
