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


-(void) fallDown:(double)delay{

    SKTexture* txtr; //= [SKTexture textureWithImageNamed:@"dominoH"];

    switch (_direction) {
    case 1:  //left
            txtr = [SKTexture textureWithImageNamed:@"dominosC-R"];
        break;
    case 2:  //right
            txtr = [SKTexture textureWithImageNamed:@"dominosC-L"];
        break;
    case 3: //up
            txtr = [SKTexture textureWithImageNamed:@"dominosC-D"];
        break;
    case 4: //down
            txtr = [SKTexture textureWithImageNamed:@"dominosC-U"];
        break;
    default: ;

    }

    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction runBlock:^{
            [self setTexture: txtr];
        }]
    ]]];
}

//- (void) animateDomino
//{
//    //This is our general runAction method to make our flappy bird fly.
//    [self runAction:[SKAction repeatActionForever:
//                            [SKAction animateWithTextures:dominoFrames
//                                             timePerFrame:0.15f
//                                                   resize:NO
//                                                  restore:YES]] withKey:@"flyingFlappyBird"];
//    return;
//}
//
//
//- (void)initializeBird
//{
//    NSMutableArray *flappyBirdFrames = [NSMutableArray array];
//    for (int i = 0; i < 3; i++)
//    {
//        NSString* textureName = nil;
//        switch (i)
//        {
//            case 0:
//            {
//                textureName = @"Yellow_Bird_Wing_Up";
//                break;
//            }
//            case 1:
//            {
//                textureName = @"Yellow_Bird_Wing_Straight";
//                break;
//            }
//            case 2:
//            {
//                textureName = @"Yellow_Bird_Wing_Down";
//                break;
//            }
//            default:
//                break;
//        }
//
//        SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
//        [flappyBirdFrames addObject:texture];
//    }
//    //[self setFlappyBirdFrames:flappyBirdFrames];
//}

@end
