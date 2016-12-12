//
//  DZPhotoBrowser.m
//  YaoHe
//
//  Created by stonedong on 16/12/11.
//
//

#import "DZPhotoBrowser.h"
#import "DZPhotoViewController.h"
#import "UIBarButtonItem+Button.h"

@interface DZPhotoBrowser () <UIPageViewControllerDataSource>
@property  (nonatomic, strong) UIPageViewController * pageViewController;
@property  (nonatomic, strong) NSArray * photoViewControllers;
@end

@implementation DZPhotoBrowser

- (instancetype)initWithPhotos:(NSArray<DZPhoto *> *)photos {
    self = [super init];
    if (!self) {
        return self;
    }
    _photos = photos;
    return self;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPageViewController];
    //
    NSMutableArray * vcs = [NSMutableArray new];
    for (DZPhoto *photo in _photos) {
        DZPhotoViewController * photoVC = [[DZPhotoViewController alloc] initWithPhoto:photo];
        [vcs addObject:photoVC];
    }
    _photoViewControllers = vcs;
    [_pageViewController setViewControllers:@[_photoViewControllers.firstObject] direction:UIPageViewControllerNavigationOrientationHorizontal animated:YES completion:^(BOOL finished) {

    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _pageViewController.view.frame = self.view.bounds;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem * dismissItem = [UIBarButtonItem barButtonItem:@"关闭" target:self selector:@selector(dismissNavigation)];
    if (self.navigationController.presentingViewController) {
        self.navigationItem.rightBarButtonItem = dismissItem;
    }
}

- (void) dismissNavigation
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
}
@end
