//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domGameScene.h"
#import "clsPlayer.h"
#import "clsDomino.h"
#import "domViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "domMenuScene.h"

//import Common and Global Variables
#import "clsCommon.h"

#import "wallSeg.h"

//this is used like the VB isRunningInIde()
//usage: isRunningInIde( <statement>; <statement>...)
//apparently NSLog() also stays in the app in production
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

#define notRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location == NSNotFound){x;}

#define ARRAY_SIZE( array ) (sizeof( array ) / sizeof( array[0] ))

#define runAfter(X,After)    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, After * NSEC_PER_SEC), dispatch_get_main_queue(), ^{X});

//define z positions for objects
#define dominoZPos      6
#define wallZpos        7

//define rows and cols
#define rows        28
#define cols        20

#define _gameSpeed  .25
#define _maxSpeed   .05
#define _gameSpeedIncrement  .01
#define SceneChangeDelay     3


@interface domGameScene (){

    //moved (almost) all variables to domVariables.m

    CFTimeInterval startTime;
    
    //boolean 2D array, representing our playing grid
    //each value is true if there is a domino placed there
    BOOL grid [cols+1][rows+1];
    //BOOL wGrid [cols+1][rows+1];
    BOOL testGrid [cols+1][rows+1];  //to record matches during recursive testing

    //NSMutableArray* wallGrid;   //to store wall position intersection pairs

    double wallDrawSpeed;
}

@property NSTimeInterval fallingAnimationInterval;
@property NSTimeInterval fallingAnimationDelay;
@property NSTimeInterval fallingAnimationSlowStart;
@property int sceneChangeDelay;

@property NSMutableArray* wallSegments;

@end


@implementation domGameScene

CGPoint pointA;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        _wallSegments = [[NSMutableArray alloc]init];

        sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

        arenaSize = size;

        [domViewController setAdView:YES ShowOnTop:YES ChooseRandom:YES];

        //NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Insert code from doTaskWithContextData: here

            [self setUpBackGround];
        
            [self setUpDominoGrid];

        //}];

            [self setUpSounds];
        
            [self initializeGame];

            [self setUpBackgroundFloor];



        roundOver = FALSE;

        //NSLog(@"Width: %f, Height: %f", size.width, size.height);

    }
    return self;
}


-(void) setUpSounds {

    [clsCommon doBackgroundMusicFadeToQuiet];

}


-(void) setUpDominoGrid{

//set the width and height of the grid
    gridWidth = maxX - minX;
    gridHeight = maxY - minY;

    dominoScaleFactorX = 1;   // - 1.25
    dominoScaleFactorY = 1;

    if (scaleY < 4) {  //stretched screen
        dominoScaleFactorY = .9;
    }
    
//set the size of the grid and domino
    //pre-scaled should be 64 x 68
    gridSize = CGSizeMake(gridWidth/cols/scaleX, gridHeight/rows/scaleY);
    dominoSize = CGSizeMake((gridWidth/cols)/scaleX*dominoScaleFactorX, (gridHeight/rows)/scaleY*dominoScaleFactorY);

//initialize the grid BOOL to false
    for (int i=0; i<cols+1; i++) {
        for (int ii=0; ii < rows+1; ii++) {
            grid[i][ii]=false;
        }
    }
}

-(void) setUpMinMaxExtents:(CGSize)size{
    minX    =    96;
    minY    =    77;
    maxX    =    1440;
    maxY    =    1971;

    //figure out gridWidth, gridHeight FROM background image size
    //was based on original arena..prob not valid
//    minX = round((size.width * 10.42) / 100);//based on 1536 = 10.42%
//    minY = round((size.height * 7.08) / 100);//based on 2048 =  7.08%
//    maxX = size.width - minX;
//    maxY = size.height - minY;

}

-(void) setRandomStartLocation: (clsPlayer*) _player computer:(BOOL)comp{

    //int halfX = cols/2;
//    BOOL lowerQuad;
//    BOOL leftQuad;

    //NSMutableArray* directionChoices = [NSMutableArray new];

    int xPos = (comp) ? 11 : 10 ;
    int yPos = (comp)? 15 : 14;

//    lowerQuad = (yPos < rows/2);
//    leftQuad = (xPos < halfX/2);

//    if (lowerQuad) {
//        [directionChoices addObject:[NSNumber numberWithInt:up]];
//    }else{
//        [directionChoices addObject:[NSNumber numberWithInt:down]];
//    }
//    if (leftQuad) {
//        [directionChoices addObject:[NSNumber numberWithInt:right]];
//    }else{
//        [directionChoices addObject:[NSNumber numberWithInt:left]];
//    }

    _player.curX = xPos;
    _player.curY = yPos;

    _player.isPlayer = (comp==false);

    //int choice = [clsCommon getRanInt:0 maxNumber:1];
    _player.curDirection = (comp == true)? right : left;
    _player.lastDirection = _player.curDirection;


}

-(void) initializeGame{

    player = [clsPlayer new];
    computer = [clsPlayer new];

    playerDominos=[NSMutableArray new];
    computerDominos=[NSMutableArray new];
    
// set the start position and direction of players
// random start locations
    [self setRandomStartLocation:player computer:FALSE];

    [self setRandomStartLocation:computer computer:TRUE];

//set up params
    if (gameStatus != game_Started) {
        gameStatus = game_Started;
        totalScore = 0;
        maxLevels = 0;
        lives = 3;
        level = 0;
        gameSpeed = _gameSpeed;

        //isRunningInIde(lives=1)

    // check if social sharing free life applies to this player
        if([[clsCommon getUserSettingForKey:@"socialFreeLife"] isEqualToString:@"yes"]){
            lives=4;
        }
    }

    if (levelScore > 0 || level == 0) {
        level += 1;
    }


    //if won the last round, speed things up a bit
//    BOOL isFaster = false;
//    if (levelScore > 0 && gameSpeed > _maxSpeed) { //define max speed
//        if  (level <=3){
//            gameSpeed -= _gameSpeedIncrement*2;
//            isFaster = true;
//        }else{
//            if (level % 2) {
//                gameSpeed -= _gameSpeedIncrement;
//                isFaster = true;
//            }
//        }
//    }


    //reset the level score
    levelScore = 0;

    //set the max amount of levels
    if (level > maxLevels) {
        maxLevels = level;
    }

// action that flashes direction arrows
    SKAction* flashArrows = [SKAction runBlock:^{
        [self flashingArrowFor:player showFasterMessage:false];
        [self flashingArrowFor:computer showFasterMessage:false];
    }];
// timer action that runs the game!
    SKAction* startGame = [SKAction repeatActionForever:[SKAction sequence:@[
                                 [SKAction performSelector:@selector(gameRunner) onTarget:self],
                                 [SKAction waitForDuration:gameSpeed],
                            ]]];

//TODO new startup stuff

    //instructions if first-ish run...
    SKAction* instruct = [SKAction new];
    if([self getLevelHighscore]<30){
        SKSpriteNode* instruct1 = [SKSpriteNode spriteNodeWithImageNamed:@"directions1.gif"];
        SKSpriteNode* instruct2 = [SKSpriteNode spriteNodeWithImageNamed:@"directions2.png"];
        instruct1.xScale = .01; instruct1.yScale = .01;
        instruct2.xScale = .01; instruct2.yScale = .01;
        instruct1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        instruct2.position = instruct1.position;
        instruct1.color = [SKColor blueColor];
        instruct1.colorBlendFactor = 1;
        instruct2.color = instruct1.color;
        instruct2.colorBlendFactor = 1;
        [self addChild:instruct1];
        [self addChild:instruct2];

        SKAction* show =[SKAction sequence:@[ //3 seconds
                                             [SKAction scaleTo:1 duration:.5],
                                             [SKAction waitForDuration:2],
                                             [SKAction scaleTo:.01 duration:.25],
                                             [SKAction removeFromParent]
                                             ]];

        instruct = [SKAction sequence:@[ //6 seconds
                                        [SKAction runBlock:^{[instruct1 runAction:show];}],
                                        [SKAction waitForDuration:3],
                                        [SKAction runBlock:^{[instruct2 runAction:show];}],
                                        [SKAction waitForDuration:3],
                                        [SKAction runBlock:^{
                                            [clsCommon makeCenterScreenLabelWithText:@"You Are Blue" labelName:@"yrb" withFont:nil withSize:40 withColor:[SKColor blueColor] withAlpha:1 fadeOut:YES flash:YES onScene:self position:1  ];
                                        }],
                                        [SKAction waitForDuration:3],
                                    ]];
    }

    // build walls based on level
    SKAction* buildWalls = [SKAction runBlock:^{
        [self buildWallsForLevel:level];
    }];


    [self runAction:
        [SKAction sequence:@[
              instruct,
              buildWalls,
              flashArrows,
              [SKAction waitForDuration:2],
              startGame
        ]]
     ];

}


-(void)buildWallsForLevel:(int)level{

        //X col 10 (20)
        //Y row 14 (28)
        //{X,Y,X1,Y1,Vertical}

    //todo for testing
    gameSpeed = .05;
    //level=4;

    wallDrawSpeed = .05;

//define array matrix seperately for each level
    switch (level) {
        case 1:
            //      |   Vertical split
            //
            //      |
            [self drawWallSectionVfromY:8 ToY:12 X:10 start:true];
            [self drawWallSectionVfromY:16 ToY:20 X:10 start:false];
            break;
        case 2:
            //      |    vertical line
            //      |
            //      |
            //      |
            [self drawWallSectionVfromY:8 ToY:20 X:10 start:true];
            break;
        case 3:
            //      ___   T-Bar
            //       |
            //       |
            //       |
            //       |
            //      ---
            [self drawWallSectionVfromY:10 ToY:17 X:10 start:true];
            //bottom bar
            [self drawWallSectionHfromX:10 ToX:11 Y:9 start:false];
            //top bar
            [self drawWallSectionHfromX:10 ToX:11 Y:17 start:false];
            

            break;
        case 4:
            //   _     _   four corners
            //  |       |

            //  |       |
            //   -     -
            //top left
            [self drawWallSectionVfromY:16 ToY:20 X:4 start:true];
            [self drawWallSectionHfromX:5 ToX:9 Y:20 start:false];
            //top right
            [self drawWallSectionHfromX:12 ToX:16 Y:20 start:false];
            [self drawWallSectionVfromY:20 ToY:16 X:16 start:false];
            //bottom right
            [self drawWallSectionVfromY:13 ToY:9 X:16 start:false];
            [self drawWallSectionHfromX:16 ToX:12 Y:8 start:false];
            //bottom left
            [self drawWallSectionHfromX:9 ToX:5 Y:8 start:false];
            [self drawWallSectionVfromY:9 ToY:13 X:4 start:false];
            break;

        case 5:
            // cross to outside walls
            //left
            [self drawWallSectionHfromX:0 ToX:4 Y:14 start:true];
            //top
            [self drawWallSectionVfromY:28 ToY:24 X:10 start:false];
            //right
            [self drawWallSectionHfromX:20 ToX:16 Y:14 start:false];
            //bottom
            [self drawWallSectionVfromY:0 ToY:4 X:10 start:false];
            break;

        default:
            //large box with top/bottom opening
            [self drawWallSectionVfromY:3 ToY:25 X:2 start:true]; //left
            [self drawWallSectionHfromX:3 ToX:8 Y:25 start:false]; //top
            [self drawWallSectionHfromX:13 ToX:17 Y:25 start:false]; //top
            [self drawWallSectionVfromY:25 ToY:3 X:17 start:false]; //right
            [self drawWallSectionHfromX:17 ToX:13 Y:2 start:false]; //bottom
            [self drawWallSectionHfromX:8 ToX:3 Y:2 start:false]; //bottom



            break;
    }


}
-(void)drawWallSectionVfromY:(int)Y ToY:(int)ToY X:(int)X start:(BOOL)start{

    int inc = (Y < ToY)?1:-1;
    if (inc == 1) {
        for (int i=Y; i<=ToY; i++) {
            [self addWallSegmentg1X:X g1Y:i g2X:X+1 g2Y:i vertical:true start:(i==Y && start)];
        }
    }else{
        for (int i=Y; i>=ToY; i--) {
            [self addWallSegmentg1X:X g1Y:i g2X:X+1 g2Y:i vertical:true start:(i==Y && start)];
        }
    }
}
-(void)drawWallSectionHfromX:(int)X ToX:(int)ToX Y:(int)Y start:(BOOL)start{

    int inc = (X < ToX)?1:-1;
    if (inc == 1) {
        for (int i=X; i<=ToX; i++) {
            [self addWallSegmentg1X:i g1Y:Y g2X:i g2Y:Y+1 vertical:false start:(i==X && start)];
        }
    }else{
        for (int i=X; i>=ToX; i--) {
            [self addWallSegmentg1X:i g1Y:Y g2X:i g2Y:Y+1 vertical:false start:(i==X && start)];
        }
    }
}

-(void)addWallSegmentg1X:(int)g1X g1Y:(int)g1Y g2X:(int)g2X g2Y:(int)g2Y vertical:(BOOL)vertical start:(BOOL)start{

    static double delay;
    if (start) {
        delay = 0;
    }
    delay += wallDrawSpeed;

    wallSeg* wallSegment = [wallSeg new];

    [wallSegment set1X:g1X withg1Y:g1Y withg2X:g2X withg2Y:g2Y withVertical:vertical];
    [_wallSegments addObject:wallSegment];
    [self runAction:[SKAction sequence:@[
                         [SKAction waitForDuration:delay],
                         [SKAction runBlock:^{
                            [wallSegment drawSegmentOnScene:self];
                         }]
                    ]]];
}
//-(void) doWallSegments:(int[12][5])array{
//
//    for (int i=0; i<ARRAY_SIZE(array); i++) {
//        if (array[i][0] > 0 && array[i][0] < 30) {
//            [self addWallSegment:array[i] delay:(double)i/10];
//        }else{
//            break;
//        }
//    }
//
//}
//-(void)addWallSegment:(int[5])array delay:(double)delay{
//
//    wallSeg* wallSegment = [wallSeg new];
//
//    [wallSegment set1X:array[0] withg1Y:array[1] withg2X:array[2] withg2Y:array[3] withVertical:(array[4]==1)];
//
//    [_wallSegments addObject:wallSegment];
//
//    [self runAction:[SKAction sequence:@[
//                                    [SKAction waitForDuration:delay],
//                                    [SKAction runBlock:^{
//                                        [wallSegment drawSegmentOnScene:self];
//                                    }]
//                                ]]];
//
//
//}




//********* Game Runner - is called on interval time 'gameSpeed' from the repeat action above..
-(void) gameRunner {
    if(adsShowing)
    {
        return;
    }
    //computer move
    [self handleComputerMove];

    //player move, 1/2 gameSpeed interval wait time to run it
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:gameSpeed/2],
        [SKAction performSelector:@selector(handlePlayerMove) onTarget:self],
    ]]];
}

-(void) flashingArrowFor:(clsPlayer*)player showFasterMessage:(BOOL)faster{
//flash an arrow for a couple seconds
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"arrow%i",player.curDirection ]];
    arrow.position = [self calcDominoPosition:player.curX withArg2:player.curY];
    arrow.alpha = .1;
    arrow.xScale = .7;
    arrow.yScale = .7;

    if (player.isPlayer) {
        arrow.color = [SKColor blueColor];
    }else{
        arrow.color = [SKColor redColor];
    }
    arrow.colorBlendFactor = .9;

    [self addChild:arrow];

    ///show "A little bit faster now!" label if
    //faster BOOL is set true
       // SKLabelNode *lblFaster = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
//    if (level == 1){
//        lblFaster.text = NSLocalizedString(@"Let's start off slow...",nil);
//        lblFaster.fontSize = 18 * sizeDoubler;
//    }else{
//        lblFaster.text = NSLocalizedString(@"A Little Faster!",nil);
//        lblFaster.fontSize = 18 * sizeDoubler;
//    }

//    lblFaster.color = [SKColor blackColor];
//    lblFaster.colorBlendFactor = 1;
//    lblFaster.alpha = .7;
//    
//    //adjust label position if it's on the arrow
//    if (player.curY > 12 && player.curY < 18) {
//        lblFaster.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+(75 * sizeDoubler) ); //
//    }else{
//        lblFaster.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
//    }
//
//    if (faster || level == 1) {
//        [self addChild:lblFaster];
//    }
//

    //show lives remaining
    SKLabelNode *lblLives = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
    if (lives > 1) {
        lblLives.text = [NSString stringWithFormat:NSLocalizedString(@"%i Lives Remaining",nil), lives];
    }else{
        lblLives.text = NSLocalizedString(@"Last Life!",nil);
    }

    lblLives.fontSize = 25 * sizeDoubler;
    lblLives.alpha = .7;
    lblLives.color = [SKColor blackColor];
    lblLives.colorBlendFactor = 1;

    int yAdjust = 200;
    if (ceilingOn) {
        yAdjust = 150;
    }
    lblLives.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ (yAdjust * sizeDoubler) );
    [self addChild:lblLives];

    //add a message to prompt user to get next achievement
    int levelHighScore = [self getLevelHighscore];
    SKLabelNode* achievPrompt = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
    int goal = 125;

    //figure out what the next goal level is
    if (levelHighScore < 125) {
        goal = 125;
    }else if (levelHighScore < 175){
        goal = 175;
    }else if (levelHighScore < 225){
        goal = 225;
    }else if (levelHighScore < 275){
        goal = 275;
    }else if (levelHighScore < 300){
        goal = 300;
    }

    achievPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"Get a badge for %i Bricks!",nil),goal];

    achievPrompt.fontSize = 15;
    achievPrompt.alpha = .7;
    achievPrompt.color = [SKColor redColor];
    achievPrompt.colorBlendFactor = 1;

    achievPrompt.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ (yAdjust * sizeDoubler) - 35 );
    [self addChild:achievPrompt];

    [self runAction:
       [SKAction sequence:@[
         [SKAction repeatAction:
            [SKAction sequence:@[
                [SKAction runBlock:^{
                    arrow.alpha = .7;
                }],
                [SKAction waitForDuration:.15],
                [SKAction runBlock:^{
                    arrow.alpha = 0;
                }],
                [SKAction waitForDuration:.15],
            ]]
            count:6
          ],
          [SKAction runBlock:^{
                //[lblFaster removeFromParent];
                [lblLives removeFromParent];
                [achievPrompt removeFromParent];
          }],
        ]]
     ];

}

-(int) getLevelHighscore {
    NSString* _score;
    _score = [clsCommon getUserSettingForKey:@"levelHighscore"];
    int value = [_score intValue];
    return value;
}

-(void) handleComputerMove {

    clsDomino* domino; // = [clsDomino new];
    BOOL crashed = false;
    int X = computer.curX;
    int Y = computer.curY;

    //Computer direction should already be set.. default:down

    BOOL crossingWall = [self checkIfCrossingWallWithDirection:computer.curDirection curX:X curY:Y];

    switch (computer.curDirection) {
        case left:
            if (X > 0 && grid[X-1][Y]==false && !crossingWall) {
                computer.curX --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case right:
            if (X < cols && grid[X+1][Y]==false && !crossingWall){
                computer.curX ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case up:
            if (Y < rows && grid[X][Y+1]==false && !crossingWall){
                computer.curY ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case down:
            if (Y > 0 && grid[X][Y-1]==false && !crossingWall){
                computer.curY --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        default:
            break;
    }

    if (!crashed) {
        //draw computer domino
        if(computer.curDirection == up || computer.curDirection==down)
        {
            domino =[clsDomino spriteNodeWithImageNamed:@"dom-green-horizontal.png"];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoHc"];
        }else{
            domino =[clsDomino spriteNodeWithImageNamed:@"dom-green-vertical.png"];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoVc"];
        }
        domino.direction = computer.curDirection;

        domino.size = dominoSize;
        domino.zPosition = dominoZPos;

        //[objectWithOurMethod methodName:int1 withArg2:int2];
        domino.position = [self calcDominoPosition:computer.curX withArg2:computer.curY];

        //temp - highlight when computer is close to a wall
//        isRunningInIde(
//            if (Y==0  || Y==rows || X==0 || X==cols) {
                domino.color = [SKColor colorWithRed:1 green:.2 blue:0 alpha:1];
                domino.colorBlendFactor = 1;
//            }
//        );

        [self addChild:domino];

        //reset explosion so it can happen again..
        computer.didExplosion = false;

        //add to the array so we can track back later
        [computerDominos addObject:domino];

        //add to the grid... for domino colision detection
        grid[computer.curX][computer.curY]=true;

         //add logic to test the next move, and change direction if
        //required, or calculated. Also should make some random function to
        //change direction periodically for no reason
        [self testNextComputerMove];

    }else{
        if (!computer.didExplosion) {

            computer.didExplosion = true;
            if (roundOver) {
                return;
            }

            NSString *burstPath =
            [[NSBundle mainBundle]
             pathForResource:@"explosion_red" ofType:@"sks"];

            SKEmitterNode *explosion =
            [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];

            explosion.position = [self calcDominoPosition:computer.curX withArg2:computer.curY];
            explosion.zPosition = 10;

            [self addChild:explosion];


            roundOver  = TRUE;

            _sceneChangeDelay  = SceneChangeDelay;
            //isRunningInIde(_sceneChangeDelay = 2);
            _fallingAnimationInterval = (NSTimeInterval)_sceneChangeDelay/computerDominos.count;
            if (_fallingAnimationInterval > .1) {
                _fallingAnimationInterval = .1;
            }
            _fallingAnimationSlowStart = .15;


            //crashed = false;
            [self runAction:[SKAction sequence:@[
                  [SKAction playSoundFileNamed:@"sounds/long_ding3.wav" waitForCompletion:NO],
                  [SKAction runBlock:^{
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                   }],
                  [SKAction waitForDuration:.6],
                  [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],

                  [SKAction runBlock:^{
                    _fallingAnimationDelay = 0;
                    [self enableScore];
                    bool gotHighLevel = (computerDominos.count>[self getLevelHighscore]);
                    NSLog(@"Dominoes: %i",(int)computerDominos.count);
                    for (clsDomino* dom in [computerDominos reverseObjectEnumerator]) {
                            //code to be executed on the main queue after delay
                        if(gotHighLevel){
                            [dom explode:_fallingAnimationDelay];
                        }else{
                            [dom fallDown:_fallingAnimationDelay isPlayer:false isEnd:false];
                        }
                        _fallingAnimationDelay += _fallingAnimationSlowStart;
                        if (_fallingAnimationSlowStart > _fallingAnimationInterval) {
                            _fallingAnimationSlowStart -= .02;
                        }else if(_fallingAnimationSlowStart < _fallingAnimationInterval){
                            _fallingAnimationSlowStart = _fallingAnimationInterval;
                        }
                    };
                    clsDomino* lastDom = [computerDominos objectAtIndex: 0];
                    [lastDom fallDown:_fallingAnimationDelay isPlayer:false isEnd:true ];//gets us the end of run 'clack' sound

                  }],

                  [SKAction waitForDuration:.2],
                  [SKAction runBlock:^{ [explosion removeFromParent]; } ],
                  [SKAction waitForDuration:_sceneChangeDelay + 1],
                  [SKAction runBlock:^{
                        [self doRoundIsOver];
                    }],
                ]]];
        } //end if (player2.didExplosion)
    }

}

-(void)doRoundIsOver{
    domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
    [self.view presentScene:menu transition:[SKTransition doorwayWithDuration:1]];
}

//enabling this draws an auto-updating label using 'score' variable
-(void) enableScore{

    levelScore = 0;//temp for debugging

    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Komika Axis"];
    scoreLabel.color = [UIColor whiteColor];
    scoreLabel.fontSize = 120 * sizeDoubler;;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame));

    scoreLabel.zPosition = 100;
    [self addChild:scoreLabel];

    SKAction *tempAction = [SKAction runBlock:^{
        scoreLabel.text = [NSString stringWithFormat:@"%i", levelScore]; //(score+4-1)/4
    }];

    SKAction *waitAction = [SKAction waitForDuration:0.05];

    [scoreLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[tempAction, waitAction]]]];
}

-(void) youLoseMessage{


    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Komika Axis"];
    scoreLabel.color = [UIColor whiteColor];
    scoreLabel.colorBlendFactor = 1;

    //scoreLabel.fontSize = 25 * sizeDoubler;;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
    scoreLabel.alpha = 1;
    scoreLabel.zPosition = 100;

    if (lives > 1){
        switch ([clsCommon getRanInt:1 maxNumber:7]) {

        case 1  :
            scoreLabel.fontSize = 38 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Don't Crash!",nil);
            break;
        case 2  :
            scoreLabel.fontSize = 42 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Watch Out!",nil);
            break;
        case 3  :
            scoreLabel.fontSize = 25 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Remember to turn!",nil);
            break;
        case 4  :
            scoreLabel.fontSize = 38 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Outlast Him!",nil);
            break;
        case 5  :
            scoreLabel.fontSize = 25 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"You can do better!",nil);
            break;
        case 6  :
            scoreLabel.fontSize = 20 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Control the opponent!",nil);
            break;
        case 7  :
            scoreLabel.fontSize = 22 * sizeDoubler;
            scoreLabel.text = NSLocalizedString(@"Contain & Dominate!",nil);
            break;
        }
    }else{
        scoreLabel.fontSize = 40 * sizeDoubler;
        scoreLabel.text = NSLocalizedString(@"Game Over!",nil);
    }


    [self addChild:scoreLabel];

}

-(BOOL)checkIfCrossingWallWithDirection:(int)D curX:(int)X curY:(int)Y{

    int nX;
    int nY;
    BOOL posMatch1stSeg;
    BOOL posMatch2ndSeg;
    BOOL fposMatch1stSeg;
    BOOL fposMatch2ndSeg;

    nX = X;
    nY = Y;

    switch (D) {
        case up:
            nY = Y + 1;
            break;
        case right:
            nX = X + 1;
            break;
        case down:
            nY = Y - 1;
            break;
        case left:
            nX = X - 1;
            break;
        default:
            break;
    }



    for (wallSeg* wallseg in _wallSegments) {

        posMatch1stSeg = (X == wallseg.g1X && Y == wallseg.g1Y);
        posMatch2ndSeg = (X == wallseg.g2X && Y == wallseg.g2Y);
        fposMatch1stSeg = (nX == wallseg.g1X && nY == wallseg.g1Y);
        fposMatch2ndSeg = (nX == wallseg.g2X && nY == wallseg.g2Y);


        if (posMatch1stSeg) { //position matches first wall seg grid
            if (fposMatch2ndSeg){  // and future position matches second wall seggrid
                return true;
            }
        }else{
            if (posMatch2ndSeg) {  //position matches second wall seg grid
                if (fposMatch1stSeg) {//and future position matches first wall seg grid
                    return true;
                }
            }
        }
    }

    return false;
}
-(void) testNextComputerMove{

    //checks if the next move will cause the computer to crash
    //avoid crash if possible
    //also random/or/intelligent course changes to add personality

    NSMutableArray* directionChoices = [NSMutableArray new];
    int X = computer.curX;
    int Y = computer.curY;
    int D = computer.curDirection;
    //don't change path if choices are equal on a unforced 2 choice evaluation
    //BOOL noChange = false;

    //BOOL crossingWall = [self checkIfCrossingWallWithDirection:D curX:X curY:Y];

    //1 in n chance of a random direction change at any time
    int rndChance = 25;

    //increase random chance when computer is close to a wall
    if ((D == left && X < 7) || (D == up && Y > maxY-7) || (D == right && X > maxX-7) || (D == down && Y < 7) || Y==0  || Y==rows || X==0 || X==cols)
        {
            rndChance =2;
        }

//generate a random change BOOL - all direction changes will have 2 possible choices
    BOOL randChange = ([clsCommon getRanInt:1 maxNumber:rndChance]) == 1;

//evaluate all possible directions, for the best one
    if (D != right) {
        if (X > 0 && grid[X-1][Y]==false && ![self checkIfCrossingWallWithDirection:left curX:X curY:Y]) {
            [directionChoices addObject:[NSNumber numberWithInt:left]];
        }
    }
    if (D != down) {
        if (Y < rows && grid[X][Y+1]==false && ![self checkIfCrossingWallWithDirection:up curX:X curY:Y]) {
            [directionChoices addObject:[NSNumber numberWithInt:up]];
        }
    }
    if (D != left) {
        if (X < cols && grid[X+1][Y]==false && ![self checkIfCrossingWallWithDirection:right curX:X curY:Y]) {
            [directionChoices addObject:[NSNumber numberWithInt:right]];
        }
    }
    if (D != up) {
        if (Y > 0 && grid[X][Y-1]==false && ![self checkIfCrossingWallWithDirection:down curX:X curY:Y]) {
            [directionChoices addObject:[NSNumber numberWithInt:down]];
        }
    }

    //check for the best choice.. or if there is no diff then stay the course
    //unless randChange is true
    int choices[5];

    memset(choices, 0, sizeof(choices));

    //get the number of moves in each direction
    for (NSNumber* direction in directionChoices) {
        choices[[direction intValue]] =
        [self checkPath:X  originY:Y direction:[direction intValue]];
    }

    //get the max in the choices array
    int max = [clsCommon maxInArray:choices size:5];

    //now check if any of the choices are better than the other, and
    //if so, change to the best direction.
    [directionChoices removeAllObjects];
    if (max>0) { //otherwise.. there is no choice
        for (int i=1; i<5; i++) {
            if (choices[i] == max) {
                [directionChoices addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    if (directionChoices.count == 0) {
        return;
    }
    if (directionChoices.count == 1) {
        computer.curDirection = [[directionChoices objectAtIndex:0] intValue];
        return;
    }
    //ignore if we are already on a best direction, unless randChange is TRUE
    if (!randChange) {
        for (NSNumber* direction in directionChoices) {
            if (D == [direction intValue] ) {
                return;
            }
        }
    }
    //multiple equal choices, choice is needed, now choose 1
    int choice = [clsCommon getRanInt:0 maxNumber:(int)directionChoices.count-1];
    computer.curDirection = [[directionChoices objectAtIndex:choice] intValue];


}


-(void) handlePlayerMove{

    if (roundOver) { //todo
        return;
    }

    doingPlayerMove = true;

    clsDomino* domino =[clsDomino new];
    BOOL crashed = false;
    
//        //get player direction


    //change the direction if a uTurn was executed
    switch (player.uTurnStep) {
        case step1:
            switch (player.uTurnDirection) {
                case clockWise:
                    player.curDirection += 1;
                    break;
                default:
                    player.curDirection -= 1;
                    break;
            }
            player.uTurnStep = step2;
            break;
        case step2:
            switch (player.uTurnDirection) {
                case clockWise:
                    player.curDirection += 1;
                    break;
                default:
                    player.curDirection -= 1;
                    break;
            }
            player.uTurnStep = unone;
            break;
        default:
            player.uTurnStep = unone;
            break;
    }

    if (player.curDirection < left)
        player.curDirection = down;

    if (player.curDirection > down)
        player.curDirection = left;

    if (player.swipedEarlyDirection !=none && player.swipedEarlyDirection != none2) {
        player.curDirection = player.swipedEarlyDirection;
        player.swipedEarlyDirection = none2;
    }

    crashed = [self doNextPlayerMove];


    if (!crashed) {
        //draw a domino
        if (player.curDirection == up || player.curDirection == down) {
            [domino setTexture:[SKTexture textureWithImageNamed:@"dom-blue-horizontal"]];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoH1"];
        }else {
            [domino setTexture:[SKTexture textureWithImageNamed:@"dom-blue-vertical"]];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoV1"];
        }

        domino.size = dominoSize;
        domino.zPosition = dominoZPos;

        //[objectWithOurMethod methodName:int1 withArg2:int2];
        domino.position = [self calcDominoPosition:player.curX withArg2:player.curY];
        domino.direction=player.curDirection;
        domino.color = [SKColor blueColor];
        domino.colorBlendFactor = 1;


        [self addChild:domino];

        doingPlayerMove = false;

        //reset explosion so it can happen again..
        player.didExplosion = false;

        //add to the array so we can track back later
        [playerDominos addObject:domino];


        //add to the grid... for domino colision detection
        grid[player.curX][player.curY]=true;
        
    //play a sound
        [self runAction: [SKAction playSoundFileNamed:@"sounds/woosh_2.wav" waitForCompletion:NO]];

        
        
}else{  //we crashed!
    if (!player.didExplosion) {
        NSString *burstPath =
        [[NSBundle mainBundle]
        pathForResource:@"explosion2" ofType:@"sks"];

        SKEmitterNode *explosion =
        [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];

        explosion.position = [self calcDominoPosition:player.curX withArg2:player.curY];
        explosion.zPosition = 10;

        [self addChild:explosion];
        player.didExplosion = true;

        //notRunningInIde(
            roundOver = TRUE;
        //);

        _sceneChangeDelay  = SceneChangeDelay;
        _fallingAnimationInterval = (NSTimeInterval)_sceneChangeDelay/playerDominos.count;
        if (_fallingAnimationInterval > .1) {
            _fallingAnimationInterval = .1;
        }
        _fallingAnimationSlowStart = .15;


        [self youLoseMessage];

        [self runAction:[SKAction sequence:@[
            [SKAction playSoundFileNamed:@"sounds/long_ding3.wav" waitForCompletion:NO],
            [SKAction runBlock:^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }],
            [SKAction waitForDuration:.6],
            [SKAction runBlock:^{ explosion.particleBirthRate = 0; } ],

            [SKAction runBlock:^{
                _fallingAnimationDelay = 0;
            //[self enableScore];
            NSLog(@"Dominoes: %i",(int)playerDominos.count);
            for (clsDomino* dom in [playerDominos reverseObjectEnumerator]) {
                    //code to be executed on the main queue after delay
                [dom fallDown:_fallingAnimationDelay isPlayer:true isEnd:false ];
                //[dom explode:_fallingAnimationDelay];

                _fallingAnimationDelay += _fallingAnimationSlowStart;
                if (_fallingAnimationSlowStart > _fallingAnimationInterval) {
                    _fallingAnimationSlowStart -= .02;
                }else if(_fallingAnimationSlowStart < _fallingAnimationInterval){
                    _fallingAnimationSlowStart = _fallingAnimationInterval;
                }
            };
            clsDomino* lastDom = [playerDominos objectAtIndex: 0];
            [lastDom fallDown:_fallingAnimationDelay isPlayer:true isEnd:true ];

            }],

            [SKAction waitForDuration:0.2],
            [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],
            [SKAction waitForDuration:_sceneChangeDelay + 1],
            [SKAction runBlock:^{
                [self doRoundIsOver];
                }],
            ]]];
        lives -= 1;  //minus one life
    } //end if (player1.crashed)
    
}  //end if (!crashed)

}

-(BOOL)doNextPlayerMove {

    BOOL crashed = false;
    BOOL aboutToCrossWall = [self checkIfCrossingWallWithDirection:player.curDirection curX:player.curX curY:player.curY];

    switch (player.curDirection) {
        case left:
            if (player.curX > 0 && grid[player.curX-1][player.curY]==false && !aboutToCrossWall) {
                player.curX --;
                player.lastDirection = player.curDirection;
            }else{
                if (player.curDirection == player.lastDirection) {
                    crashed = true;
                }else{
                    if (player.swipedEarlyDirection !=none2) {
                        player.swipedEarlyDirection = player.curDirection;
                    }else{
                        player.swipedEarlyDirection = none;
                    }
                    player.curDirection = player.lastDirection;
                    crashed = [self doNextPlayerMove];
                }
            }
            break;
        case right:
            if (player.curX < cols && grid[player.curX+1][player.curY]==false && !aboutToCrossWall){
                player.curX ++;
                player.lastDirection = player.curDirection;
            }else{
                if (player.curDirection == player.lastDirection) {
                    crashed = true;
                }else{
                    if (player.swipedEarlyDirection !=none2) {
                        player.swipedEarlyDirection = player.curDirection;
                    }else{
                        player.swipedEarlyDirection = none;
                    }
                    player.curDirection = player.lastDirection;
                    crashed = [self doNextPlayerMove];
                }
            }
            break;
        case up:
            if (player.curY < rows && grid[player.curX][player.curY+1]==false && !aboutToCrossWall){
                player.curY ++;
                player.lastDirection = player.curDirection;
            }else{
                if (player.curDirection == player.lastDirection) {
                    crashed = true;
                }else{
                    if (player.swipedEarlyDirection !=none2) {
                        player.swipedEarlyDirection = player.curDirection;
                    }else{
                        player.swipedEarlyDirection = none;
                    }
                    player.curDirection = player.lastDirection;
                    crashed = [self doNextPlayerMove];
                }
            }

            break;
        case down:
            if (player.curY > 0 && grid[player.curX][player.curY-1]==false && !aboutToCrossWall){
                player.curY --;
                player.lastDirection = player.curDirection;
            }else{
                if (player.curDirection == player.lastDirection) {
                    crashed = true;
                }else{
                    if (player.swipedEarlyDirection !=none2) {
                        player.swipedEarlyDirection = player.curDirection;
                    }else{
                        player.swipedEarlyDirection = none;
                    }
                    player.curDirection = player.lastDirection;
                    crashed = [self doNextPlayerMove];
                }
            }

            break;
        default:
            player.curDirection = player.lastDirection;
            break;
    }

    return crashed;
}

- (CGPoint) calcDominoPosition:(int)x withArg2:(int) y{

    int xPos;
    int yPos;

    //minX = width of wall
    xPos = minX/scaleX + (x * gridSize.width);
    yPos = minY/scaleY + (y * gridSize.height);

    //only have to shift the Y pos if the ad banner is on bottom
    //if not, the y starting location is the same
    if (floorOn) {
        yPos += bannerSizeY;
    }

     //NSLog(@"Domino Placed: X-%i, Y-%i", xPos, yPos);
    
    return CGPointMake(xPos, yPos);
}

-(void) setUpBackgroundFloor{
    NSString *floorPath =
    [[NSBundle mainBundle]
     pathForResource:@"floor1" ofType:@"sks"];

    SKEmitterNode *floor =
    [NSKeyedUnarchiver unarchiveObjectWithFile:floorPath];


    //floor.position = backGround.position;

    floor.zPosition = -1;
    float red = 0;
    float green = .1;
    float blue = 1;


    SKColor* color = [SKColor colorWithRed:red green:green blue:blue alpha:1];

    floor.particleColorSequence = nil;
    floor.particleColorBlendFactor = 1.0;

    floor.particleColor = color;
    floor.alpha = .8;

    floor.name = @"floor";



    [backGround addChild:floor];
}

-(void) getBannerHeight{
    bannerSizeY = (arenaSize.width == 320) ? 50 : 56;
}

-(void) setUpBackGround{

    int bannerCount =0;

    //randomize or otherwise have changing arenas

    //int rndBackground = [clsCommon getRanInt:1 maxNumber:7];

    //adShowingArenaScaleAmount = 0;
    backGround = [SKSpriteNode spriteNodeWithImageNamed:@"new-arena5.png"];

    backGround.color = [SKColor redColor];
    backGround.colorBlendFactor = .8;

    //calculate min and max extents, based on original background size
    [self setUpMinMaxExtents:backGround.size];

    //determine the banner size (according to iAD)
    [self getBannerHeight];  //bannerSizeY = (arenaSize.width == 320)?50:56;

    bannerHeightAdjuster = 0;

    //if only one of the banners is on, then we need an adjuster to center things
    if (ceilingOn + floorOn ==1){
        bannerHeightAdjuster = (ceilingOn) ? -(bannerSizeY/2): +(bannerSizeY/2);
    }

    if (floorOn){
        bannerCount +=1;
    }
    if (ceilingOn){
        bannerCount +=1;
    }


    //get the scale factors, so we know how much to scale any other images
    scaleX = backGround.size.width  / arenaSize.width;
    scaleY = backGround.size.height / (arenaSize.height -(bannerSizeY * bannerCount) );

    backGround.size = CGSizeMake(arenaSize.width, arenaSize.height );

    //fine tune the scale of the background
    if (arenaSize.width == 320){
        if (scaleY > 4.5) {
            adShowingArenaScaleAmount = .895; //for 3.5" iphone
        }else{
        adShowingArenaScaleAmount = .915;  //for 4.0" iphone
        }
    }else{
        adShowingArenaScaleAmount = .955;  //for ipad
    }

    if (bannerCount > 0){
        [backGround setYScale:adShowingArenaScaleAmount];
    }

    float backGroundPos = arenaSize.height/2 + bannerHeightAdjuster ;


    backGround.position = CGPointMake(arenaSize.width/2, backGroundPos);
    backGround.zPosition = 250;


    //pick a random floor tile...but not the same as last
    int rndTile = [clsCommon getRanInt:1 maxNumber:6 butNot:lastTile];
    lastTile = rndTile;
    //[self makeBackgroundFloorSizeOf:backGround withTile:[NSString stringWithFormat:@"floortile%i.png",rndTile]];

    [self addChild:backGround];

    self.backgroundColor = [SKColor lightGrayColor];

}

#pragma mark - Floor Tiles
-(void)makeBackgroundFloorSizeOf:(SKSpriteNode*)area withTile:(NSString*)tileName {
    CGSize coverageSize = area.size; //the size of the entire image you want tiled
    SKSpriteNode* tile = [SKSpriteNode spriteNodeWithImageNamed:tileName];
    CGRect textureSize = tile.frame; //the size of the tile.
    CGImageRef backgroundCGImage = [UIImage imageNamed:tileName].CGImage; //change the string to your image name
    UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
    UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
    SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    backgroundTiles.yScale = -1; //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
    backgroundTiles.position = area.position; // CGPointMake(0,0);
    backgroundTiles.zPosition = 0;
    backgroundTiles.alpha = .5;

    [self addChild:backgroundTiles];
}

//-(void) setUpDoors:(CGSize) size{
//    
//    topDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-topdoor"];
//
//    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
//    scaledSize = [self getScaledSizeForNode:topDoor];
//    
//    topDoor.size= scaledSize;
//    topDoor.position = CGPointMake(size.width /1.735 ,size.height - (scaledSize.height/2) - (ceilingOn * bannerSizeY) );
//    topDoor.zPosition = doorZPos;
//    
//    [self addChild:topDoor];
//    
//    bottomDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-bottomdoor"];
//    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
//    scaledSize = [self getScaledSizeForNode:bottomDoor];
//    bottomDoor.size= scaledSize;
//    bottomDoor.position = CGPointMake(size.width /1.735 ,72/scaleY + (floorOn * bannerSizeY) );
//    bottomDoor.zPosition = doorZPos;
//    [self addChild:bottomDoor];
//    
//    
//    leftDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-leftdoor"];
//    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
//    scaledSize = [self getScaledSizeForNode:leftDoor];
//    leftDoor.size= scaledSize;
//    leftDoor.position = CGPointMake(82/scaleX ,size.height/2 + (37/scaleY)+bannerHeightAdjuster);
//    leftDoor.zPosition = doorZPos;
//    [self addChild:leftDoor];
//
//    rightDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-rightdoor"];
//    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
//    scaledSize = [self getScaledSizeForNode:rightDoor];
//    rightDoor.size= scaledSize;
//    rightDoor.position = CGPointMake(size.width - (84/scaleX),size.height/2 + (45/scaleY)+bannerHeightAdjuster);
//    rightDoor.zPosition = doorZPos;
//    [self addChild:rightDoor];
//    
//}

-(CGSize) getScaledSizeForNode:(SKSpriteNode*)node{
    return CGSizeMake(node.size.width / scaleX, node.size.height / scaleY );
}


//to clear the testgrid before calling this function..outside of this method
//memset(testGrid,false, sizeof(testGrid[0][0]) * rows * cols);
// countsquares needs to be initialized and zeroed before calling this method
int countSquares;
-(void)parse_quad_tree:(bycopy int)X  originY:(bycopy int)Y
{
//[self arrayToString:testGrid];


    countSquares += 1; //count this square

    testGrid[X][Y] = true;  //mark this grid point as checked

    BOOL n = !grid[X][Y+1] && Y < rows ? true : false;
    BOOL s = !grid[X][Y-1] && Y > 0 ? true : false;
    BOOL e = !grid[X-1][Y] && X > 0  ? true : false;
    BOOL w = !grid[X+1][Y] && X < cols ? true : false;

    if(n  && !testGrid[X][Y+1] && ![self checkIfCrossingWallWithDirection:up curX:X curY:Y])
    {
        [self parse_quad_tree:X originY:Y+1];
    }
    if(s && !testGrid[X][Y-1] && ![self checkIfCrossingWallWithDirection:down curX:X curY:Y])
    {
        [self parse_quad_tree:X originY:Y-1 ];
    }
    if(e && !testGrid[X-1][Y] && ![self checkIfCrossingWallWithDirection:left curX:X curY:Y])
    {
        [self parse_quad_tree:X-1 originY: Y];
    }
    if(w && !testGrid[X+1][Y] && ![self checkIfCrossingWallWithDirection:right curX:X curY:Y])
    {
        [self parse_quad_tree:X+1 originY:Y];
    }
   // [self parse_quad_tree:X originY:Y];
}

-(int)checkPath:(bycopy int)X  originY:(bycopy int)Y direction:(int)D {
    switch (D) {
        case up:
            Y += 1;
            break;
        case down:
            Y-= 1;
            break;
        case left:
            X-= 1;
            break;
        case right:
            X+= 1;
            break;

        default:
            break;
    }
    //initialize countSquares, zero the testGrid, and call the parser for X, Y
    countSquares = 0;
    //memset(testGrid,0, sizeof(testGrid[0][0]) * rows * cols);
    //initialize the testGrid BOOL array
    for (int i=0; i<(cols+1); i++) {
        for (int ii=0; ii < (rows+1); ii++) {
            testGrid[i][ii]=false;
        }
    }


    [self parse_quad_tree:X originY:Y];
    return countSquares;

}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    // Get the specific point that was touched
    pointA = [touch locationInView:self.view];
//    NSLog(@"X location: %f", pointA.x);
//    NSLog(@"Y Location: %f",pointA.y);

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}
//-(float)CalcDegrees:(CGPoint) pointB{
//    float Theta;
//    if ( pointB.x - pointA.x == 0 )
//        if ( pointB.y > pointA.y )
//            Theta = 0;
//        else
//            Theta = (float)( M_PI);
//        else
//        {
//            Theta = atan((pointB.y - pointA.y) / (pointB.x - pointA.x));
//            if ( pointB.x > pointA.x )
//                Theta = (float)( M_PI ) / 2.0f - Theta;
//            else
//                Theta = (float)( M_PI ) * 1.5f - Theta;
//        };
//    return Theta * (180/M_PI);
//    
//}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (!doingPlayerMove){  //if currently processing player move, ignore
        UITouch *touch=[touches anyObject];
        CGPoint pointB=[touch locationInView:self.view];
        //determine if not a swipe
        if (abs(pointA.x - pointB.x) < 30 && abs(pointA.y - pointB.y) < 30) {
            //toint touch detected
            [self handlePointTouchWith_X:pointB.x andY:pointB.y];
            return;
        }
    }else{
        NSLog(@"Aborted Touch");
    }

    //now we need to calc the angle difference when touch stops to determine if an angled swipe
    //float angle=[self CalcDegrees:pointB];
    //NSLog(@"Angle is: %f",angle);

    //[self handleAngleSwipe:angle];
}

-(void) handlePointTouchWith_X:(int)Xpos andY:(int)Ypos{

    NSLog(@"X:%i  Y:%i",Xpos,Ypos);

    if (Xpos < arenaSize.width/2) {
        //counterClockwise
        player.uTurnDirection = cclockWise;
        player.uTurnStep = step1;
        [clsCommon playSound:@"sounds/uturn.mp3" withVolume:.3];
    }
    if (Xpos > arenaSize.width/2) {
        //clockwise
        player.uTurnDirection = clockWise;
        player.uTurnStep = step1;
        [clsCommon playSound:@"sounds/uturn.mp3" withVolume:.3];
    }
}

//-(void)handleAngleSwipe:(float) angle{
//    
//    //straight down     =   360/0
//    //straight right    =   90
//    //straight up      =    180
//    //straight left     =   270
//    //straight down     =   360/0
//    
//    //here we need to handle what to do when a swiped angle detected during play
//    if (angle>=15 && angle<=75) {
//        NSLog(@"Angle was down-right");
//    } else if(angle>=105 && angle<=165) {
//        //clockwise
//        player.uTurnDirection = clockWise;
//        player.uTurnStep = step1;
//        NSLog(@"Angle was up-right");
//    } else if (angle>=205 && angle<=255) {
//        NSLog(@"Angle was up-left");
//    } else if (angle>=285 && angle<=345) {
//        NSLog(@"Angle was down-left");
//        //cclockwise
//        player.uTurnDirection = cclockWise;
//        player.uTurnStep = step1;
//
//    }
//}

//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//    //get elapsed time
//    CFTimeInterval elapsedTime=CACurrentMediaTime()-startTime;
//    
//    if(elapsedTime>5)
//    {
//        if(adView==NULL)
//        {
//            
//            adView=[[ADBannerView alloc] initWithFrame];
//           
//            adView.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin;
//            [self.view addSubview:adView];
//        }
//        
//    }
//
//}


// This was to visualize the grid array
//- (void)arrayToString:(bool [cols][rows])array
//{
//    NSString *arrayOutputString = [NSString stringWithFormat:@"\n["];
//
//    for (int y=rows;y>=0;y--) {
//        for (int x=0;x<=cols;x++) {
//            if (x<cols) {
//                if (array[x][y]==true) {
//                    arrayOutputString = [NSString stringWithFormat:@"%@%@-",arrayOutputString,@"X"];
//                }
//                else {
//                    arrayOutputString = [NSString stringWithFormat:@"%@%@-",arrayOutputString,@"0"];
//                }
//            }
//            else if (x==cols) {
//                if (array[x][y]==true) {
//                    arrayOutputString = [NSString stringWithFormat:@"%@%@]\n",arrayOutputString,@"X"];
//                }
//                else {
//                    arrayOutputString = [NSString stringWithFormat:@"%@%@]\n",arrayOutputString,@"0"];
//                }
//            }
//        }
//
//        if (y!=rows) {
//            arrayOutputString = [NSString stringWithFormat:@"%@[",arrayOutputString];
//        }
//    }
//    NSLog(@"%@",arrayOutputString);
//}

@end
