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
#import "DZGeometryTools.h"
#import <DACircularProgressView.h>
#import <DZAlertPool.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LBXScanWrapper.h"
#import "DZURLRoute.h"

@interface DZPhotoViewController () <UIScrollViewDelegate>
{
    BOOL  _willLayout;
    BOOL _willRestoreUI;
}

@property  (nonatomic, strong) UITapGestureRecognizer * doubleTapGesture;
@property  (nonatomic, strong) DACircularProgressView * progressView;
@property  (nonatomic, assign) BOOL loading;
@end

@implementation DZPhotoViewController
@synthesize scrollView = _scrollView;

- (void) dealloc
{
}
- (instancetype)initWithPhoto:(DZPhoto *)photo {
    self = [super init];
    if (!self) {
        return self;
    }
    _photo = photo;
    _willLayout = YES;
    _willRestoreUI = NO;
    return self;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    //
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    _doubleTapGesture.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:_doubleTapGesture];

    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];

    [singleTap requireGestureRecognizerToFail:_doubleTapGesture];
    _scrollView.zoomScale = 1.0f;

    _progressView = [DACircularProgressView new];
    _progressView.roundedCorners = YES;
    _progressView.trackTintColor = [UIColor clearColor];
    [self.view addSubview:_progressView];

    UILongPressGestureRecognizer * longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longGest];
}
- (void) handleLongPress:(UILongPressGestureRecognizer*)gest
{
    if (gest.state == UIGestureRecognizerStateBegan) {
        [self showActions];
    }
}
- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    DZAlertShowSuccess(@"保存成功");
}

- (void) scanThisPic
{
    [LBXScanWrapper recognizeImage:self.imageView.image success:^(NSArray<LBXScanResult *> *array) {
        if (array.count) {
            LBXScanResult * result = array.firstObject;
            if (!result.strScanned) {
                DZAlertShowError(@"没有识别到任何二维码信息");
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    NSString * url = result.strScanned?:@"";
                    [[DZURLRoute defaultRoute] routeURL:DZURLRouteQueryLink(url, @{})];
                }];
            }
        } else {
            DZAlertShowError(@"没有识别到任何二维码信息");
        }
    }];
}
- (void) showActions {
    if (self.loading) {
        return;
    }
    typeof(self) __weak weakSelf = self;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction * save = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImageWriteToSavedPhotosAlbum(_imageView.image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];


    UIAlertAction * scan  = [UIAlertAction actionWithTitle:@"扫描图片中的二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf scanThisPic];
    }];
    UIAlertAction * share = [UIAlertAction actionWithTitle:@"分享图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        if(! weakSelf) {
            return;;
        }
        NSArray * items = @[weakSelf.imageView.image];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [weakSelf presentViewController:activityViewController animated:YES completion:nil];
    }];

    [alert addAction:cancel];
    [alert addAction:save];
    [alert addAction:share];
    [alert addAction:scan];


    [self.navigationController  presentViewController:alert animated:YES completion:^{

    }];
}
- (void) handleSingleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self dismissViewControllerAnimated:YES completion:^{

        }];
    }
}


- (void) layoutWithImage:(UIImage *)image animated:(BOOL)animated
{
    CGSize size = {40,40};
    if (image && ![image isKindOfClass:[NSNull class]]) {
        [self layoutWithImageSize:image.size animated:animated];
    } else {
        [self layoutWithImageSize:size animated:animated];
    }
}
- (void) layoutWithImageSize:(CGSize) size animated:(BOOL)animated
{
    void (^Animator)() = ^{
        [self layoutWithImageSize:size];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:Animator completion:^(BOOL finished) {

        }];
    } else {
        Animator();
    }
}
- (void) layoutWithImageSize:(CGSize) size
{
    CGRect  contentRect = self.view.bounds;
    if (CGRectIsEmpty(contentRect)) {
        return;;
    }
    CGSize aimSize;
    if (size.width < size.height) {
       if (size.height <= CGRectGetHeight(contentRect)) {
           aimSize = size;
           if (aimSize.width > CGRectGetWidth(contentRect)){
               aimSize = CGSizeScale(aimSize, CGRectGetWidth(contentRect)/aimSize.width);
           }
       } else {
           aimSize = CGSizeScale(size, CGRectGetHeight(contentRect)/size.height);
           if (aimSize.width > CGRectGetWidth(contentRect)){
              aimSize = CGSizeScale(aimSize, CGRectGetWidth(contentRect)/aimSize.width);
           } else if (aimSize.width != 0 && aimSize.height / aimSize.width > 3) {
               aimSize = CGSizeScale(aimSize, CGRectGetWidth(contentRect)/aimSize.width);
           }
       }
    } else {
        if (size.width <= CGRectGetWidth(contentRect)) {
            aimSize = size;
        } else {
            aimSize = CGSizeScale(size, CGRectGetWidth(contentRect)/ size.width);
        }
    }
    _scrollView.contentSize = aimSize;
    CGRect rect = CGRectCenter(contentRect, aimSize);
    if (rect.origin.y < 0) {
        rect.origin.y = 0;
    }
    _imageView.frame =  rect;

#ifdef DEBUG
    CGPrintKeyRect(@"Destani Rect", self.imageView.frame);
#endif
}
- (void) handleDoubleTapGesture:(UIGestureRecognizer *)gestrue
{
    if (gestrue.state == UIGestureRecognizerStateRecognized) {
        CGFloat  aimScale = (int)floor(_scrollView.zoomScale) % 3 +1;
        [_scrollView setZoomScale:aimScale animated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    NSString * key = [manager cacheKeyForURL:_photo.url];
    UIImage * image = [[[SDWebImageManager sharedManager] imageCache] imageFromCacheForKey:key];
    if (!image) {
        image = self.photo.image;
    }
    if (image) {
        self.imageView.image = image;
        self.progressView.hidden = YES;
        self.loading = NO;
        [self layoutWithImage:image animated:NO];
    } else {
        self.progressView.hidden = NO;
        self.progressView.progress = 0.0;
        __weak  typeof(self) weakSelf = self;
        self.loading = YES;
        UIImage * thumbnail = _photo.thumb;
        if (thumbnail) {
            self.imageView.image = thumbnail;
            if (_photo.sourceImageView && !CGRectIsEmpty(_photo.sourceImageView.frame)) {
                [self layoutWithImageSize:_photo.sourceImageView.frame.size animated:NO];
            } else {
                [self layoutWithImage:thumbnail animated:NO];
            }
        } else {
            [self layoutWithImageSize:CGSizeMake(40, 40) animated:NO];
        }
        [self.imageView sd_setImageWithURL:self.photo.url placeholderImage:_photo.thumb options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (expectedSize != 0) {
                    weakSelf.progressView.progress = receivedSize / (float)expectedSize;
                }
            });
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            weakSelf.progressView.hidden = YES;
            weakSelf.loading = NO;
            if (image) {
                [weakSelf layoutWithImage:image animated:YES];
            } else {
               NSBundle * bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DZPhotoBrowser" ofType:@"bundle"]];
                UIImage * image = [UIImage imageNamed:@"ImageError" inBundle:bundle compatibleWithTraitCollection:nil];
                weakSelf.imageView.image = image;
                [weakSelf layoutWithImage:image animated:YES];
            }
        }];
    }
    // Do any additional setup after loading the view.
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect contentRect = scrollView.bounds;
    contentRect.origin = CGPointMake(0, 0);
    CGSize size = scrollView.contentSize;
    CGSize aimSize = {MAX(size.width, CGRectGetWidth(scrollView.frame)), MAX(size.height, CGRectGetHeight(scrollView.frame))};
    contentRect.size = aimSize;
    _imageView.frame = CGRectCenter(contentRect, size);
}



- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _progressView.frame = CGRectCenter(self.view.bounds, (CGSize){55,55});
    if (_willLayout) {
        _willLayout = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tryRestorUI];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifdef DEBUG
    CGPrintKeyRect(@"Destani Rect", self.imageView.frame);
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _willRestoreUI = YES;
}
- (void) tryRestorUI
{
    if (_willRestoreUI) {
        _scrollView.zoomScale = 1.0f;
        _willRestoreUI= NO;
    }
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
