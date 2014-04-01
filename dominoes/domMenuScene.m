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

#import "SKEmitterNode+fromFile.h"

//#import <AudioToolbox/AudioServices.h>

@implementation domMenuScene


-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {


        //start the background music track playing
        [domViewController setAdView:NO ShowOnTop:NO];
        [clsCommon playBackgroundMusicWithVolume:.2];


        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background_Stars"];
        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        [background advanceSimulationTime:10];

        self.backgroundColor = [SKColor blackColor];
        
        [self addChild:background];

        int sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

if (gameStatus == reset) {  //game hasn't started.. show initial screen

        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:title text:@"brick'd" fontSize:60 posY:30 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        [self addChild: [self instruct:sizeDoubler posY:150]]; //instructions button, from below

        SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        [self createLabel:tapToPlay text:@"Tap to Play" fontSize:40 posY:-40 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

}else if(gameStatus == game_Started && lives > 0)   { // game started...

        //show score screen

        SKLabelNode *cur_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:cur_score text:[NSString stringWithFormat:@"Score: %i",score] fontSize:50 posY:30 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        totalScore += score;

        SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:tot_score text:[NSString stringWithFormat:@"Total Score: %i",totalScore] fontSize:30 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        SKLabelNode *Lives = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:Lives text:[NSString stringWithFormat:@"Lives: %i",lives] fontSize:30 posY:-100 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];
}else{
        //game over
        //TODO game over stuff here
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:title text:@"GAME OVER" fontSize:45 posY:30 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:tot_score text:@"Total Score" fontSize:40 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        SKLabelNode *tot_score2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        [self createLabel:tot_score2 text:[NSString stringWithFormat:@"%i",totalScore] fontSize:80 posY:-150 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

        gameStatus = 2;

}
        //NSString *currentModeName = [[NSUserDefaults standardUserDefaults] stringForKey:ORBGameModeDefault];
        //_currentMode = NSClassFromString(currentModeName);
        //if(!_currentMode)
            //_currentMode = [self availableGameScenes][0];
        
        //_modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_modeButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:40];
        //[_modeButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
        //_modeButton.frame = CGRectMake(0, (self.size.height - tapToPlay.position.y) + 20, self.size.width, 60);
        //[self updateModeButton];
        //[_modeButton addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventTouchUpInside];



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


    }
    return self;
}

-(void) createLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posY:(int)posY color:(SKColor*)color alpha:(float)alpha sizeDoubler:(int)sizeDoubler {

    label.text = text;
    label.fontSize = fontSize * sizeDoubler;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + posY * sizeDoubler);
    label.color = color;
    label.alpha = alpha;

    [self addChild:label];

}

- (SKSpriteNode *)instruct:(int)sizeDoubler posY:(int)posY
{
    SKSpriteNode *instruct = [SKSpriteNode spriteNodeWithImageNamed:@"directions"];
    instruct.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame) - (posY * sizeDoubler) );
    instruct.name = @"instructions";//how the node is identified later
    instruct.zPosition = 10;
    instruct.alpha = .7;
    return instruct;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    @autoreleasepool {

        if (gameStatus == reset || gameStatus == game_Started) {
            domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
            [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
        }else{
            domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
            [self.view presentScene:menu transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
        }


    }
}

@end
