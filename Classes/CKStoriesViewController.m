//
//  CKStoriesViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKStoriesViewController.h"

#import "CKStory.h"
#import "CKStoryView.h"
#import "CKForceLayoutAnimator.h"
#import "CKStoryViewController.h"

@implementation CKStoriesViewController {
    CKForceLayoutAnimator *_animator;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    _animator = [[CKForceLayoutAnimator alloc] initWithReferenceView:self.view];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[CKStory entityName]];
    NSArray *stories = [_managedObjectContext executeFetchRequest:request error:nil];
    NSMapTable *storyViews = [NSMapTable weakToWeakObjectsMapTable];
    for (CKStory *story in stories) {
        CKStoryView *storyView = [[CKStoryView alloc] initWithFrame:CGRectMake(arc4random_uniform(CGRectGetWidth(self.view.bounds)), arc4random_uniform(CGRectGetHeight(self.view.bounds)), 100.0f, 100.0f)];
        storyView.story = story;
        [self.view addSubview:storyView];
        [_animator addNode:storyView];

        UITapGestureRecognizer *tapRecongizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [storyView addGestureRecognizer:tapRecongizer];
        [storyView addGestureRecognizer:panRecognizer];
        [storyViews setObject:storyView forKey:story];
    }

    for (CKStory *story in stories) {
        CKStoryView *storyView = [storyViews objectForKey:story];
        for (CKStory *neighbor in story.neighbors) {
            CKStoryView *neighborView = [storyViews objectForKey:neighbor];
            [_animator linkNode:storyView toNode:neighborView];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_animator start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [_animator stop];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    _animator.alpha = 0.1f;
}

#pragma mark - CKMainViewController

- (void)tap:(UITapGestureRecognizer *)recognizer {
    CKStoryView *storyView = (CKStoryView *)recognizer.view;
    [UIView animateKeyframesWithDuration:0.3f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.4f animations:^{
            storyView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4f relativeDuration:0.4f animations:^{
            storyView.transform = CGAffineTransformMakeScale(0.85f, 0.85f);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8f relativeDuration:0.2f animations:^{
            storyView.transform = CGAffineTransformIdentity;
        }];
    } completion:nil];

    if (storyView.story.storyPath) {
        CKStoryViewController *storyViewController = [[CKStoryViewController alloc] init];
        storyViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        storyViewController.story = storyView.story;
        [self presentViewController:storyViewController animated:YES completion:nil];
    }
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [_animator fixNode:recognizer.view atPosition:recognizer.view.center];
            break;
        }

        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:_animator.referenceView];
            [recognizer setTranslation:CGPointZero inView:_animator.referenceView];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
            [_animator fixNode:recognizer.view atPosition:CGPointApplyAffineTransform(recognizer.view.center, transform)];
            [_animator setAlpha:0.1f];
            break;
        }

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [_animator releaseNode:recognizer.view];
            break;
        }

        default:
            break;
    }
}

@end
