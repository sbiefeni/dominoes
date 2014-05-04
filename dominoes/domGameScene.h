//
//  domMyScene.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>



@interface domGameScene : SKScene


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

typedef enum {
    reset = 0,
    game_Started = 1,
    game_Over = 2
} game_Status;

typedef enum enmColors : NSUInteger{
    orange=     1,
    yellow=     2,
    Blue=       3,
    purple=     4,
    beige=      5,
    Green=      6,
    honeydew=   7
} enmColors;

@end
