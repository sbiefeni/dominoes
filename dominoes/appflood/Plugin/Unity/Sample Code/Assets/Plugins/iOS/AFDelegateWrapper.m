//
//  AFEventDelegateWrapper.m
//  AppFlood
//
//  Created by Guo Ming on 6/5/13.
//  Copyright (c) 2013 papaya. All rights reserved.
//

#import "AFDelegateWrapper.h"


@implementation AFDelegateWrapper
+  (id<AFRequestDelegate>) getAFRequestDelegate:(const char*) obj callback:(const char*) callback{
    {
        NSString * objObj = [[NSString alloc] initWithCString:obj encoding:NSUTF8StringEncoding];
        NSString * callObj = [[NSString alloc] initWithCString:callback encoding:NSUTF8StringEncoding];
        AFRequestDelegateWrapper * delegate = [[[AFRequestDelegateWrapper alloc] initWithBlock:^(id ret) {
            NSDictionary * dict = [ret retain];
            NSString *r;
            if(!dict){
                r = @"{}";
            }else{
                r = [NSString stringWithFormat:@"%@",dict];
            }
            [dict release];
            const char * message = [r UTF8String];
            const char * ob = [objObj UTF8String];
            const char * call = [callObj UTF8String];
            UnitySendMessage(ob, call, message);
        } ] autorelease];
        
        return delegate;
    }
}

+  (id<AFEventDelegate>) getAFEventDelegate:(const char*) obj1 clickCallback:(const char*) clickCallback obj2:(const char *) obj2 closeCallback:(const char*) closeCallback {
    NSString * obj1Obj = [[NSString alloc] initWithCString:obj1 encoding:NSUTF8StringEncoding];
    NSString * clickObj = [[NSString alloc] initWithCString:clickCallback encoding:NSUTF8StringEncoding];
    
    NSString * obj2Obj = [[NSString alloc] initWithCString:obj2 encoding:NSUTF8StringEncoding];
    NSString * closeObj = [[NSString alloc] initWithCString:closeCallback encoding:NSUTF8StringEncoding];
    AFEventDelegateWrapper *delegateWrapper = [[AFEventDelegateWrapper alloc] initWithBlock:^(int type, NSString *ret){
        const char * message = [ret UTF8String];
        if (type == 0) {
            
            const char * ob = [obj1Obj UTF8String];
            const char * call = [clickObj UTF8String];
            UnitySendMessage(ob, call, message);
        }else{
            
            const char * ob = [obj2Obj UTF8String];
            const char * call = [closeObj UTF8String];
            UnitySendMessage(ob, call, message);
        }
        
    }];
    return delegateWrapper;

}



@end
@implementation AFBannerController
static AFBannerController *instance = nil;
+ (id) getInstance{
    @synchronized (self)
    {
        if (instance == nil)
        {
            instance  = [[self alloc] init];
        }
    }
    return instance;
}
- (void) dealloc
{
    [array release];
    [super dealloc];
}
-(id)init{
    @synchronized(self) {
        [super init];
        array = [[NSMutableArray alloc] init];
        return self;
    }
    
    
}
- (void) showBanner:(int) bannerType layoutType:(int) layoutType{
    UIView * view = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation)){
        
        CGFloat tmp = height;
        height = width;
        width = tmp;
        

        
    }
    int top = 0;
    if(layoutType == 12){
        top = height - 40;
    }
    UIViewController* banner =  [AppFlood newBannerViewController:bannerType isAuto:YES frame:CGRectMake(0, top,width, 40)];

    [array addObject:banner.view];
    [view addSubview:banner.view];

}
- (void) removeBanner{
    if(array){
        int count = [array count];
        for(int i = count -1;i >=0;i --){

            UIView* a = [array objectAtIndex:i];

            [a removeFromSuperview];
            [array removeObject:a];
        }
    }
}

@end

