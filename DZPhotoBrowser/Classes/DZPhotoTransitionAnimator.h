//
// Created by baidu on 2016/12/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DZPhotoTransitionAnimator;
@protocol DZPhotoTransitionAnimatorDelegate
- (UIImageView *) sourceImageViewForPhotoTransitionAnimator:(DZPhotoTransitionAnimator*)animator;
@end

@interface DZPhotoTransitionAnimator : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property  (nonatomic, weak) NSObject<DZPhotoTransitionAnimatorDelegate>* delegate;
@end