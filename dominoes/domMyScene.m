//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domMyScene.h"

//using 0 and 1 instead of BOOL so I can use these in calculations
#define ceilingOn   1
#define floorOn     0

@interface domMyScene (){
    
    SKSpriteNode* backGround;
    SKSpriteNode* topDoor;
    SKSpriteNode* rightDoor;
    SKSpriteNode* bottomDoor;
    SKSpriteNode* leftDoor;
    
//to get the scale factor for the current screen (orig size / new size)
    float scaleX;
    float scaleY;
    
//banner height depends on the screen width, which can only be 320, or 768 (portrait mode)
    int bannerSizeY;
    float bannerHeightAdjuster;
    
//store the scaled size of the arena
    CGSize scaledSize;
    
    
}


@end

@implementation domMyScene


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self setUpBackGround:size];
        
        [self setUpDoors:size];
        
        
        NSLog(@"Width: %f, Height: %f", size.width, size.height);
    }
    return self;
}


-(void) setUpBackGround:(CGSize)size{

    int bannerCount =0;
    
    //determine the banner size (according to iAD)
    bannerSizeY = (size.width == 320) ? 50 : 66;
    if (ceilingOn + floorOn ==1){
        bannerHeightAdjuster = (ceilingOn) ? -(bannerSizeY/2): +(bannerSizeY/2);
    }
    
    if (floorOn){
        SKSpriteNode* floor = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(size.width, bannerSizeY)];
        floor.position = CGPointMake(size.width/2, (bannerSizeY/2));
        [self addChild:floor];
        bannerCount +=1;
    }
    if (ceilingOn){
        SKSpriteNode* ceiling = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(size.width, bannerSizeY)];
        ceiling.position = CGPointMake(size.width/2, size.height-(bannerSizeY/2));
        [self addChild:ceiling];
        bannerCount +=1;
    }
    
    
    
    backGround = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-arena.png"];
//get the scale factors, so we know how much to scale any other images
    scaleX = backGround.size.width  / size.width;
    scaleY = backGround.size.height / (size.height -(bannerSizeY * bannerCount) );
    
    backGround.size = CGSizeMake(size.width, size.height-(bannerSizeY * bannerCount) );
    
    float backGroundPos = size.height/2 + bannerHeightAdjuster ;

    
    backGround.position = CGPointMake(size.width/2, backGroundPos);
    backGround.zPosition = 5;
    
    [self addChild:backGround];
}

-(void) setUpDoors:(CGSize) size{
    
    int doorZPos = 5;
    
    topDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-topDoor.png"];

    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:topDoor];
    
    topDoor.size= scaledSize;
    topDoor.position = CGPointMake(size.width /1.735 ,size.height - (scaledSize.height/2) - (ceilingOn * bannerSizeY) );
    topDoor.zPosition = doorZPos;
    
    [self addChild:topDoor];
    
    bottomDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-bottomDoor.png"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:bottomDoor];
    bottomDoor.size= scaledSize;
    bottomDoor.position = CGPointMake(size.width /1.735 ,72/scaleY + (floorOn * bannerSizeY) );
    bottomDoor.zPosition = doorZPos;
    [self addChild:bottomDoor];
    
    
    leftDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-leftDoor.png"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:leftDoor];
    leftDoor.size= scaledSize;
    leftDoor.position = CGPointMake(82/scaleX ,size.height/2 + (37/scaleY)+bannerHeightAdjuster);
    leftDoor.zPosition = doorZPos;
    [self addChild:leftDoor];

    rightDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-rightDoor.png"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:rightDoor];
    rightDoor.size= scaledSize;
    rightDoor.position = CGPointMake(size.width - (84/scaleX),size.height/2 + (45/scaleY)+bannerHeightAdjuster);
    rightDoor.zPosition = doorZPos;
    [self addChild:rightDoor];
    
}
-(CGSize) getScaledSizeForNode:(SKSpriteNode*)node{
    return CGSizeMake(node.size.width / scaleX, node.size.height / scaleY );
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
