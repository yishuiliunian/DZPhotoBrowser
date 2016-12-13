//
// Created by stonedong on 16/12/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DZPhoto : NSObject
@property  (nonatomic, strong) UIImage * image;
@property  (nonatomic, strong) NSURL * url;
@property  (nonatomic, strong) UIImage * thumb;
@property  (nonatomic, strong) UIImageView* sourceImageView;
+ (instancetype) photoWithURL:(NSURL *)url;
- (instancetype) initWithURL:(NSURL *)url;
@end
