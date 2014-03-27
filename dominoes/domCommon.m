//
//  domVariables.m
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domCommon.h"
//this declaration, along with the extern declaration in the .h file,
//make this a global variable

SKSpriteNode* backGround;
BOOL adsShowing;

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
NSMutableArray* playerDominos;
NSMutableArray* computerDominos;

player* player1;
player* computer;


int score;

SKLabelNode *scoreLabel;

int levels;


AVAudioPlayer* backgroundMusic;

@interface domCommon() {}
@end

@implementation domCommon

+(void) playBackgroundMusicWithVolume:(double)volume{
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      [[NSBundle mainBundle] resourcePath],
                      @"sounds/tick_tock_jingle2.mp3"];
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [backgroundMusic prepareToPlay];
    [backgroundMusic play];
    backgroundMusic.volume = volume;
}

+(void) doBackgroundMusicFadeToQuiet {
    if (backgroundMusic.volume > 0.03) {
        backgroundMusic.volume = backgroundMusic.volume - 0.01;
        [self performSelector:@selector(doBackgroundMusicFadeToQuiet) withObject:nil afterDelay:0.02];
    }else{
        [backgroundMusic stop];
    }
}

+(void) playSound:(NSString*)file {
    NSString* sound = [NSString stringWithFormat:@"sounds/%@", file];
    [SKAction playSoundFileNamed:sound waitForCompletion:NO];
}

+ (float)getRanFloat:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

+ (int)getRanInt:(int)min maxNumber:(int)max
{
    return min + arc4random() % (max - min + 1);
}

@end
