//
//  domGameSettings.h
//  dominoes
//
//  Created by Stefano on 3/27/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "clsPlayer.h"
#import <AVFoundation/AVFoundation.h>
//#import "clsGameSettings.h"

@interface clsGameSettings : NSObject

extern SKSpriteNode* backGround;
extern BOOL adsShowing;

//to get the scale factor for the current screen (orig size / new size)
extern float scaleX;
extern float scaleY;


//to store the arena unscaled size
extern CGSize arenaSize;
//store the scaled size of the arena
extern CGSize scaledSize;

//for scaling arena for ads
extern float adShowingArenaScaleAmount;

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
extern NSMutableArray* playerDominos;
extern NSMutableArray* computerDominos;

extern clsPlayer* player;
extern clsPlayer* computer;

extern BOOL ceilingOn;
extern BOOL floorOn;


//score, lives, levels
extern int score;
extern int totalScore;
extern int lives;
extern int level;
extern float gameSpeed;

// functionality bool to let certain processes know the current round has ended with someone crashing
extern BOOL roundOver;

extern game_Status gameStatus;

extern SKLabelNode* scoreLabel;

extern AVAudioPlayer* backgroundMusic;



@end
