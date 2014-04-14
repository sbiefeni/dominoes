//
//  domMenuScene.m
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}


#import "domMenuScene.h"
#import "domGameScene.h"
#import "clsCommon.h"
#import "domViewController.h"
#import "clsGameSettings.h"
#import "GameKitHelper.h"


#import "SKEmitterNode+fromFile.h"

//#import <AudioToolbox/AudioServices.h>

@implementation domMenuScene

-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {


        //start the background music track playing
        [domViewController setAdView:NO ShowOnTop:NO ChooseRandom:YES];
        [clsCommon playBackgroundMusicWithVolume:.2];


        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background_Stars"];
        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        [background advanceSimulationTime:10];

        self.backgroundColor = [SKColor blackColor];
        
        [self addChild:background];

        sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

        int highScore = [self getHighScore];
        int levelHighscore = [self getLevelHighscore];

        if (gameStatus != game_Started ) {  //game hasn't started.. show initial screen

                SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:title text:@"300" fontSize:130 posY:40 color:[SKColor redColor] alpha:.7 sizeDoubler:sizeDoubler];

            SKLabelNode *title2 = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:title2 text:@"bricks" fontSize:45 posY:10 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode* hscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            
            [self createLabel:hscore text:[NSString stringWithFormat:@"High Score: %i",(int)highScore] fontSize:20 posY:150 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:hlscore text:[NSString stringWithFormat:@"Best Level: %i",(int)levelHighscore] fontSize:30 posY:180 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                [self addChild: [self instruct:sizeDoubler posY:-135]]; //instructions button, from below

                SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
                [self createLabel:tapToPlay text:@"Tap to Play" fontSize:40 posY:-50 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

//game center button------------------

        //get the gamecenter enabled setting from usersettings
            gcEnabled = ([[clsCommon getUserSettingForKey:@"gcEnabled"] isEqual: @"1"]);

        if(gcEnabled){
            [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
            
        }else{
            SKSpriteNode *gcButton = [SKSpriteNode spriteNodeWithImageNamed:@"stretch_button.png"];
            gcButton.position = CGPointMake(CGRectGetMidX(self.frame), 30);
            gcButton.name = @"gamecenter";
            [self addChild:gcButton];

            SKLabelNode *gcLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            [self createLabel:gcLabel text:@"Game Center" fontSize:30 posY:-((size.height/2)/sizeDoubler) color:[SKColor blackColor] alpha:.7 sizeDoubler:1];
            gcLabel.position = gcButton.position;
            gcLabel.zPosition = 25;
            gcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            gcLabel.name = @"gamecenterlabel";
        }
//------------------------------------


                gameStatus = reset;

        }else if(gameStatus == game_Started && lives > 0)   { // game started...

                //show score screen

                totalScore += score;

                SKLabelNode *cur_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:cur_score text:[NSString stringWithFormat:@"Score: %i",score] fontSize:50 posY:0 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:tot_score text:[NSString stringWithFormat:@"Total Score: %i",totalScore] fontSize:30 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *Lives = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:Lives text:[NSString stringWithFormat:@"Lives: %i",lives] fontSize:30 posY:-100 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
                [self createLabel:tapToPlay text:@"Tap to continue" fontSize:40 posY:-145 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

            //for debugging - to reset the level high score
            //levelHighscore = 0;
            //[self setLevelHighScore: 0];

                //if new best level, give a message and store it!
                if (score > levelHighscore) {
                    [self setLevelHighScore: score];

                    levelHighscore = score;

                    SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                    [self createLabel:hs text:@"NEW BEST LEVEL!" fontSize:30 posY:120 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];
                }

                SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                [self createLabel:hlscore text:[NSString stringWithFormat:@"Best Level: %i",(int)levelHighscore] fontSize:20 posY:80 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        }else{
                //game over
                //TODO game over stuff here


                totalScore += score;

            //debugging - reset the total score
            highScore=0;
            [self setHighScore:0];

                //if new high score, give a message and store it!
                if (totalScore > highScore) {
                    [self setHighScore:totalScore];

                    SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                    [self createLabel:hs text:@"NEW HIGH SCORE!" fontSize:30 posY:120 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];
                    if (gcEnabled){
                    //set the gamecenter score
                     [[GameKitHelper sharedGameKitHelper] reportHighScore:totalScore];
                    }
                }

                SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:title text:@"GAME OVER" fontSize:45 posY:30 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];


                SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:tot_score text:@"Total Score" fontSize:40 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *tot_score2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:tot_score2 text:[NSString stringWithFormat:@"%i",totalScore] fontSize:80 posY:-150 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                gameStatus = game_Over;

                if (score > levelHighscore) {
                    [self setLevelHighScore: score];
                }

                //reset score to 0 now, for next round
                score = 0;

        // TODO games center stuff
        //dfdkjhfskjhfskjhfk00-00
        
    }


//this block only auto-restarts if the app is
//        running in the IDE
//            [self runAction:[SKAction sequence:@[
//                [SKAction waitForDuration:2],
//                [SKAction runBlock:^{
//                    isRunningInIde(
//                            domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
//                            [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
//                    )
//                }],
//            ]]];

        
        
    }//end super initwithsize
    return self;
}//end initwithsize


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setHighScore:(int)score {
    NSString* _score = [NSString stringWithFormat:@"%i",score];
    [clsCommon storeUserSetting:@"highscore" value:_score];
}

-(void) setLevelHighScore:(int)score {
    NSString* _score = [NSString stringWithFormat:@"%i",score];
    [clsCommon storeUserSetting:@"levelHighscore" value:_score];
}
-(int) getHighScore {
    NSString* _score;
    _score = [clsCommon getUserSettingForKey:@"highscore"];
    int value = [_score intValue];
    return value;
}

-(int) getLevelHighscore {
    NSString* _score;
    _score = [clsCommon getUserSettingForKey:@"levelHighscore"];
    int value = [_score intValue];
    return value;
}

-(void) createLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posY:(int)posY color:(SKColor*)color alpha:(float)alpha sizeDoubler:(int)sizeDoubler {

    label.text = text;
    label.fontSize = fontSize * sizeDoubler;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + posY * sizeDoubler);
    label.fontColor = color;
    label.alpha = alpha;

    [self addChild:label];

}


- (SKSpriteNode *)instruct:(int)sizeDoubler posY:(int)posY
{
    SKSpriteNode *instruct = [SKSpriteNode spriteNodeWithImageNamed:@"directions"];
    instruct.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame) + (posY * sizeDoubler) );
    instruct.name = @"instructions";//how the node is identified later
    instruct.zPosition = 10;
    instruct.alpha = .7;
    return instruct;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];

        // if gamecenter button touched, launch it
        if ([node.name isEqualToString:@"gamecenter"] || [node.name isEqualToString:@"gamecenterlabel"]) {
            NSLog(@"GameCenter Button pressed");
            
            [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        }else{

            if (gameStatus == reset || gameStatus == game_Started) {
                domViewController *dv=[domViewController new];
                [dv showLeaderBoard:YES];
                
                //domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
                //[self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:.75]];
                
            }else{
                domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                [self.view presentScene:menu transition:[SKTransition doorsOpenHorizontalWithDuration:.75]];
            }
        }

}

@end
