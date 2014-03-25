//
//  domVariables.h
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "player.h"

@interface domVariables : NSObject

  //extern SKSpriteNode* test;
  extern SKSpriteNode* backGround;

//to get the scale factor for the current screen (orig size / new size)
extern float scaleX;
extern float scaleY;


//to store the arena unscaled size
extern CGSize arenaSize;
//store the scaled size of the arena
extern CGSize scaledSize;

//banner height depends on the screen width, which can only be 320, or 768 (portrait mode)
extern int bannerSizeY;
extern float bannerHeightAdjuster;


extern float gridWidth;
extern float gridHeight;

extern CGSize gridSize;
extern CGSize dominoSize;

// min/max extents
extern double minX;
extern double minY;
extern double maxX;
extern double maxY;

//use these to store each movement, in sequence, for each player
//max size is the total available grid squares, so we never run out
//of room
extern NSMutableArray* playerDominos;
extern NSMutableArray* computerDominos;

extern player* player1;
extern player* computer;

extern SKAction* _dominoSound;

//extern float gameSpeed;








@end
