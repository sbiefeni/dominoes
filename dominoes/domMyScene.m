//
//  domMyScene.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domMyScene.h"
#import "player.h"
#import "domino.h"

//using 0 and 1 instead of BOOL so I can use these in calculations
#define ceilingOn   1
#define floorOn     0

//define the min and max extents of the domino grid area
#define minX        145
#define minY        135
#define maxX        1400
#define maxY        1900

//define z positions for objects
#define doorZPos    5
#define dominoZPos  6

//define rows and cols
#define rows        30
#define cols        16

//scale up the domino size relative to the grid
#define dominoScaleFactorX 1.25   // - 1.25
#define dominoScaleFactorY 1.35    //

@interface domMyScene (){
    
    SKSpriteNode* backGround;
    SKSpriteNode* topDoor;
    SKSpriteNode* rightDoor;
    SKSpriteNode* bottomDoor;
    SKSpriteNode* leftDoor;
    
    
    //dominoes
    SKSpriteNode* dominoH;
    SKSpriteNode* dominoV;
    
    
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
    float gridWidth;
    float gridHeight;

    CGSize gridSize;
    CGSize dominoSize;


    
//use these to store each movement, in sequence, for each player
//max size is the total available grid squares, so we never run out
//of room
    NSMutableArray* playerDominos;
    NSMutableArray* computerDominos;
    
    player* player1;
    player* player2;

// set game speed
    float gameSpeed;
    
    
    


}
@end

@implementation domMyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        arenaSize = size;
        gameSpeed = .40;
        
        [self setUpBackGround];
        
        [self setUpDoors:size];
        
        [self setUpDominoGrid];
        
        [self initializeGame];
        
        NSLog(@"Width: %f, Height: %f", size.width, size.height);
    }
    return self;
}

-(void) setUpDominoGrid{
    
//set the width and height of the grid
    gridWidth = maxX - minX;
    gridHeight = maxY - minY;
    
//set the size of the grid and dominoes
    gridSize = CGSizeMake(gridWidth/cols/scaleX, gridHeight/rows/scaleY);
    dominoSize = CGSizeMake((gridWidth/cols)/scaleX*dominoScaleFactorX, (gridHeight/rows)/scaleY*dominoScaleFactorY);

//initialize the grid BOOL
    for (int i=0; i<(cols+1); i++) {
        for (int ii=0; ii < (rows+1); ii++) {
            grid[i][ii]=false;
        }
    }
}

-(void) initializeGame{

    player1 = [player new];
    player2 = [player new];

    playerDominos=[NSMutableArray new ];
    computerDominos=[NSMutableArray new];
    
//set the start position and direction of players
    player1.curX = cols/2 - 2;
    player1.curY = rows/2;
    player1.curDirection = up;

    player2.curX = cols/2 + 2;
    player2.curY = rows/2;
    player2.curDirection = down;

//set the speed interval between moves (time for both player and computer to complete one move)
    gameSpeed = .40;
    
//set initial player1 direction - ***HACK? - NSUserDefaults lets us easily communicate variables between classes.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInt:3] forKey:@"playerDirection"];
        [standardUserDefaults synchronize];
    }

//start the timer that runs the game!
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(gameRunner) onTarget:self],[SKAction waitForDuration:gameSpeed]]]]];

}

//********* Game Runner - is called on interval time 'gameSpeed' from the repeat action above..
-(void) gameRunner {

//player move
    [self handlePlayerMove];

//computer move, 1/2 of gameSpeed interval wait time to run it
//    [self runAction:[SKAction sequence:@[
//        [SKAction waitForDuration:gameSpeed/2],
//        [SKAction performSelector:@selector(handleComputerMove) onTarget:self],
//    ]]];
}

-(void) handleComputerMove {

    SKSpriteNode* domino = [SKSpriteNode new];
    BOOL crashed = false;

    BOOL ComputerBool=false;

    //Computer direction should already be set.. default:down

    switch (player2.curDirection) {
        case left:
            if (player2.curX > 0 && grid[player2.curX-1][player2.curY]==false) {
                player2.curX --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case right:
            if (player2.curX < cols && grid[player2.curX+1][player2.curY]==false){
                player2.curX ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case up:
            if (player2.curY < rows && grid[player2.curX][player2.curY+1]==false){
                player2.curY ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case down:
            if (player2.curY > 0 && grid[player2.curX][player2.curY-1]==false){
                player2.curY --;
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
        if(player2.curDirection == up || player2.curDirection==down)
        {
            domino = [SKSpriteNode spriteNodeWithImageNamed:@"dominoH.png"];
        }else{
            domino = [SKSpriteNode spriteNodeWithImageNamed:@"dominoV.png"];
        }

        domino.size = dominoSize;
        domino.zPosition = dominoZPos;

        //[objectWithOurMethod methodName:int1 withArg2:int2];
        domino.position = [self calcDominoPosition:player2.curX withArg2:player2.curY];



        [self addChild:domino];

    }

}

-(void) handlePlayerMove{

    SKSpriteNode* domino =[SKSpriteNode new];
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
            domino = [SKSpriteNode spriteNodeWithImageNamed:@"dominoH.png"];
        }else {
            domino = [SKSpriteNode spriteNodeWithImageNamed:@"dominoV.png"];
        }

        domino.size = dominoSize;
        domino.zPosition = dominoZPos;

        //[objectWithOurMethod methodName:int1 withArg2:int2];
        domino.position = [self calcDominoPosition:player1.curX withArg2:player1.curY];


        [self addChild:domino];

        //reset explosion so it can happen again..
        player1.didExplosion = false;

        //add to the array so we can track back later
        [playerDominos addObject:domino];

        //add to the grid... for domino colision detection
        grid[player1.curX][player1.curY]=true;

    //play a sound
    [self runAction: [SKAction playSoundFileNamed:@"tileclick.mp3" waitForCompletion:NO]];
        
}else{
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

            crashed = false;

        [explosion runAction:[SKAction sequence:@[
                [SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO],
                //[SKAction waitForDuration:0.4]
                //[SKAction runBlock:^{
                // TODO: Remove these more nicely
                //[killingEnemy removeFromParent];
                //[_player removeFromParent];
                //],
                [SKAction waitForDuration:0.35],
                [SKAction runBlock:^{ explosion.particleBirthRate = 0;} ],
                [SKAction waitForDuration:1.2],
                [SKAction runBlock:^{ [explosion removeFromParent]; } ]
                //[SKAction runBlock:^{
                        //ORBMenuScene *menu = [[ORBMenuScene alloc] initWithSize:self.size];
                          //[self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];

        ]]];

    } //end if (player1.crashed)
    
}  //end if (!crashed)

}

-(void) updatePlayerDirection:(swipeDirection)direction{

    player1.curDirection = direction;

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
        SKSpriteNode* floor = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(arenaSize.width, bannerSizeY)];
        floor.position = CGPointMake(arenaSize.width/2, (bannerSizeY/2));
        [self addChild:floor];
        bannerCount +=1;
    }
    if (ceilingOn){
        SKSpriteNode* ceiling = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(arenaSize.width, bannerSizeY)];
        ceiling.position = CGPointMake(arenaSize.width/2, arenaSize.height-(bannerSizeY/2));
        [self addChild:ceiling];
        bannerCount +=1;
    }
    
    
    
    backGround = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-arena.png"];
//get the scale factors, so we know how much to scale any other images
    scaleX = backGround.size.width  / arenaSize.width;
    scaleY = backGround.size.height / (arenaSize.height -(bannerSizeY * bannerCount) );
    
    backGround.size = CGSizeMake(arenaSize.width, arenaSize.height-(bannerSizeY * bannerCount) );
    
    float backGroundPos = arenaSize.height/2 + bannerHeightAdjuster ;

    
    backGround.position = CGPointMake(arenaSize.width/2, backGroundPos);
    backGround.zPosition = 1;
    
    [self addChild:backGround];
}

-(void) setUpDoors:(CGSize) size{
    
    topDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-topDoor.png"];

    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:topDoor];
    
    topDoor.size= scaledSize;
    topDoor.position = CGPointMake(size.width /1.735 ,size.height - (scaledSize.height/2) - (ceilingOn * bannerSizeY) );
    topDoor.zPosition = doorZPos;
    
    [self addChild:topDoor];
    
    bottomDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-bottomDoor.png"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:bottomDoor];
    bottomDoor.size= scaledSize;
    bottomDoor.position = CGPointMake(size.width /1.735 ,72/scaleY + (floorOn * bannerSizeY) );
    bottomDoor.zPosition = doorZPos;
    [self addChild:bottomDoor];
    
    
    leftDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-leftDoor.png"];
    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
    scaledSize = [self getScaledSizeForNode:leftDoor];
    leftDoor.size= scaledSize;
    leftDoor.position = CGPointMake(82/scaleX ,size.height/2 + (37/scaleY)+bannerHeightAdjuster);
    leftDoor.zPosition = doorZPos;
    [self addChild:leftDoor];

    rightDoor = [SKSpriteNode spriteNodeWithImageNamed:@"dominoes-rightDoor.png"];
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end
