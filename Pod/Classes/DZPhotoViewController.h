//
//  DZPhotoViewController.h
//  YaoHe
//
//  Created by stonedong on 16/12/11.
//
//


@class DZPhoto;
@interface DZPhotoViewController : UIViewController
@property  (nonatomic, strong, readonly) UIScrollView * scrollView;
@property  (nonatomic, strong, readonly) UIImageView * imageView;
@property  (nonatomic, strong, readonly) DZPhoto * photo;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithPhoto:(DZPhoto *)photo;
@end
