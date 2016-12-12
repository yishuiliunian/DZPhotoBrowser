//
//  DZPhotoBrowser.h
//  YaoHe
//
//  Created by stonedong on 16/12/11.
//
//


#import <UIKit/UIKit.h>
#import "DZPhoto.h"
@interface DZPhotoBrowser : UIViewController
@property  (nonatomic, strong, readonly) NSArray * photos;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithPhotos:(NSArray<DZPhoto*> *)photos;
@end
