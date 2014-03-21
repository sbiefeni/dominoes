//
//  domino.m
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//


#import "clsDomino.h"



@implementation clsDomino


NSMutableArray* dominoFrames;


-(void) fallDown:(double)delay isPlayer:(BOOL)bPlayer{

    SKTexture* txtr = [SKTexture textureWithImageNamed:@"dominosC-U"];
    SKAction* moveAction;
    double rotation = 0;

    switch (_direction) {
    case 1:  //left
            rotation = (M_PI / 180) * 90; // degrees to radians
            moveAction = [SKAction moveByX:5 y:0 duration:.3];
        break;
    case 2:  //right
            rotation = (M_PI / 180) * 270;
            moveAction = [SKAction moveByX:-5 y:0 duration:.3];
        break;
    case 3: //up
            rotation = (M_PI / 180) * 180;
            moveAction = [SKAction moveByX:0 y:-5 duration:.3];
        break;
    case 4: //down
            //rotation = 0;
            moveAction = [SKAction moveByX:0 y:5 duration:.3];
        break;
    default: ;

    }


    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction runBlock:^{
            [self setTexture: txtr];
            self.zRotation = rotation;
        }],
        [SKAction waitForDuration:.1],
        moveAction
    ]]];
}

@end
