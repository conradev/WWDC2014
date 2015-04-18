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
#import "CKBrowserViewController.h"
#import "NSData+FILE.h"

@interface CKStoryViewController () <UIWebViewDelegate>
@end

@implementation CKStoryViewController

@dynamic view;

#pragma mark - UIViewController

- (void)loadView {
    self.view = [[CKStoryView alloc] init];
    self.view.webView.delegate = self;
    self.view.titleLabel.text = _story.name;
    self.view.titleLabel.textColor = _story.textColor;
    self.view.backgroundColor = _story.color;
}

#pragma mark - CKStoryViewController

- (void)setStory:(CKStory *)story {
    _story = story;

    self.view.titleLabel.text = _story.name;
    self.view.titleLabel.textColor = _story.textColor;
    self.view.backgroundColor = _story.color;
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
    NSString *css = [NSString stringWithFormat:@"<link href=\"story.css\" type=\"text/css\" rel=\"stylesheet\"></link><style type=\"text/css\">a {color:#%06x;}</style>", (unsigned int)color];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", css, body];
    [self.view.webView loadHTMLString:html baseURL:storiesURL];
}

- (void)resetWebView {
    [self.view.webView loadHTMLString:@"" baseURL:nil];
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

    [[UIApplication sharedApplication] openURL:request.URL];

    return NO;
}

@end
