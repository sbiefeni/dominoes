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


-(void) fallDown:(NSTimeInterval)delay isPlayer:(BOOL)bPlayer{

    SKTexture* txtr; //= [SKTexture textureWithImageNamed:@"dominoH"];
    SKAction* moveAction;
    NSString *whichPlayer=(bPlayer)?@"P":@"C";
    double rotation = 0;

    switch (_direction) {
    case 1:  //left
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s%@","dominos",whichPlayer]];
            rotation = (M_PI / 180) * 90; // degrees to radians
            moveAction = [SKAction moveByX:5 y:0 duration:.15];
        break;
    case 2:  //right
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s%@","dominos",whichPlayer]];
            rotation = (M_PI / 180) * 270;
            moveAction = [SKAction moveByX:-5 y:0 duration:.15];
        break;
    case 3: //up
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s%@","dominos",whichPlayer]];
            rotation = (M_PI / 180) * 180;
            moveAction = [SKAction moveByX:0 y:-5 duration:.15];
        break;
    case 4: //down
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s%@","dominos",whichPlayer]];
            //rotation = 0;
            moveAction = [SKAction moveByX:0 y:5 duration:.15];
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
        moveAction,
    ]]];
}

@end
