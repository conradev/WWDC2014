//
//  CKStoryViewController.h
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

@import UIKit;

#import "CKStoryView.h"

@class CKStory;

@interface CKStoryViewController : UIViewController

@property (strong, nonatomic) CKStory *story;

@property (strong, nonatomic) CKStoryView *view;

- (void)loadWebView;

- (void)resetWebView;

@end
