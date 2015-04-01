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
//        SKAction* S1 = [SKAction playSoundFileNamed:@"dom1.wav" waitForCompletion:NO];

        //[self animate:1];
    }
}

-(void) animate:(double)time{

    int segments = 10;
    double delay = time/segments;

    int texNum = [clsCommon getRanInt:1 maxNumber:5];
    NSString* texName = [NSString stringWithFormat:@"Trail_%i_4",texNum];

    [self setTImage:[SKTexture textureWithImageNamed: texName]];


    for (double i = 1; i <=segments; i++) {
        [self runAction:
            [SKAction sequence:@[
                 [SKAction waitForDuration:i*delay],
                 [SKAction runBlock:^{
                    [self cropImagewithPercent:i/10];
                  }]
             ]]
         ];
    }
}

-(void)cropImagewithPercent:(double)percent{

    [self removeAllChildren];

    SKSpriteNode *pictureToMask = [SKSpriteNode spriteNodeWithTexture: self.tImage];
    pictureToMask.name = @"pm";
    pictureToMask.color = [SKColor blueColor];
    pictureToMask.colorBlendFactor = 1;
    
    pictureToMask.size = dominoSize;
    SKSpriteNode *mask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size: CGSizeMake(dominoSize.width, dominoSize.height*percent)];
    SKCropNode *cropNode = [SKCropNode node];
    [cropNode addChild: pictureToMask];
    [cropNode setMaskNode: mask];
    cropNode.name=@"cn";
    [self addChild: cropNode];
    cropNode.position = CGPointMake( 0,self.size.height - mask.size.height/2);


}


//show image from top down, return image cropped at "percent"
//takes fractional percent - .1= one tenth, .5 = half way down, 1 = full image
- (UIImage*) cropImageFromFullImage:(UIImage*)image withPercent:(double)percent
{
    // Get size of current image
    CGSize size = image.size;

    int myWidth= size.width;
    int myHeight = size.height * percent;

    CGRect newRect;

    newRect= CGRectMake(0, 0, myWidth, myHeight);

    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return img;
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

