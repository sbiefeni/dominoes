//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domMyScene.h"

@interface domMyScene (){
    
    SKSpriteNode* backGround;
    SKSpriteNode* topDoor;
    SKSpriteNode* rightDoor;
    SKSpriteNode* bottomDoor;
    SKSpriteNode* leftDoor;
    
    float scaleX;
    float scaleY;
    
}


@end

@implementation domMyScene


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self setUpBackGround:size];
        
        [self setUpDoors:size];
        
    }
    return self;
}



-(void) setUpBackGround:(CGSize)size{
    
    backGround = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-arena.png"];
    scaleX = backGround.size.width / size.width;
    scaleY = backGround.size.height/size.height;
    
    backGround.size = size;
    backGround.position = CGPointMake(size.width/2, size.height/2);
    
    [self addChild:backGround];
}
-(void) setUpDoors:(CGSize) size{
    
    topDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-topDoor.png"];
    
    CGSize newSize = CGSizeMake(topDoor.size.width / scaleX, topDoor.size.height / scaleY );
    
    NSLog(@"newSize.Width %f, newSize.Height %f", newSize.width, newSize.height);
    

    
    topDoor.position = CGPointMake(size.width /1.740 , size.height - newSize.height);
    
    
    
    topDoor.size= newSize;
    
    [self addChild:topDoor];
    
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
