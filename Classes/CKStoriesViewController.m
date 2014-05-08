//
//  CKStoriesViewController.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <POP/POP.h>
#import <POP/POPCGUtils.h>

#import "CKStoriesViewController.h"

#import "CKStory.h"
#import "CKBubbleView.h"
#import "CKStoryView.h"
#import "CKForceLayoutAnimator.h"
#import "CKStoryViewController.h"

static NSString * const CKBubbleAnimatorPosition = @"animatorPosition";

static NSString * const CKBubbleFixPositionKey = @"fixPosition";
static NSString * const CKShadowViewAppearKey = @"shadowAppear";
static NSString * const CKStoryViewExpandKey = @"storyExpand";
static NSString * const CKStoryViewShrinkKey = @"storyShrink";

@implementation CKStoriesViewController {
    CKForceLayoutAnimator *_animator;
    CKStoryViewController *_storyViewController;
    NSMapTable *_stories;

    __weak CKBubbleView *_fixedBubbleView;
    __weak UIView *_shadowView;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _stories = [NSMapTable weakToStrongObjectsMapTable];
        _storyViewController = [[CKStoryViewController alloc] init];
        _storyViewController.view.bounds = CGRectMake(0, 0, 540.0f, 620.0f);
        _storyViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    _animator = [[CKForceLayoutAnimator alloc] initWithReferenceView:self.view];
    _animator.alpha = 1.0f;

    _storyViewController.view.alpha = 0.0f;
    [self addChildViewController:_storyViewController];
    [self.view addSubview:_storyViewController.view];
    [_storyViewController didMoveToParentViewController:self];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadow:)];

    UIView *shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    shadowView.alpha = 0.0f;
    [shadowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:shadowView];
    _shadowView = shadowView;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[CKStory entityName]];
    NSArray *stories = [_managedObjectContext executeFetchRequest:request error:nil];
    NSMapTable *bubbleViews = [NSMapTable weakToWeakObjectsMapTable];
    for (CKStory *story in stories) {
        CKBubbleView *bubbleView = [[CKBubbleView alloc] init];
        bubbleView.bounds = (CGRect){ CGPointZero, CGSizeMake(100.0f, 100.0f) };
        bubbleView.center = CGPointMake(arc4random_uniform(CGRectGetWidth(self.view.bounds)), arc4random_uniform(CGRectGetHeight(self.view.bounds)) + CGRectGetHeight(self.view.bounds));
        bubbleView.imageView.backgroundColor = story.color;
        [bubbleView.imageView setImage:[UIImage imageNamed:story.imagePath]];

        [self.view addSubview:bubbleView];
        [_animator addNode:bubbleView];
        [bubbleViews setObject:bubbleView forKey:story];

        UITapGestureRecognizer *tapRecongizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBubble:)];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panBubble:)];
        [bubbleView addGestureRecognizer:tapRecongizer];
        [bubbleView addGestureRecognizer:panRecognizer];
    }

    for (CKStory *story in stories) {
        CKBubbleView *bubbleView = [bubbleViews objectForKey:story];
        [_stories setObject:story forKey:bubbleView];
        for (CKStory *neighbor in story.neighbors) {
            [_animator linkNode:bubbleView toNode:[bubbleViews objectForKey:neighbor]];
        }
    }

    _animator.alpha = 0.25f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    float delay = (_animator.alpha == 0.25f) ? 0.5 : 0.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_animator start];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [_animator stop];
}

- (void)viewDidLayoutSubviews {
    _shadowView.frame = self.view.bounds;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    _animator.alpha = 0.1f;
}

#pragma mark - POPAnimationDelegate

- (void)pop_animationDidStart:(POPPropertyAnimation *)anim {
    if ([[_storyViewController.view.layer pop_animationForKey:CKStoryViewExpandKey] isEqual:anim]) {
        _storyViewController.view.alpha = 1.0f;
    } else if ([[_shadowView pop_animationForKey:CKShadowViewAppearKey] isEqual:anim]) {
        [self.view bringSubviewToFront:_shadowView];
        [self.view bringSubviewToFront:_storyViewController.view];
        [self.view bringSubviewToFront:_fixedBubbleView];
    }
}

- (void)pop_animationDidReachToValue:(POPAnimation *)anim {
    if ([[_fixedBubbleView pop_animationForKey:CKBubbleFixPositionKey] isEqual:anim]) {
        POPSpringAnimation *expandAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        expandAnimation.fromValue = [NSValue valueWithCGPoint:CGPointZero];
        expandAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0f, 1.0f)];
        expandAnimation.delegate = self;

        POPBasicAnimation *shadowAnimation = [POPBasicAnimation easeOutAnimation];
        shadowAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        shadowAnimation.duration = 0.3f;
        shadowAnimation.fromValue = @(_shadowView.alpha);
        shadowAnimation.toValue = @0.5f;
        shadowAnimation.delegate = self;

        [_shadowView pop_addAnimation:shadowAnimation forKey:CKShadowViewAppearKey];
        [_storyViewController.view.layer pop_addAnimation:expandAnimation forKey:CKStoryViewExpandKey];
    } else if ([[_storyViewController.view.layer pop_animationForKey:CKStoryViewShrinkKey] isEqual:anim]) {
        [_animator releaseNode:_fixedBubbleView];
        _fixedBubbleView = nil;
    }
}

#pragma mark - CKMainViewController

- (void)presentStory:(CKStory *)story fromBubbleView:(CKBubbleView *)bubbleView {
    if (!story.storyPath)
        return;

    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));

    [_storyViewController.view layoutIfNeeded];
    CGFloat width = CGRectGetWidth(_storyViewController.view.bounds);
    CGFloat height = CGRectGetHeight(_storyViewController.view.bounds);
    CGPoint imageCenter = CGPointApplyAffineTransform(_storyViewController.view.layer.anchorPoint, CGAffineTransformMakeScale(width, height));
    _storyViewController.view.center = CGPointMake(center.x - (width / 2.0f) + imageCenter.x, center.y - (height / 2.0f) + imageCenter.y);
    _storyViewController.story = story;
    [_storyViewController loadWebView];

    POPSpringAnimation *positionAnimation = [POPSpringAnimation animation];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:bubbleView.center];
    positionAnimation.toValue = [NSValue valueWithCGPoint:_storyViewController.view.center];
    positionAnimation.delegate = self;
    positionAnimation.property = [POPAnimatableProperty propertyWithName:CKBubbleAnimatorPosition initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(UIView *obj, const CGFloat values[]) {
            [_animator fixNode:obj atPosition:values_to_point(values)];
        };
        prop.readBlock = ^(UIView *obj, CGFloat values[]) {
            values_from_point(values, obj.center);
        };
    }];

    CGFloat clearComponents[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    POPBasicAnimation *lineFadeAnimation = [POPBasicAnimation easeInAnimation];
    lineFadeAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeColor];
    lineFadeAnimation.duration = 0.25f;
    lineFadeAnimation.fromValue = (__bridge id)bubbleView.outlineLayer.strokeColor;
    lineFadeAnimation.toValue = (__bridge id)POPCGColorRGBACreate(clearComponents);

    [bubbleView.outlineLayer pop_addAnimation:lineFadeAnimation forKey:@"fadeOut"];
    [bubbleView pop_addAnimation:positionAnimation forKey:CKBubbleFixPositionKey];
    _fixedBubbleView = bubbleView;
    _animator.alpha = 0.3f;
}

- (void)dismissStory {
    POPBasicAnimation *shadowAnimation = [POPBasicAnimation easeOutAnimation];
    shadowAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    shadowAnimation.duration = 0.3f;
    shadowAnimation.fromValue = @(_shadowView.alpha);
    shadowAnimation.toValue = @0.0f;

    POPSpringAnimation *shrinkAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    shrinkAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0f, 1.0f)];
    shrinkAnimation.toValue = [NSValue valueWithCGPoint:CGPointZero];
    shrinkAnimation.delegate = self;
    shrinkAnimation.springSpeed = 20.0f;
    shrinkAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        _storyViewController.view.alpha = 0.0f;
        _storyViewController.view.layer.transform = CATransform3DIdentity;
        [_storyViewController resetWebView];
    };

    CGFloat darkGrayComponents[] = { 0.333f, 0.333f, 0.333f, 1.0f };
    POPBasicAnimation *lineFadeAnimation = [POPBasicAnimation easeInAnimation];
    lineFadeAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeColor];
    lineFadeAnimation.duration = 0.25f;
    lineFadeAnimation.fromValue = (__bridge id)_fixedBubbleView.outlineLayer.strokeColor;
    lineFadeAnimation.toValue = (__bridge id)POPCGColorRGBACreate(darkGrayComponents);

    [_fixedBubbleView.outlineLayer pop_addAnimation:lineFadeAnimation forKey:@"fadeIn"];
    [_shadowView pop_addAnimation:shadowAnimation forKey:CKShadowViewAppearKey];
    [_storyViewController.view.layer pop_addAnimation:shrinkAnimation forKey:CKStoryViewShrinkKey];
    _animator.alpha = 0.3f;
}

- (void)tapBubble:(UITapGestureRecognizer *)recognizer {
    [_storyViewController.view layoutIfNeeded];

    [self presentStory:[_stories objectForKey:recognizer.view] fromBubbleView:(CKBubbleView *)recognizer.view];
}

- (void)tapShadow:(UITapGestureRecognizer *)recognizer {
    [self dismissStory];
}

- (void)panBubble:(UIPanGestureRecognizer *)recognizer {
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
