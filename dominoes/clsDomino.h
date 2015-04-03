//
//  domino.h
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface clsDomino : SKSpriteNode

//store the trail image
@property SKTexture* tImage;

//@property SKSpriteNode* head; //ref to the trail head

//store the x and y which correspond to grid
@property int direction;

//is this a player domino, or computer
@property BOOL player;

//this is just to make sure that this object can't count score more than once
@property BOOL CountedScore;

//@property NSMutableArray* dominos;

-(void) animate:(double)time;

-(void) fallDown:(NSTimeInterval)delay isPlayer:(BOOL)bPlayer isEnd:(BOOL)bIsEnd;

-(void) explode:(NSTimeInterval)delay;

@end
