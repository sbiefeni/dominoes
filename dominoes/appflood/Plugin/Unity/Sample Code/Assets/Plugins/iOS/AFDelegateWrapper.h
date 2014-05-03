//
//  AFDelegateWrapper.h
//  AppFlood
//
//  Created by Guo Ming on 6/5/13.
//  Copyright (c) 2013 papaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppFlood.h"



@interface AFDelegateWrapper:NSObject
+  (id<AFRequestDelegate>) getAFRequestDelegate:(const char*) obj callback:(const char*) callback;
+  (id<AFEventDelegate>) getAFEventDelegate:(const char*) obj1 clickCallback:(const char*) clickCallback obj2:(const char *) obj2 closeCallback:(const char*) closeCallback ;
@end
@interface AFBannerController : NSObject{
    NSMutableArray *array;
}

+ (id) getInstance;
- (void) showBanner:(int) bannerType layoutType:(int) layoutType;
- (void) removeBanner;

@end

