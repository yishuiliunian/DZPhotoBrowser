//
// Created by stonedong on 16/12/11.
//

#import "DZPhoto.h"
#import "DZPhotoPrivate.h"

@implementation DZPhoto

+ (instancetype)photoWithURL:(NSURL *)url {
    return [[DZPhoto alloc] initWithURL:url];
}
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return self;
    }
    _url = url;
    return self;
}
@end