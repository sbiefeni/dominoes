//
//  domGameSettings.m
//  dominoes
//
//  Created by Stefano on 3/27/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "clsGameSettings.h"

SKSpriteNode* backGround;

BOOL adsShowing;
BOOL bannerIsVisible;
BOOL bannerIsLoaded;

//gamecenter settings
BOOL gcEnabled;

//to get the scale factor for the current screen (orig size / new size)
float scaleX;
float scaleY;


//to store the arena unscaled size
CGSize arenaSize;
//store the scaled size of the arena
CGSize scaledSize;

//this determines the arena scale for displaying an ad banner
float adShowingArenaScaleAmount;

//banner height depends on the screen width, which can only be 320, or 768 (portrait mode)
int bannerSizeY;
float bannerHeightAdjuster;


float gridWidth;
float gridHeight;

CGSize gridSize;
CGSize dominoSize;

double dominoScaleFactorX;   // - 1.25
double dominoScaleFactorY; //

// min/max extents
double minX;
double minY;
double maxX;
double maxY;

//use these to store each movement, in sequence, for each player
NSMutableArray* playerDominos;
NSMutableArray* computerDominos;

clsPlayer* player;
clsPlayer* computer;

//if we are currently calculating player move, use this to ignore swipes
BOOL doingPlayerMove;

//using 0 and 1 instead of BOOL so I can use these in calculations
//not needed?
BOOL ceilingOn;
BOOL floorOn;

BOOL gameCenterEnabled;
BOOL didReportPrevHighScore;
BOOL didReportPrevHighLevelScore;

int sizeDoubler;

// actual game settings..
int score;
int totalScore;
int highScore;
int lives;
int level;

float gameSpeed;


//temp swipe direction
int tmpDirection;



BOOL roundOver;
//BOOL gameStarted;

game_Status gameStatus;

SKLabelNode *scoreLabel;

AVAudioPlayer* backgroundMusic;
AVAudioPlayer* soundFile;


@implementation clsGameSettings

@end
