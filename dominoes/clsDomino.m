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

//-(id) init {
//
//    return self;
//
//}

-(void) fallDown:(NSTimeInterval)delay isPlayer:(BOOL)bPlayer isEnd:(BOOL)bIsEnd{

    SKTexture* txtr; //= [SKTexture textureWithImageNamed:@"dominoH"];
    SKAction* moveAction = [SKAction new];
    NSString *whichPlayer=(bPlayer)?@"blue":@"green";
    //double rotation = 0;

    switch (_direction) {
    case 1:  //left    domino-green-fallen-d.png
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-r","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 90; // degrees to radians
            moveAction = [SKAction moveByX:5 y:0 duration:.15];
            self.xScale = 1.2;
        break;
    case 2:  //right
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-L","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 270;
            moveAction = [SKAction moveByX:-5 y:0 duration:.15];
            self.xScale = 1.2;
        break;
    case 3: //up
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-d","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 180;
            moveAction = [SKAction moveByX:0 y:-5 duration:.15];
            self.yScale = 1.2;
        break;
    case 4: //down
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-u","domino",whichPlayer]];
            //rotation = 0;
            moveAction = [SKAction moveByX:0 y:5 duration:.15];
            self.yScale = 1.2;
        break;
    default: ;

    }

    NSString* which = @"";

        //load either the -end sound if it's true, or one of
        //9 random domino falling sounds
        //the end sound is distinct and represents the end of a run
    if (bIsEnd) {
        which = @"-end";
    }else{
        int rnd = 1 + arc4random() % 9;
        which = [@(rnd) stringValue];
    };

    float rotation = [self randomFloatBetween:-.1 and:.1];

    NSString* sound = [NSString stringWithFormat:@"sounds/dom%@.wav", which];

    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction runBlock:^{
            [self setTexture: txtr];
            self.zRotation = rotation;
            if ( !(bPlayer || bIsEnd) ) {
                score += 1;
            }
        }],
        [SKAction playSoundFileNamed:sound waitForCompletion:NO],
        [SKAction waitForDuration:.1],
        moveAction,
    ]]];

}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


@end

//Have an iVar
//
//SKAction *_ballsHitSound;
//Set it up when load the scene
//
//_ballsHitSound = [SKAction playSoundFileNamed:@"ballsCollide.mp3" waitForCompletion:NO];
//then the sound is ready to go
//
//[self runAction:_ballsHitSound];

