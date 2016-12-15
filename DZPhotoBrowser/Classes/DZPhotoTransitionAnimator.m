//
// Created by baidu on 2016/12/12.
//

#import "DZPhotoTransitionAnimator.h"
#import "DZPhotoViewController.h"
#import "DZPhotoBrowser.h"
#import <DZGeometryTools.h>

@implementation DZPhotoTransitionAnimator


- (NSTimeInterval)transitionDuration {
    return 0.25;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView* fromView = fromVC.view;
    UIView* toView = toVC.view;
    UIView* containerView = [transitionContext containerView];

    CGFloat duration = [self transitionDuration:transitionContext];

    UIImageView * sourceImageView = nil;
    if ([self.delegate respondsToSelector:@selector(sourceImageViewForPhotoTransitionAnimator:)]) {
        sourceImageView = [self.delegate sourceImageViewForPhotoTransitionAnimator:self];
    }
    int tag = 8473;
    UIView * backgroundView =  (UIView *) [containerView viewWithTag:tag];
    if (!backgroundView) {
        backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.tag = tag;
    }
    [containerView insertSubview:backgroundView atIndex:0];
    backgroundView.frame = containerView.bounds;
    if (toVC.isBeingPresented) {

        UIView * imageContentView = containerView;
        [containerView addSubview:toView];
        toView.frame = containerView.bounds;

        UIImageView * transitionImageView = [UIImageView new];

        transitionImageView.image = sourceImageView.image;
        [imageContentView addSubview:transitionImageView];
        CGRect sourceRect = [imageContentView convertRect:sourceImageView.frame fromView:sourceImageView.superview];

        transitionImageView.frame = sourceRect;
        UINavigationController* nav = (UINavigationController*)toVC;
        CGRect aimRect = CGRectCenter(containerView.bounds, sourceImageView.frame.size);
        if ([nav.topViewController isKindOfClass:[DZPhotoBrowser class]]) {
            UIImageView * photoView = [[(DZPhotoBrowser *) nav.topViewController topPhotoViewController] imageView];
            if(photoView.image && !CGRectIsEmpty(photoView.frame))
            {
                aimRect = [imageContentView convertRect:photoView.frame   fromView:photoView.superview];
            }
#ifdef DEBUG
            CGPrintKeyRect(@"Image Aim Rect", aimRect);
#endif
            transitionImageView.contentMode = photoView.contentMode = sourceImageView.contentMode;
            transitionImageView.layer.masksToBounds = photoView.layer.masksToBounds = sourceImageView.layer.masksToBounds;
        }
        backgroundView.alpha = 0.0;
        toView.alpha = 0.0;
        [UIView animateWithDuration:duration animations:^{
            transitionImageView.frame = aimRect;
            toView.backgroundColor = [UIColor blackColor];
            backgroundView.alpha = 1.0;
        } completion:^(BOOL finished) {
            BOOL isCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!isCancelled];
            [transitionImageView removeFromSuperview];
            toView.frame = containerView.bounds;
            toView.alpha = 1.0;
        }];
    }

    if (fromVC.isBeingDismissed) {


        CGRect toRect;
        UIView * imageContentView = containerView;
        toRect = [imageContentView convertRect:sourceImageView.frame fromView:sourceImageView.superview];

        UINavigationController* nav = (UINavigationController*)fromVC;

        UIImageView * transitionImageView = [UIImageView new];
        [imageContentView addSubview:transitionImageView];

        if ([nav.topViewController isKindOfClass:[DZPhotoBrowser class]]) {
            UIImageView * photoView = [[(DZPhotoBrowser *) nav.topViewController topPhotoViewController] imageView];
            transitionImageView.frame = [imageContentView convertRect:photoView.frame   fromView:photoView.superview];
            transitionImageView.image = photoView.image;
            transitionImageView.contentMode = sourceImageView.contentMode;
            transitionImageView.layer.masksToBounds = sourceImageView.layer.masksToBounds;
        }
        fromVC.view.frame = containerView.bounds;

        [fromVC beginAppearanceTransition:YES animated:YES];
        [toVC beginAppearanceTransition:YES animated:YES];
        backgroundView.alpha = 1.0;
        fromVC.view.alpha = 0.0;
        [UIView animateWithDuration:duration animations:^{
            transitionImageView.frame = toRect;
            backgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            BOOL isCancelled = [transitionContext transitionWasCancelled];
            [transitionImageView removeFromSuperview];
            [fromVC endAppearanceTransition];
            [toVC endAppearanceTransition];
            [transitionContext completeTransition:!isCancelled];
        }];
    }

}
@end