//
//  domMyScene.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>



@interface domGameScene : SKScene
<ADBannerViewDelegate>

//enum the last swipe action
typedef enum  {
    none=   0,
    left=   1,
    up=     2,
    right=  3,
    down=   4,
    none2 = 5
} swipeDirection;

typedef enum    {
    cnone=0,
    clockWise = 1,
    cclockWise = 2,
} uTurnDirection;

typedef enum {
    step1 = 1,
    step2 = 2,
    unone = 3,
} uTurnStep;


@end
