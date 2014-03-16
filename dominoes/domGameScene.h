//
//  domMyScene.h
//  dominoes
//

//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>




@interface domGameScene : SKScene

@property (strong, nonatomic) SKAction *playMySound;

@property float gameSpeed;

//enum the last swipe action
typedef enum  {
    none=   0,
    left=   1,
    right=  2,
    up=     3,
    down=   4,
} swipeDirection;

//-(void) updatePlayerDirection:(swipeDirection)direction;
@end
