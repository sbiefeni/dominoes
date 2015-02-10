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
extern int lastTile;

extern BOOL adsShowing;
extern BOOL bannerIsVisible;
extern BOOL bannerIsLoaded;

extern int FullAdSceneCount;
extern bool AdShowedLastLevel;

extern int areAdsRemoved;

extern BOOL gcEnabled;

extern BOOL soundEnabled;

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

extern double dominoScaleFactorX;   // - 1.25
extern double dominoScaleFactorY; //

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

extern BOOL doingPlayerMove;



extern BOOL ceilingOn;
extern BOOL floorOn;

extern BOOL gameCenterEnabled;
extern BOOL didReportPrevHighScore;
extern BOOL didReportPrevHighLevelScore;
extern BOOL didReportMaxLevels;

extern int sizeDoubler;


//score, lives, levels
extern int levelScore;
extern int totalScore;
extern int highScore;
extern int maxLevels;
extern int lives;
extern int level;

extern double gameSpeed;


//tmp swipe direction
extern int tmpDirection;

// functionality bool to let certain processes know the current round has ended with someone crashing
extern BOOL roundOver;

extern game_Status gameStatus;

extern SKLabelNode* scoreLabel;

extern AVAudioPlayer* backgroundMusic;
extern AVAudioPlayer* soundFile;

//tap enable bool.. initail delay for the gamecenter
extern BOOL tapEnabled;

@end
