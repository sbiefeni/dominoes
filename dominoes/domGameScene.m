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

//this is used like the VB isRunningInIde()
//usage: isRunningInIde( <statement>; <statement>...)
//apparently NSLog() also stays in the app in production
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

#define notRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location == NSNotFound){x;}


//define z positions for objects
#define dominoZPos      6

//define rows and cols
#define rows        28
#define cols        20

#define _gameSpeed  .25
#define _maxSpeed   .05
#define _gameSpeedIncrement  .02
#define SceneChangeDelay     3


@interface domGameScene (){

    //moved (almost) all variables to domVariables.m

    CFTimeInterval startTime;
    //ADBannerView *adView;
    
    //boolean 2D array, representing our playing grid
    //each value is true if there is a domino placed there
    BOOL grid [cols+1][rows+1];
    BOOL testGrid [cols+1][rows+1];  //to record matches during recursive testing
    
     //player* player1;
     //player* computer;

    
}

@property NSTimeInterval fallingAnimationInterval;
@property NSTimeInterval fallingAnimationDelay;
@property NSTimeInterval fallingAnimationSlowStart;
@property int sceneChangeDelay;

@end


@implementation domGameScene

CGPoint pointA;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

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

    int halfX = cols/2;
    BOOL lowerQuad;
    BOOL leftQuad;

    NSMutableArray* directionChoices = [NSMutableArray new];

    int xPos = [clsCommon getRanInt:1 maxNumber:halfX];
    int yPos = [clsCommon getRanInt:1 maxNumber:rows];

    lowerQuad = (yPos < rows/2);
    leftQuad = (xPos < halfX/2);

    if (lowerQuad) {
        [directionChoices addObject:[NSNumber numberWithInt:up]];
    }else{
        [directionChoices addObject:[NSNumber numberWithInt:down]];
    }
    if (leftQuad) {
        [directionChoices addObject:[NSNumber numberWithInt:right]];
    }else{
        [directionChoices addObject:[NSNumber numberWithInt:left]];
    }

    _player.curX = (comp==TRUE)? xPos + halfX:xPos;
    _player.curY = yPos;

    _player.isPlayer = (comp==false);

    int choice = [clsCommon getRanInt:0 maxNumber:1];
    _player.curDirection = [[directionChoices objectAtIndex:choice] intValue];
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
        lives = 3;
        level = 0;
        gameSpeed = _gameSpeed;

        //isRunningInIde(lives=1)

    // check if social sharing free life applies to this player
        if([[clsCommon getUserSettingForKey:@"socialFreeLife"] isEqualToString:@"yes"]){
            lives=4;
        }

    }

    //if won the last round, speed things up a bit
    BOOL isFaster = false;
    if (score > 0 && gameSpeed > _maxSpeed) { //define max speed
        gameSpeed -= _gameSpeedIncrement;
        isFaster = true;
    }

    score = 0;
    
    level += 1;


    isRunningInIde(
        //gameSpeed = .02;
    )

    // flash some stuff on the screen
    // show level number TODO
    // change level parameters
    // start countdown.. direction arrows
    // start the timer that runs the game!

    [self runAction:
        [SKAction sequence:@[
            [SKAction runBlock:^{
                [self flashingArrowFor:player showFasterMessage:isFaster];
                //[self flashingArrowFor:computer];
            }],
            [SKAction waitForDuration:2],
            [SKAction repeatActionForever:[SKAction sequence:@[
                [SKAction performSelector:@selector(gameRunner) onTarget:self],
                [SKAction waitForDuration:gameSpeed],
            ]]]
        ]]
     ];

}

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
    arrow.alpha = .6;
    arrow.xScale = .7;
    arrow.yScale = .7;

    if (player.isPlayer) {
        arrow.color = [SKColor cyanColor];
    }else{
        arrow.color = [SKColor greenColor];
    }
    arrow.colorBlendFactor = .7;

    [self addChild:arrow];

    ///show "A little bit faster now!" label if
    //faster BOOL is set true
        SKLabelNode *lblFaster = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    if (level == 1){
        lblFaster.text = @"Let's start off slow...";
        lblFaster.fontSize = 30 * sizeDoubler;
    }else{
        lblFaster.text = @"A Little Faster!";
        lblFaster.fontSize = 40 * sizeDoubler;
    }

        lblFaster.alpha = .5;
    //adjust label position if it's on the arrow
    if (player.curY > 12 && player.curY < 18) {
        lblFaster.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+(75 * sizeDoubler) ); //
    }else{
        lblFaster.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
    }

    if (faster || level == 1) {
        [self addChild:lblFaster];
    }


    //show lives remaining
    SKLabelNode *lblLives = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    if (lives > 1) {
        lblLives.text = [NSString stringWithFormat:@"%i Lives Remaining", lives];
    }else{
        lblLives.text = @"Last Life!";
    }

    lblLives.fontSize = 20 * sizeDoubler;
    lblLives.alpha = .7;
    int yAdjust = 200;
    if (ceilingOn) {
        yAdjust = 150;
    }
    lblLives.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ (yAdjust * sizeDoubler) );
    [self addChild:lblLives];

    //add a message to prompt user to get next achievement
    int levelHighScore = [self getLevelHighscore];
    SKLabelNode* achievPrompt = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    int goal = 100;

    //figure out what the next goal level is
    if (levelHighScore < 150) {
        goal = 150;
    }else if (levelHighScore < 200){
        goal = 200;
    }else if (levelHighScore < 225){
        goal = 225;
    }else if (levelHighScore < 250){
        goal = 250;
    }else if (levelHighScore < 275){
        goal = 275;
    }else if (levelHighScore < 300){
        goal = 300;
    }

    achievPrompt.text = [NSString stringWithFormat:@"Get a badge for %i Bricks!",goal];

    achievPrompt.fontSize = 22;
    achievPrompt.alpha = .7;
    achievPrompt.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ (yAdjust * sizeDoubler) - 25 );
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
                [lblFaster removeFromParent];
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

    switch (computer.curDirection) {
        case left:
            if (X > 0 && grid[X-1][Y]==false) {
                computer.curX --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case right:
            if (X < cols && grid[X+1][Y]==false){
                computer.curX ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case up:
            if (Y < rows && grid[X][Y+1]==false){
                computer.curY ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case down:
            if (Y > 0 && grid[X][Y-1]==false){
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
//                domino.color = [SKColor redColor];
//                domino.colorBlendFactor = 5;
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
             pathForResource:@"explosion" ofType:@"sks"];

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
                    NSLog(@"Dominoes: %i",(int)computerDominos.count);
                    for (clsDomino* dom in [computerDominos reverseObjectEnumerator]) {
                            //code to be executed on the main queue after delay
                        [dom fallDown:_fallingAnimationDelay isPlayer:false isEnd:false];

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
                        domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                        [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:1]];
                    }],
                ]]];
        } //end if (player2.didExplosion)
    }

}

//enabling this draws an auto-updating label using 'score' variable
-(void) enableScore{

    score = 0;//temp for debugging

    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    scoreLabel.color = [UIColor whiteColor];
    scoreLabel.fontSize = 120 * sizeDoubler;;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame));

    scoreLabel.zPosition = 100;
    [self addChild:scoreLabel];

    SKAction *tempAction = [SKAction runBlock:^{
        scoreLabel.text = [NSString stringWithFormat:@"%i", score]; //(score+4-1)/4
    }];

    SKAction *waitAction = [SKAction waitForDuration:0.05];

    [scoreLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[tempAction, waitAction]]]];
}

-(void) youLoseMessage{


    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    scoreLabel.color = [UIColor whiteColor];
    scoreLabel.fontSize = 45 * sizeDoubler;;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
    scoreLabel.alpha = .8;
    scoreLabel.zPosition = 100;

    switch ([clsCommon getRanInt:1 maxNumber:5]) {

        case 1  :
            scoreLabel.text = @"You Lose!";
            break;
        case 2  :
            scoreLabel.text = @"You Lose!";
            break;
        case 3  :
            scoreLabel.text = @"You Lose!";
            break;
        case 4  :
            scoreLabel.text = @"You Lose!";
            break;
        case 5  :
            scoreLabel.text = @"You Lose!";
            break;
    }



    [self addChild:scoreLabel];

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
        if (X > 0 && grid[X-1][Y]==false) {
            [directionChoices addObject:[NSNumber numberWithInt:left]];
        }
    }
    if (D != down) {
        if (Y < rows && grid[X][Y+1]==false) {
            [directionChoices addObject:[NSNumber numberWithInt:up]];
        }
    }
    if (D != left) {
        if (X < cols && grid[X+1][Y]==false) {
            [directionChoices addObject:[NSNumber numberWithInt:right]];
        }
    }
    if (D != up) {
        if (Y > 0 && grid[X][Y-1]==false) {
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


    if (roundOver) {
        return;
    }

    doingPlayerMove = true;

    clsDomino* domino =[clsDomino new];
    BOOL crashed = false;
    
//        //get player direction
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    NSNumber *tmpValue;
//    if (standardUserDefaults) {
//        tmpValue = [standardUserDefaults objectForKey:@"playerDirection"];
//    }
//    player.curDirection = [tmpValue intValue];

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
//        domino.color = [SKColor greenColor];
//        domino.colorBlendFactor = .4;


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
        pathForResource:@"explosion" ofType:@"sks"];

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
                //notRunningInIde(
                    domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                      [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
                //);
                }],
            ]]];
        lives -= 1;  //minus one life
    } //end if (player1.crashed)
    
}  //end if (!crashed)

}

-(BOOL)doNextPlayerMove {

    BOOL crashed = false;

    switch (player.curDirection) {
        case left:
            if (player.curX > 0 && grid[player.curX-1][player.curY]==false) {
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
            if (player.curX < cols && grid[player.curX+1][player.curY]==false){
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
            if (player.curY < rows && grid[player.curX][player.curY+1]==false){
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
            if (player.curY > 0 && grid[player.curX][player.curY-1]==false){
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
    float red = [clsCommon getRanFloat:0.0 and:1.0];
    float green = [clsCommon getRanFloat:0.0 and:1.0];
    float blue = [clsCommon getRanFloat:0.0 and:1.0];


    SKColor* color = [SKColor colorWithRed:red green:green blue:blue alpha:1];

    floor.particleColorSequence = nil;
    floor.particleColorBlendFactor = 1.0;

    floor.particleColor = color;



    [backGround addChild:floor];
}

-(void) getBannerHeight{
    bannerSizeY = (arenaSize.width == 320) ? 50 : 56;
}

-(void) setUpBackGround{

    int bannerCount =0;

    //randomize or otherwise have changing arenas

    int rndBackground = [clsCommon getRanInt:1 maxNumber:7];

    //adShowingArenaScaleAmount = 0;
    backGround = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"new-arena%i.png",rndBackground]];

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

    self.backgroundColor = [SKColor blackColor];
    //backGround.colorBlendFactor = 1;


    [self addChild:backGround];
    
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

    if(n  && !testGrid[X][Y+1])
    {
        [self parse_quad_tree:X originY:Y+1];
    }
    if(s && !testGrid[X][Y-1])
    {
        [self parse_quad_tree:X originY:Y-1 ];
    }
    if(e && !testGrid[X-1][Y])
    {
        [self parse_quad_tree:X-1 originY: Y];
    }
    if(w && !testGrid[X+1][Y])
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
