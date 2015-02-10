//
//  domino.m
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//


#import "clsDomino.h"
#import "clsCommon.h"

@implementation clsDomino


NSMutableArray* dominoFrames;

+ (void)initialize {
    if (self == [clsDomino self]) {

        //this is (confirmed) pre-loading all the sounds.. this only runs once in the game
        //during class initialization. the actions die right after this, but the sounds
        //are loaded and there is no delay the first time a sound plays
        SKAction* S1 = [SKAction playSoundFileNamed:@"dom1.wav" waitForCompletion:NO];
        SKAction* S2 = [SKAction playSoundFileNamed:@"dom2.wav" waitForCompletion:NO];
        SKAction* S3 = [SKAction playSoundFileNamed:@"dom3.wav" waitForCompletion:NO];
        SKAction* S4 = [SKAction playSoundFileNamed:@"dom4.wav" waitForCompletion:NO];
        SKAction* S5 = [SKAction playSoundFileNamed:@"dom5.wav" waitForCompletion:NO];
        SKAction* S6 = [SKAction playSoundFileNamed:@"dom6.wav" waitForCompletion:NO];
        SKAction* S7 = [SKAction playSoundFileNamed:@"dom7.wav" waitForCompletion:NO];
        SKAction* S8 = [SKAction playSoundFileNamed:@"dom8.wav" waitForCompletion:NO];
        SKAction* S9 = [SKAction playSoundFileNamed:@"dom9.wav" waitForCompletion:NO];
        SKAction* SEnd = [SKAction playSoundFileNamed:@"dom-end3.wav" waitForCompletion:NO];


    }
}

-(void) explode:(NSTimeInterval)delay {

//explosion.position = CGPointMake(0, 0);

    int rnd = [clsCommon getRanInt:1 maxNumber:5];
    NSString* which = [@(rnd) stringValue];
    NSString* sound = [NSString stringWithFormat:@"fireworks%@.mp3", which];

    [self runAction:[SKAction sequence:@[
                                [SKAction waitForDuration:delay],
                                [SKAction runBlock:^{
                                    if (soundEnabled){
                                        [self runAction:[SKAction playSoundFileNamed:sound waitForCompletion:NO]];
                                    }
                                }],
                                [SKAction runBlock:^{
                                    levelScore += 1;
                                    _CountedScore = true;
                                    if (levelScore % 3) {
                                        NSString *burstPath =
                                        [[NSBundle mainBundle]
                                         pathForResource:@"explosion_red" ofType:@"sks"];
                                        SKEmitterNode *explosion =
                                        [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
                                        explosion.particleBirthRate = 30;
                                        [self addChild:explosion];

                                        [self runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:.50],
                                            [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],
                                            [SKAction waitForDuration:.05],
                                            [SKAction runBlock:^{[explosion removeFromParent];}],
                                            [SKAction fadeAlphaTo:.1 duration:0]
                                        ]]];
                                    }else{
                                        self.alpha = .1;
                                    }
                                }],

                ]]];
}

-(void) fallDown:(NSTimeInterval)delay isPlayer:(BOOL)bPlayer isEnd:(BOOL)bIsEnd{

    SKTexture* txtr; //= [SKTexture textureWithImageNamed:@"dominoH"];
    SKAction* moveAction = [SKAction new];
    NSString *whichPlayer=(bPlayer)?@"blue":@"green";
    double moveDuration = 0.15;

    switch (_direction) {
    case left:  //domino-green-fallen-d.png
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-r","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 90; // degrees to radians
            moveAction = [SKAction moveByX:5 y:0 duration:moveDuration];
            self.xScale = 1.2;
        break;
    case right:
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-L","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 270;
            moveAction = [SKAction moveByX:-5 y:0 duration:moveDuration];
            self.xScale = 1.2;
        break;
    case up:
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-d","domino",whichPlayer]];
            //rotation = (M_PI / 180) * 180;
            moveAction = [SKAction moveByX:0 y:-5 duration:moveDuration];
            self.yScale = 1.2;
        break;
    case down:
            txtr = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%s-%@-fallen-u","domino",whichPlayer]];
            //rotation = 0;
            moveAction = [SKAction moveByX:0 y:5 duration:moveDuration];
            self.yScale = 1.2;
        break;
    default: ;

    }

    NSString* which = @"";

        //load either the -end sound if it's true, or one of
        //9 random domino falling sounds
        //the end sound is distinct and represents the end of a run
    if (bIsEnd) {
        if (bPlayer) {
            which = @"-clak";
        }else{
            which = @"-end3";
        }
    }else{
        int rnd = [clsCommon getRanInt:1 maxNumber:9];
        which = [@(rnd) stringValue];
    };

    float rotation = [clsCommon getRanFloat:-.1 and:.1];

    NSString* sound = [NSString stringWithFormat:@"dom%@.wav", which];

    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction runBlock:^{
            [self setTexture: txtr];
            if (bPlayer && soundEnabled) {
                [self runAction:[SKAction playSoundFileNamed:sound waitForCompletion:NO]];
            }
            self.zRotation = rotation;
            if ( !(bPlayer || bIsEnd) ) {
                if (bPlayer !=true && _CountedScore != true) {
                    levelScore += 1;
                    _CountedScore = true;
                }
            }
        }],
        [SKAction waitForDuration:.1],
        moveAction,
    ]]];

    self.ZPosition = 25;

    //[clsCommon playSound:@"dom1.wav"];

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

