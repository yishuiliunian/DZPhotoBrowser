//
//  DZPhotoViewController.m
//  YaoHe
//
//  Created by stonedong on 16/12/11.
//
//

#import "DZPhotoViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "DZPhoto.h"

@interface DZPhotoViewController () <UIScrollViewDelegate>
@property  (nonatomic, strong, readonly) UIScrollView * scrollView;
@property  (nonatomic, strong, readonly) UIImageView * imageView;
@property  (nonatomic, strong) UIGestureRecognizer * doubleTapGesture;
@end

@implementation DZPhotoViewController
@synthesize scrollView = _scrollView;
- (instancetype)initWithPhoto:(DZPhoto *)photo {
    self = [super init];
    if (!self) {
        return self;
    }
    _photo = photo;
    return self;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.maximumZoomScale = 3.0f;
    }
    return _scrollView;
}

- (void)loadView {
    self.view = self.scrollView;
    _imageView = [UIImageView new];
    [self.view addSubview:_imageView];
    //
    _imageView.userInteractionEnabled = YES;
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    [_imageView addGestureRecognizer:_doubleTapGesture];
    _scrollView.zoomScale = 1.0f;
}

- (void) handleDoubleTapGesture:(UIGestureRecognizer *)gestrue
{
    if (gestrue.state == UIGestureRecognizerStateRecognized) {
        [_scrollView setZoomScale:2 animated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _imageView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageView sd_setImageWithURL:self.photo.url];
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

@end
