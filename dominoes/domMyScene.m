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
#define ceilingOn   0
#define floorOn     0

//define the min and max extents of the domino grid area
#define minX        130
#define minY        130
#define maxX        1420
#define maxY        1940

//define z positions for objects
#define doorZPos    5
#define dominoZPos  6

//define rows and cols
#define rows        30
#define cols        24

//scale up the domino size relative to the grid
#define dominoScaleFactor 1.3   // - 1.3 looks best

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
    BOOL grid [rows][cols];
    float gridWidth;
    float gridHeight;
    CGSize dominoSize;


    
//use these to store each movement, in sequence, for each player
//max size is the total available grid squares, so we never run out
//of room
    int playerA [rows * cols];
    int enemyA [rows * cols];
    
    player* player1;

// set game speed
    float gameSpeed;
    
    
    


}


@end

@implementation domMyScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        arenaSize = size;
        gameSpeed = .5;
        
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
    
//set the size of the dominoes
    dominoSize = CGSizeMake((gridHeight/rows)/scaleY*dominoScaleFactor, (gridWidth/cols)/scaleX*dominoScaleFactor);
    
}
-(void) initializeGame{

    player1 = [[player alloc]init];

//set the start position and direction of player
    player1.curX = 7;
    player1.curY = 6;
    player1.curDirection = up;
    
//set initial player1 direction - ***HACK? - NSUserDefaults lets us easily communicate variables between classes.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInt:3] forKey:@"playerDirection"];
        [standardUserDefaults synchronize];
    }

//start the timer that runs the game!
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(gameRunner) onTarget:self],[SKAction waitForDuration:gameSpeed]]]]];

}
-(void) gameRunner {
    SKSpriteNode* domino =[[SKSpriteNode alloc]init];
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
            if (player1.curX > 0) {
                player1.curX --;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case right:
            if (player1.curX < cols){
                player1.curX ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case up:
            if (player1.curY < rows){
                player1.curY ++;
            }else{
                //NSLog(@"CRASH!!!");
                crashed = true;
            }
            break;
        case down:
            if (player1.curY > 0){
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

    //NSLog(@"Domino Placed: X-%i, Y-%i", player1.curX, player1.curY);

    [self addChild:domino];
}
    
}
-(void) updatePlayerDirection:(swipeDirection)direction{

    player1.curDirection = direction;

}

//- (int)methodName:(int)arg1 withArg2:(int)arg2
- (CGPoint) calcDominoPosition:(int)x withArg2:(int) y{
    
    int xPos;
    int yPos;
    
    //minX = width of wall
    //dominoSize = width/height of domino tile
    xPos = minX/scaleX + (x * dominoSize.width/dominoScaleFactor);
    yPos = minY/scaleY + (y * dominoSize.height/dominoScaleFactor);

     NSLog(@"Domino Placed: X-%i, Y-%i", xPos, yPos);
    
    return CGPointMake(xPos, yPos);
}


//-(void) setUpDominoGrid: (CGSize)size{
//    dominoH  = [SKSpriteNode spriteNodeWithImageNamed:@"dominoH.png"];
//    dominoV  = [SKSpriteNode spriteNodeWithImageNamed:@"dominoV.png"];
//    
//    
//    //grab the unscaled image, and resize using the scale factors scaleX and scaleY
//    scaledSize = [self getScaledSizeForNode:dominoH];
//    dominoH.size= scaledSize;
//    
//    scaledSize = [self getScaledSizeForNode:dominoV];
//    dominoV.size = scaledSize;
//    
//    dominoV.position = CGPointMake(size.width /2 ,size.height/2);
//    dominoH.position = CGPointMake(size.width /1.735 ,size.height/2 );
//    dominoV.zPosition = dominoZPos;
//    dominoH.zPosition = dominoZPos;
//    
//    [self addChild:dominoH];
//    [self addChild:dominoV];
//    
//}

-(void) setUpBackGround{

    int bannerCount =0;
    
    
    //determine the banner size (according to iAD)
    bannerSizeY = (arenaSize.width == 320) ? 50 : 66;
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
    backGround.zPosition = 5;
    
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
//just to be able to log coords and see what they are
    UITouch *touched = [[event allTouches] anyObject];
    CGPoint location = [touched locationInView:touched.view];
    location.x = location.x * scaleX;
    location.y = location.y * scaleY;
    NSLog(@"x=%.2f y=%.2f", location.x, location.y);
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
//}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end
