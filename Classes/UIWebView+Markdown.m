//
//  UIWebView+Markdown.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/10/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#include <stdio.h>
#include <mkdio.h>

#import "UIWebView+Markdown.h"

#import "NSData+FILE.h"

@implementation UIWebView (Markdown)

- (void)loadMarkdownFile:(NSString *)fileName {
    NSURL *storiesURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Stories"];
    NSURL *infoURL = [storiesURL URLByAppendingPathComponent:fileName];
    FILE *infoFile = fopen([infoURL fileSystemRepresentation], "r");
    MMIOT *document = mkd_in(infoFile, 0);
    NSMutableData *htmlData = [NSMutableData data];
    FILE *htmlFile = CKOpenData(htmlData);
    markdown(document, htmlFile, 0);
    mkd_cleanup(document);
    fclose(infoFile);
    fclose(htmlFile);
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    htmlString = [[@"<html><head><link href=\"story.css\" type=\"text/css\" rel=\"stylesheet\"></link></head><body>" stringByAppendingString:htmlString] stringByAppendingString:@"</body></html>"];
    [self loadHTMLString:htmlString baseURL:storiesURL];
}

@end
