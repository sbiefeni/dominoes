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

//using 0 and 1 instead of BOOL so I can use these in calculations
//not needed?
BOOL ceilingOn;
BOOL floorOn;     


int score;
int totalScore;
int lives;
int levels;

BOOL roundOver;

SKLabelNode *scoreLabel;

AVAudioPlayer* backgroundMusic;



@implementation clsGameSettings

@end
