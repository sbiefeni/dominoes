//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domGameScene.h"
#import "player.h"
#import "clsDomino.h"
//#import "domVariablesAndFunctions.h"
#import <AudioToolbox/AudioServices.h>
#import "domMenuScene.h"

//this is used like the VB isRunningInIde()
//usage: isRunningInIde( <statement>; <statement>...)
//apparently NSLog() also stays in the app in production
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

//using 0 and 1 instead of BOOL so I can use these in calculations
//not needed?
#define ceilingOn   0
#define floorOn     0

//define z positions for objects
#define doorZPos    5
#define dominoZPos  6

//define rows and cols
#define rows        26
#define cols        19
//scale up the domino size relative to the grid
#define dominoScaleFactorX 1   // - 1.25
#define dominoScaleFactorY 1 //

@interface domGameScene (){

    SKSpriteNode* backGround;
    SKSpriteNode* topDoor;
    SKSpriteNode* rightDoor;
    SKSpriteNode* bottomDoor;
    SKSpriteNode* leftDoor;

    //to hold animation arrays
    NSArray *_DominoFallingLeft;
    NSArray *_DominoFallingUp;
    NSArray *_DominoFallingRight;
    NSArray *_DominoFallingDown;

    //dominoes
    SKSpriteNode* dominoH;
    SKSpriteNode* dominoV;
    CFTimeInterval startTime;
    //ADBannerView *adView;
    
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
    
//boolean 2D array, representing our playing grid
//each value is true if there is a domino placed there
    BOOL grid [cols+1][rows+1];
    BOOL testGrid [cols+1][rows+1];  //to record matches during recursive testing
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

    
// set game speed
   // float gameSpeed

}
@end

@implementation domGameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        //@autoreleasepool {

        arenaSize = size;
        
        [self setUpBackGround];
        
        [self setUpDoors:size];
        
        [self setUpDominoGrid];
        
        [self initializeGame];

        //}
        //NSLog(@"Width: %f, Height: %f", size.width, size.height);
    }
    //get starting time
    startTime=CACurrentMediaTime();
    return self;
}

-(void) setUpDominoGrid{

//set the width and height of the grid
    gridWidth = maxX - minX;
    gridHeight = maxY - minY;
    
//set the size of the grid and dominoes
    gridSize = CGSizeMake(gridWidth/cols/scaleX, gridHeight/rows/scaleY);
    dominoSize = CGSizeMake((gridWidth/cols)/scaleX*dominoScaleFactorX, (gridHeight/rows)/scaleY*dominoScaleFactorY);

//initialize the grid BOOL to false
    for (int i=0; i<(cols+1); i++) {
        for (int ii=0; ii < (rows+1); ii++) {
            grid[i][ii]=false;
        }
    }
}

-(void) setUpMinMaxExtents:(CGSize)size{
//    minX    =    160;  //based on 1536 = 10.42%
//    minY    =    145;  //based on 2048 =  7.08%
//    maxX    =    1376;
//    maxY    =    1903;

    //TODO figure out gridWidth, gridHeight FROM background image size
    minX = round((size.width * 10.42) / 100);
    minY = round((size.height * 7.08) / 100);
    maxX = size.width - minX;
    maxY = size.height - minY;

}
-(void) initializeGame{

    player1 = [player new];
    computer = [player new];

    playerDominos=[NSMutableArray new ];
    computerDominos=[NSMutableArray new];
    
//set the start position and direction of players
    player1.curX = cols/2 - 1;
    player1.curY = rows/2 -1;
    player1.curDirection = up;

    computer.curX = cols/2 +1;
    computer.curY = rows/2 +1;
    computer.curDirection = down;

//set the speed interval between moves (time for both player and computer to complete one move)
    if (_gameSpeed == 0 ) {
        _gameSpeed = .5;
    }
    
//set initial player1 direction - ***HACK? - NSUserDefaults lets us easily communicate variables between classes.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInt:3] forKey:@"playerDirection"];
        [standardUserDefaults synchronize];
    }

//start the timer that runs the game!
    __weak typeof(self) weakSelf = self;
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(gameRunner) onTarget:weakSelf],[SKAction waitForDuration:_gameSpeed]]]]];

}

//********* Game Runner - is called on interval time 'gameSpeed' from the repeat action above..
-(void) gameRunner {

//player move
    [self handlePlayerMove];

//computer move, 1/2 of gameSpeed interval wait time to run it
    __weak typeof(self) weakSelf = self;
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:_gameSpeed/2],
        [SKAction performSelector:@selector(handleComputerMove) onTarget:weakSelf],
    ]]];
}

-(void) handleComputerMove {

    clsDomino* domino = [clsDomino new];
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
            [domino setTexture:[SKTexture textureWithImageNamed:@"dominoHc"]];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoHc"];
        }else{
            [domino setTexture:[SKTexture textureWithImageNamed:@"dominoVc"]];
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
        [self checkNextComputerMove];

        //play a sound
        //[self runAction: [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:NO]];
    }else{
        if (!computer.didExplosion) {
            NSString *burstPath =
            [[NSBundle mainBundle]
             pathForResource:@"explosion" ofType:@"sks"];

            SKEmitterNode *explosion =
            [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];

            explosion.position = [self calcDominoPosition:computer.curX withArg2:computer.curY];
            explosion.zPosition = 10;

            [self addChild:explosion];
            computer.didExplosion = true;

            _sceneChangeDelay  = 3;
            _fallingAnimationInterval = (NSTimeInterval)_sceneChangeDelay/computerDominos.count;

            crashed = false;
            [self runAction:[SKAction sequence:@[
                  //[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO],
//                  [SKAction runBlock:^{
//                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//                   }],
                  [SKAction waitForDuration:.6],
                  [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],
                  [SKAction waitForDuration:1.2],
                  [SKAction runBlock:^{ [explosion removeFromParent]; } ],
                  [SKAction runBlock:^{
                    _fallingAnimationDelay = _fallingAnimationInterval;
                    for (clsDomino* dom in [computerDominos reverseObjectEnumerator]) {
                            //code to be executed on the main queue after delay
                        _fallingAnimationDelay += _fallingAnimationInterval;
                        [dom fallDown:_fallingAnimationDelay isPlayer:false];
                    };
                  }],
                  [SKAction waitForDuration:_sceneChangeDelay + 3],
                  [SKAction runBlock:^{
                        domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                        [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:1]];
                    }],
                  //[SKAction waitForDuration:1.2],

                ]]];
//            domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
//            [self.view presentScene:menu transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];

        } //end if (player2.didExplosion)
    }

}
int rndIncreases;
-(void) checkNextComputerMove{

    //checks if the next move will cause the computer to crash
    //avoid crash if possible
    //also random/or/intelligent course changes to add personality

    NSMutableArray* directionChoices = [NSMutableArray new];
    int X = computer.curX;
    int Y = computer.curY;
    int D = computer.curDirection;

    //1 in n chance of a random direction change at any time
    int rndChance = 50;

    //increase random chance when computer is close to a wall
    if ((D == left && X < 4) || (D == up && Y > maxY-4) || (D == right && X > maxX-4) || (D == down && Y < 4) || Y==0  || Y==rows || X==0 || X==cols){
        rndChance /=6;
        rndIncreases++;
        //isRunningInIde( NSLog(@"Random chance increased %i times", rndIncreases) );
    }

//generate a random change BOOL - all direction changes will have 2 possible choices
    BOOL randChange = ( arc4random() % rndChance) == 2;

//if any of these conditions are true.. player2 is about to crash..
    switch (D) {
        case left:
            if (X == 0 || grid[X-1][Y]==true || randChange) {
                if (grid[X][Y-1] == false && Y > 0) {
                    [directionChoices addObject:[NSNumber numberWithInt:down]];
                }
                if (grid[X][Y+1] == false && Y < rows) {
                    [directionChoices addObject:[NSNumber numberWithInt:up]];
                }
            }
            break;
        case right:
            if (X == cols || grid[X+1][Y]==true || randChange) {
                if (grid[X][Y-1] == false && Y > 0) {
                    [directionChoices addObject:[NSNumber numberWithInt:down]];
                }
                if (grid[X][Y+1] == false && Y < rows) {
                    [directionChoices addObject:[NSNumber numberWithInt:up]];
                }
            }
            break;
        case up:
            if (Y == rows || grid[X][Y+1]==true || randChange) {
                if (grid[X-1][Y] == false && X > 0) {
                    [directionChoices addObject:[NSNumber numberWithInt:left]];
                }
                if (grid[X+1][Y] == false && X < cols) {
                    [directionChoices addObject:[NSNumber numberWithInt:right]];
                }
            }
            break;
        case down:
            if (Y == 0 || grid[X][Y-1]==true || randChange) {
                if (grid[X-1][Y] == false && X > 0) {
                    [directionChoices addObject:[NSNumber numberWithInt:left]];
                }
                if (grid[X+1][Y] == false && X < cols) {
                    [directionChoices addObject:[NSNumber numberWithInt:right]];
                }
            }

            break;
        default:
            break;
    }

    //check how many choices we have, and change direction if we can
    if ([directionChoices count] ==2) {
        int C1; int C2;
        //2 choices.. call a parser to see which is the best choice
         C1 = [self checkPath:X  originY:Y direction:[[directionChoices objectAtIndex:0]intValue] ];
         C2 = [self checkPath:X  originY:Y direction:[[directionChoices objectAtIndex:1]intValue]];

        if (C1 > C2) {
            computer.curDirection = [[directionChoices objectAtIndex:0] intValue];
        }else if (C2 > C1){
            computer.curDirection = [[directionChoices objectAtIndex:1] intValue];
        }else{
            //randomize this choice between index 0 or 1
            int choice;
            choice = ( arc4random() % 2);
            computer.curDirection = [[directionChoices objectAtIndex:choice] intValue];
        }
    }else if([directionChoices count] == 1){
        computer.curDirection = [[directionChoices objectAtIndex:0]intValue];
    }


}

-(void) handlePlayerMove{

    clsDomino* domino =[clsDomino new];
    BOOL crashed = false;
    
        //get player direction
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *tmpValue;
    if (standardUserDefaults) {
        tmpValue = [standardUserDefaults objectForKey:@"playerDirection"];
    }
    player1.curDirection = [tmpValue intValue];

    switch (player1.curDirection) {
        case left:
            if (player1.curX > 0 && grid[player1.curX-1][player1.curY]==false) {
                player1.curX --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case right:
            if (player1.curX < cols && grid[player1.curX+1][player1.curY]==false){
                player1.curX ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case up:
            if (player1.curY < rows && grid[player1.curX][player1.curY+1]==false){
                player1.curY ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case down:
            if (player1.curY > 0 && grid[player1.curX][player1.curY-1]==false){
                player1.curY --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        default:
            break;
    }

    if (!crashed) {
        //draw a domino
        if (player1.curDirection == up || player1.curDirection == down) {
            [domino setTexture:[SKTexture textureWithImageNamed:@"dominoH1"]];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoH1"];
        }else {
            [domino setTexture:[SKTexture textureWithImageNamed:@"dominoV1"]];
            //domino = [clsDomino spriteNodeWithImageNamed:@"dominoV1"];
        }

        domino.size = dominoSize;
        domino.zPosition = dominoZPos;

        //[objectWithOurMethod methodName:int1 withArg2:int2];
        domino.position = [self calcDominoPosition:player1.curX withArg2:player1.curY];
        domino.direction=player1.curDirection;
//        domino.color = [SKColor greenColor];
//        domino.colorBlendFactor = .4;


        [self addChild:domino];

        //reset explosion so it can happen again..
        player1.didExplosion = false;

        //add to the array so we can track back later
        [playerDominos addObject:domino];

        //add to the grid... for domino colision detection
        grid[player1.curX][player1.curY]=true;
        
    //play a sound
    //[self runAction: [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:NO]];
        
}else{  //we crashed!
    if (!player1.didExplosion) {
        NSString *burstPath =
        [[NSBundle mainBundle]
        pathForResource:@"explosion" ofType:@"sks"];

            SKEmitterNode *explosion =
            [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];

            explosion.position = [self calcDominoPosition:player1.curX withArg2:player1.curY];
            explosion.zPosition = 10;

            [self addChild:explosion];
            player1.didExplosion = true;
        _sceneChangeDelay  = 3;
_fallingAnimationInterval = (NSTimeInterval)_sceneChangeDelay/computerDominos.count;
            crashed = false;
        __weak typeof(self) weakSelf = self;
        [weakSelf runAction:[SKAction sequence:@[
                //[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO],
//                [SKAction runBlock:^{
//                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//                }],
                [SKAction waitForDuration:0.6],
                [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],
                [SKAction waitForDuration:1.2],
                [SKAction runBlock:^{ [explosion removeFromParent]; } ],
                [SKAction runBlock:^{
                    _fallingAnimationDelay = _fallingAnimationInterval;
                    for (clsDomino* dom in [playerDominos reverseObjectEnumerator]) {
                            //code to be executed on the main queue after delay
                        _fallingAnimationDelay += _fallingAnimationInterval;
                        [dom fallDown:_fallingAnimationDelay isPlayer:true];
                    };
                }],

                //[SKAction runBlock:^{
                        //ORBMenuScene *menu = [[ORBMenuScene alloc] initWithSize:self.size];
                          //[self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
                ]]];


    } //end if (player1.crashed)
    
}  //end if (!crashed)

}

- (CGPoint) calcDominoPosition:(int)x withArg2:(int) y{
    
    int xPos;
    int yPos;
    
    //minX = width of wall
    xPos = minX/scaleX + (x * gridSize.width);
    yPos = minY/scaleY + (y * gridSize.height);

    if (floorOn) {
        yPos += bannerSizeY;
    }

     //NSLog(@"Domino Placed: X-%i, Y-%i", xPos, yPos);
    
    return CGPointMake(xPos, yPos);
}

-(void) setUpBackGround{

    int bannerCount =0;
    
    
    //determine the banner size (according to iAD)
    bannerSizeY = (arenaSize.width == 320) ? 50 : 66;
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

    
    
    backGround = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-arenab"];

    //calculate min and max extents, based on original background size
    [self setUpMinMaxExtents:backGround.size];

//get the scale factors, so we know how much to scale any other images
    scaleX = backGround.size.width  / arenaSize.width;
    scaleY = backGround.size.height / (arenaSize.height -(bannerSizeY * bannerCount) );
    
    backGround.size = CGSizeMake(arenaSize.width, arenaSize.height-(bannerSizeY * bannerCount) );
    
    float backGroundPos = arenaSize.height/2 + bannerHeightAdjuster ;

    
    backGround.position = CGPointMake(arenaSize.width/2, backGroundPos);
    backGround.zPosition = 1;

            backGround.color = [SKColor blackColor];
            backGround.colorBlendFactor = .2;

    
    [self addChild:backGround];

    
}

-(void) setUpDoors:(CGSize) size{
    
    topDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-topdoor"];

    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:topDoor];
    
    topDoor.size= scaledSize;
    topDoor.position = CGPointMake(size.width /1.735 ,size.height - (scaledSize.height/2) - (ceilingOn * bannerSizeY) );
    topDoor.zPosition = doorZPos;
    
    [self addChild:topDoor];
    
    bottomDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-bottomdoor"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:bottomDoor];
    bottomDoor.size= scaledSize;
    bottomDoor.position = CGPointMake(size.width /1.735 ,72/scaleY + (floorOn * bannerSizeY) );
    bottomDoor.zPosition = doorZPos;
    [self addChild:bottomDoor];
    
    
    leftDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-leftdoor"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:leftDoor];
    leftDoor.size= scaledSize;
    leftDoor.position = CGPointMake(82/scaleX ,size.height/2 + (37/scaleY)+bannerHeightAdjuster);
    leftDoor.zPosition = doorZPos;
    [self addChild:leftDoor];

    rightDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-rightdoor"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:rightDoor];
    rightDoor.size= scaledSize;
    rightDoor.position = CGPointMake(size.width - (84/scaleX),size.height/2 + (45/scaleY)+bannerHeightAdjuster);
    rightDoor.zPosition = doorZPos;
    [self addChild:rightDoor];
    
}

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

    //[scene runAction:[SKAction scaleTo:0.5 duration:0]];

//    SKAction *zoom =       [SKAction scaleTo:2.0 duration:0.25];
//    SKAction *wait =       [SKAction waitForDuration: 0.5];
//    SKAction *fadeAway =   [SKAction fadeOutWithDuration:0.25];
//    SKAction *removeNode = [SKAction removeFromParent];
//
//    SKAction *sequence = [SKAction sequence:@[moveUp, zoom, wait, fadeAway, removeNode]];
//    [node runAction: sequence];


//just to be able to log coords and see what they are
//    UITouch *touched = [[event allTouches] anyObject];
//    CGPoint location = [touched locationInView:touched.view];
//    location.x = location.x * scaleX;
//    location.y = location.y * scaleY;
//    NSLog(@"x=%.2f y=%.2f", location.x, location.y);
}

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
