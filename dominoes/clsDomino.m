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


- (void) animateDomino
{
    //This is our general runAction method to make our flappy bird fly.
    [self runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:dominoFrames
                                             timePerFrame:0.15f
                                                   resize:NO
                                                  restore:YES]] withKey:@"flyingFlappyBird"];
    return;
}


- (void)initializeBird
{
    NSMutableArray *flappyBirdFrames = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        NSString* textureName = nil;
        switch (i)
        {
            case 0:
            {
                textureName = @"Yellow_Bird_Wing_Up";
                break;
            }
            case 1:
            {
                textureName = @"Yellow_Bird_Wing_Straight";
                break;
            }
            case 2:
            {
                textureName = @"Yellow_Bird_Wing_Down";
                break;
            }
            default:
                break;
        }

        SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
        [flappyBirdFrames addObject:texture];
    }
    //[self setFlappyBirdFrames:flappyBirdFrames];
}

@end
