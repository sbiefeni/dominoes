//
//  domMyScene.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface domMyScene : SKScene

//store the last swipe action
typedef enum  {
    left,
    right,
    up,
    down,
} swipeDirection;

@end
