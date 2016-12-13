//
//  DZPhotoBrowser.m
//  YaoHe
//
//  Created by stonedong on 16/12/11.
//
//

#import "DZPhotoBrowser.h"
#import "DZPhotoViewController.h"
#import <DZObjectProxy.h>
@interface DZPhotoBrowser () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, DZPhotoTransitionAnimatorDelegate>
@property  (nonatomic, strong) UIPageViewController * pageViewController;
@property  (nonatomic, strong) NSArray * photoViewControllers;
@property  (nonatomic, assign) NSUInteger  initializeIndex;
@property  (nonatomic, strong) UIPageControl * photoPageControl;
@end

@implementation DZPhotoBrowser
@synthesize transitionAnimator = _transitionAnimator;
- (void) dealloc
{

}
- (instancetype)initWithPhotos:(NSArray<DZPhoto *> *)photos initializeIndex:(NSUInteger)index {
    self = [super init];
    if (!self) {
        return self;
    }
    _photos = photos;
    _initializeIndex = index;
    return self;
}
- (DZPhotoTransitionAnimator *)transitionAnimator {
    if (!_transitionAnimator) {
        _transitionAnimator = [DZPhotoTransitionAnimator new];
        _transitionAnimator.delegate = self;
    }
    return _transitionAnimator;
}

- (UIImageView *)sourceImageViewForPhotoTransitionAnimator:(DZPhotoTransitionAnimator *)animator {
    DZPhotoViewController * vc = self.pageViewController.viewControllers.firstObject;
    if (vc) {
        return vc.photo.sourceImageView;
    }
    return nil;
}
- (void) setupPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [_pageViewController willMoveToParentViewController:self];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];

    //
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
}

- (DZPhotoViewController *)topPhotoViewController {
    return _pageViewController.viewControllers.firstObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupPageViewController];

    //
    self.view.backgroundColor = [UIColor clearColor];
    //
    NSMutableArray * vcs = [NSMutableArray new];
    for (DZPhoto *photo in _photos) {
        DZPhotoViewController * photoVC = [[DZPhotoViewController alloc] initWithPhoto:photo];
        [vcs addObject:photoVC];
    }
    _photoViewControllers = vcs;

    //
    _photoPageControl = [[UIPageControl alloc] init];
    _photoPageControl.numberOfPages = _photoViewControllers.count;
    [self.view addSubview:_photoPageControl];
    if (_photoViewControllers.count <= 1) {
       _photoPageControl.hidden = YES;
    }

    DZPhotoViewController * firstViewController;
    if (_initializeIndex >=0 && _initializeIndex< _photoViewControllers.count) {
        firstViewController = _photoViewControllers[_initializeIndex];
    }
    if (firstViewController) {
        [_pageViewController setViewControllers:@[firstViewController] direction:UIPageViewControllerNavigationOrientationHorizontal animated:YES completion:^(BOOL finished) {
            _photoPageControl.currentPage = _initializeIndex;
         }];
    } else {
        [_pageViewController setViewControllers:@[] direction:UIPageViewControllerNavigationOrientationHorizontal animated:NO completion:^(BOOL finished) {
            _photoPageControl.currentPage = 0;
        }];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _pageViewController.view.frame = self.view.bounds;

    CGFloat  pageControlHeight  = 15;
    CGRect pageRect;
    CGRect rectRect;
    CGRectDivide(self.view.bounds, &pageRect, &rectRect, pageControlHeight, CGRectMaxYEdge);
    pageRect = CGRectOffset(pageRect, 0, -20);
    _photoPageControl.frame = pageRect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [_photoViewControllers indexOfObject:viewController];
    if (index + 1 >= _photoViewControllers.count) {
        return nil;
    } else {
        return _photoViewControllers[index + 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    int index = [_photoViewControllers indexOfObject:viewController];
    if (index - 1 < 0) {
        return nil;
    } else {
        return _photoViewControllers[index -1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    DZPhotoViewController * vc = pageViewController.viewControllers.firstObject;
    if (vc) {
        NSUInteger index = [_photoViewControllers indexOfObject:vc];
        _photoPageControl.currentPage = index;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void) dismissNavigation
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
}
@end
