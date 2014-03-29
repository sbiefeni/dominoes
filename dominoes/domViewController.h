//
//  domViewController.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>


@interface domViewController : UIViewController <ADBannerViewDelegate>

+(void)setAdView:(BOOL)showAd ShowOnTop:(BOOL)onTop;

@end
