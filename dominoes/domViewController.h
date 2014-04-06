//
//  domViewController.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>

@interface domViewController : UIViewController <GKGameCenterControllerDelegate>

+(void)setAdView:(BOOL)showAd ShowOnTop:(BOOL)onTop ChooseRandom:(BOOL)useRandom;
-(void)showGameCenter;

@end
