//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domMyScene.h"

@interface domMyScene (){
    
    SKSpriteNode* background;
    
}


@end

@implementation domMyScene


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self setUpBackGround:size];
        
    }
    return self;
}



-(void) setUpBackGround:(CGSize)size{
    
    background = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-arena.png"];
    background.size = size;
    background.position = CGPointMake(size.width/2, size.height/2);
    
    [self addChild:background];
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
