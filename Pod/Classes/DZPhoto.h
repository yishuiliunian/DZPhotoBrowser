//
// Created by stonedong on 16/12/11.
//

#import <Foundation/Foundation.h>


@interface DZPhoto : NSObject
@property  (nonatomic, strong) UIImage * image;
@property  (nonatomic, strong) NSURL * url;
@property  (nonatomic, strong) UIImage * thumb;
+ (instancetype) photoWithURL:(NSURL *)url;
- (instancetype) initWithURL:(NSURL *)url;
@end