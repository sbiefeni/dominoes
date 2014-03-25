//
//  domVariables.m
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domVariables.h"
//this declaration, along with the extern declaration in the .h file,
//make this a global variable

SKSpriteNode* backGround;

//to get the scale factor for the current screen (orig size / new size)
float scaleX;
float scaleY;

//to store the arena unscaled size
CGSize arenaSize;
//store the scaled size of the arena
CGSize scaledSize;

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
//max size is the total available grid squares, so we never run out
//of room
NSMutableArray* playerDominos;
NSMutableArray* computerDominos;

player* player1;
player* computer;



//Set it up when load the scene
//
//_dominoSound = [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:NO];
//then the sound is ready to go
//
//[self runAction:_dominoSound];
SKAction* _dominoSound;

//float gameSpeed;





@interface domVariables() {

    //SKSpriteNode* backGround;


}
@end

@implementation domVariables



@end
